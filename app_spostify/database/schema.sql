create extension if not exists "pgcrypto";

-- ---------- 1. profiles ----------------------------------------------
create table if not exists public.profiles (
  id           uuid primary key references auth.users (id) on delete cascade,
  display_name text        not null check (char_length(display_name) between 1 and 60),
  email        text        not null unique,
  role         text        not null default 'user' check (role in ('user', 'admin')),
  is_active    boolean     not null default true,   -- false = tài khoản bị khóa
  avatar_url   text,
  created_at   timestamptz not null default now()
);

-- ---------- 2. genres ------------------------------------------------
create table if not exists public.genres (
  id   serial primary key,
  name text not null unique
);

-- ---------- 3. songs -------------------------------------------------
create table if not exists public.songs (
  id               bigint generated always as identity primary key,
  title            text        not null check (char_length(title) between 1 and 60),
  artist           text        not null check (char_length(artist) between 1 and 40),
  genre_id         int         references public.genres (id) on delete set null,
  duration_seconds int         not null check (duration_seconds > 0),
  cover_url        text,
  audio_url        text,
  play_count       bigint      not null default 0,
  is_visible       boolean     not null default true,  -- false = admin đã ẩn
  created_by       uuid        references public.profiles (id) on delete set null,
  created_at       timestamptz not null default now()
);
create index if not exists songs_genre_idx on public.songs (genre_id);
create index if not exists songs_title_idx  on public.songs (lower(title));
create index if not exists songs_artist_idx on public.songs (lower(artist));

-- ---------- 4. playlists ---------------------------------------------
create table if not exists public.playlists (
  id          bigint generated always as identity primary key,
  name        text        not null check (char_length(name) between 1 and 60),
  description text,
  cover_url   text,
  is_visible  boolean     not null default true,  -- hiển thị ở "Dành riêng cho bạn"
  created_at  timestamptz not null default now()
);

-- ---------- 5. playlist_songs ----------------------------------------
create table if not exists public.playlist_songs (
  playlist_id bigint not null references public.playlists (id) on delete cascade,
  song_id     bigint not null references public.songs (id)     on delete cascade,
  position    int    not null default 0,
  primary key (playlist_id, song_id)
);
create index if not exists playlist_songs_song_idx on public.playlist_songs (song_id);

-- ---------- 6. favorites (thư viện của người dùng) --------------------
create table if not exists public.favorites (
  user_id    uuid        not null references public.profiles (id) on delete cascade,
  song_id    bigint      not null references public.songs (id)    on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, song_id)
);

-- ---------- 7. listening_history -------------------------------------
create table if not exists public.listening_history (
  id        bigint generated always as identity primary key,
  user_id   uuid        not null references public.profiles (id) on delete cascade,
  song_id   bigint      not null references public.songs (id)    on delete cascade,
  played_at timestamptz not null default now()
);
create index if not exists history_user_idx on public.listening_history (user_id, played_at desc);
create index if not exists history_time_idx on public.listening_history (played_at);

-- =====================================================================
-- Tự tạo profile khi có người đăng ký (Supabase Auth)
-- Màn Đăng ký truyền display_name qua options.data của signUp().
-- =====================================================================
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, display_name)
  values (
    new.id,
    new.email,
    coalesce(nullif(trim(new.raw_user_meta_data ->> 'display_name'), ''), split_part(new.email, '@', 1))
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- =====================================================================
-- Ghi nhận một lượt nghe: thêm lịch sử + tăng play_count
-- App gọi: supabase.rpc('record_play', params: {'p_song_id': id})
-- =====================================================================
create or replace function public.record_play(p_song_id bigint)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  insert into public.listening_history (user_id, song_id) values (auth.uid(), p_song_id);
  update public.songs set play_count = play_count + 1 where id = p_song_id;
end;
$$;

-- =====================================================================
-- View cho màn Xem tổng quan của admin
-- =====================================================================
-- Lượt nghe theo ngày (biểu đồ 14 ngày)
create or replace view public.daily_plays as
select (played_at at time zone 'Asia/Ho_Chi_Minh')::date as day,
       count(*)::int                                     as plays
from public.listening_history
where played_at >= now() - interval '14 days'
group by 1
order by 1;

-- Chỉ admin mới được đọc view này (view chạy với quyền owner nên phải tự chặn)
revoke all on public.daily_plays from anon, authenticated;

create or replace function public.admin_daily_plays()
returns table (day date, plays int)
language sql
security definer
set search_path = public
as $$
  select d.day, d.plays from public.daily_plays d
  where exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin');
$$;
