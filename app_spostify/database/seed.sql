
-- Thể loại ( có thể thêm )
insert into public.genres (name) values
  ('Pop'), ('Indie'), ('Acoustic'), ('Hip-hop'), ('Chill')
on conflict (name) do nothing;

-- Bài hát (khớp bản demo giao diện)
insert into public.songs (title, artist, genre_id, duration_seconds, play_count, is_visible, audio_url) values
  ('Ngày chưa giông bão', 'Bùi Lan Hương',  (select id from public.genres where name = 'Indie'),    252, 12840, true, 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'),
  ('Một đêm say',         'Thịnh Suy',      (select id from public.genres where name = 'Chill'),    228, 11230, true, 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'),
  ('Có em',               'Madihu',         (select id from public.genres where name = 'Pop'),      201,  9870, true, 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3'),
  ('Đêm thành phố',       'Nhiều nghệ sĩ',  (select id from public.genres where name = 'Chill'),    185,  6420, true, 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3'),
  ('Acoustic Việt',       'Tuyển chọn',     (select id from public.genres where name = 'Acoustic'), 280,  4310, false, 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3');

-- Playlist
insert into public.playlists (name, description, is_visible) values
  ('Chill buổi tối',     'Nhạc nhẹ cho buổi tối',            true),
  ('Tập trung học bài',  'Giai điệu giúp bạn tập trung',     true),
  ('Khám phá hôm nay',   'Những bài hát hợp gu bạn',         true),
  ('Nhạc Việt mới',      'Các bản phát hành mới',            false),
  ('Top thịnh hành',     'Những bản nhạc nổi bật',           false);

-- Gán bài hát vào playlist
insert into public.playlist_songs (playlist_id, song_id, position)
select p.id, s.id, row_number() over (partition by p.id order by s.id) - 1
from public.playlists p
join public.songs s on
     (p.name = 'Chill buổi tối'    and s.title in ('Một đêm say', 'Đêm thành phố'))
  or (p.name = 'Tập trung học bài' and s.title in ('Acoustic Việt', 'Có em'))
  or (p.name = 'Khám phá hôm nay'  and s.title in ('Ngày chưa giông bão', 'Một đêm say', 'Có em'))
  or (p.name = 'Nhạc Việt mới'     and s.title in ('Ngày chưa giông bão', 'Có em'))
  or (p.name = 'Top thịnh hành'    and s.title in ('Ngày chưa giông bão', 'Một đêm say', 'Có em'))
on conflict do nothing;

-- ---------------------------------------------------------------------
-- Tài khoản admin
-- Không thể tạo mật khẩu bằng SQL thuần, nên làm 2 bước:
--   1) Supabase → Authentication → Users → Add user
--      (email: admin@giaidieu.vn, mật khẩu tùy bạn, tick "Auto Confirm User").
--      Trigger handle_new_user sẽ tự tạo dòng trong public.profiles.
--   2) Chạy lệnh sau để nâng quyền:
--
--   alter table public.profiles disable trigger protect_profile_columns;
--   update public.profiles set role = 'admin', display_name = 'Minh Anh'
--   where email = 'admin@giaidieu.vn';
--   alter table public.profiles enable trigger protect_profile_columns;
--
-- Cách nhanh hơn: chạy database/sample_accounts.sql (tạo sẵn admin + user mẫu).
--
-- Tài khoản người dùng thường chỉ cần đăng ký bằng màn Đăng ký trong app.
-- ---------------------------------------------------------------------
