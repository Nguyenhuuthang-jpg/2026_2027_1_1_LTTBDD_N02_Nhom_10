create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin' and is_active
  );
$$;

alter table public.profiles          enable row level security;
alter table public.genres            enable row level security;
alter table public.songs             enable row level security;
alter table public.playlists         enable row level security;
alter table public.playlist_songs    enable row level security;
alter table public.favorites         enable row level security;
alter table public.listening_history enable row level security;

-- ---------- profiles --------------------------------------------------
drop policy if exists "profiles: đọc hồ sơ của mình hoặc admin đọc tất cả" on public.profiles;
create policy "profiles: đọc hồ sơ của mình hoặc admin đọc tất cả"
  on public.profiles for select to authenticated
  using (id = auth.uid() or public.is_admin());

drop policy if exists "profiles: sửa hồ sơ của mình hoặc admin sửa tất cả" on public.profiles;
create policy "profiles: sửa hồ sơ của mình hoặc admin sửa tất cả"
  on public.profiles for update to authenticated
  using (id = auth.uid() or public.is_admin())
  with check (id = auth.uid() or public.is_admin());

-- Người dùng thường chỉ được đổi tên hiển thị / ảnh đại diện,
-- không được tự nâng quyền hay tự mở khóa.
create or replace function public.protect_profile_columns()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    if new.role is distinct from old.role
       or new.is_active is distinct from old.is_active
       or new.email is distinct from old.email
       or new.id is distinct from old.id then
      raise exception 'Bạn không có quyền đổi role, trạng thái hoặc email';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists protect_profile_columns on public.profiles;
create trigger protect_profile_columns
  before update on public.profiles
  for each row execute function public.protect_profile_columns();

-- Không có policy insert/delete: profile do trigger tạo, xóa theo auth.users.

-- ---------- genres ----------------------------------------------------
drop policy if exists "genres: ai đăng nhập cũng đọc được" on public.genres;
create policy "genres: ai đăng nhập cũng đọc được"
  on public.genres for select to authenticated using (true);

drop policy if exists "genres: admin quản lý" on public.genres;
create policy "genres: admin quản lý"
  on public.genres for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- ---------- songs -----------------------------------------------------
drop policy if exists "songs: người dùng chỉ thấy bài đang hiển thị, admin thấy tất cả" on public.songs;
create policy "songs: người dùng chỉ thấy bài đang hiển thị, admin thấy tất cả"
  on public.songs for select to authenticated
  using (is_visible or public.is_admin());

drop policy if exists "songs: admin thêm" on public.songs;
create policy "songs: admin thêm"
  on public.songs for insert to authenticated with check (public.is_admin());

drop policy if exists "songs: admin sửa / ẩn-hiện" on public.songs;
create policy "songs: admin sửa / ẩn-hiện"
  on public.songs for update to authenticated
  using (public.is_admin()) with check (public.is_admin());

drop policy if exists "songs: admin xóa" on public.songs;
create policy "songs: admin xóa"
  on public.songs for delete to authenticated using (public.is_admin());

-- ---------- playlists + playlist_songs --------------------------------
drop policy if exists "playlists: người dùng chỉ thấy playlist đang hiển thị" on public.playlists;
create policy "playlists: người dùng chỉ thấy playlist đang hiển thị"
  on public.playlists for select to authenticated
  using (is_visible or public.is_admin());

drop policy if exists "playlists: admin quản lý" on public.playlists;
create policy "playlists: admin quản lý"
  on public.playlists for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

drop policy if exists "playlist_songs: đọc được nếu thấy được playlist" on public.playlist_songs;
create policy "playlist_songs: đọc được nếu thấy được playlist"
  on public.playlist_songs for select to authenticated
  using (exists (
    select 1 from public.playlists p
    where p.id = playlist_id and (p.is_visible or public.is_admin())
  ));

drop policy if exists "playlist_songs: admin quản lý" on public.playlist_songs;
create policy "playlist_songs: admin quản lý"
  on public.playlist_songs for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- ---------- favorites (thư viện) --------------------------------------
drop policy if exists "favorites: chỉ chủ sở hữu" on public.favorites;
create policy "favorites: chỉ chủ sở hữu"
  on public.favorites for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ---------- listening_history -----------------------------------------
-- Ghi lịch sử đi qua hàm record_play() (security definer) nên không mở insert trực tiếp.
drop policy if exists "history: đọc lịch sử của mình, admin đọc tất cả" on public.listening_history;
create policy "history: đọc lịch sử của mình, admin đọc tất cả"
  on public.listening_history for select to authenticated
  using (user_id = auth.uid() or public.is_admin());

drop policy if exists "history: xóa lịch sử của mình" on public.listening_history;
create policy "history: xóa lịch sử của mình"
  on public.listening_history for delete to authenticated
  using (user_id = auth.uid());

-- ---------- quyền thực thi hàm ----------------------------------------
revoke execute on function public.record_play(bigint)  from public, anon;
grant  execute on function public.record_play(bigint)  to authenticated;
revoke execute on function public.admin_daily_plays()  from public, anon;
grant  execute on function public.admin_daily_plays()  to authenticated;
