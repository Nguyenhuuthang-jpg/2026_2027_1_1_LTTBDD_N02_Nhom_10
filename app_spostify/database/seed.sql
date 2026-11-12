
-- Thể loại ( có thể thêm )
insert into public.genres (name) values
  ('Pop'), ('Indie'), ('Acoustic'), ('Hip-hop'), ('Chill')
on conflict (name) do nothing;

-- Bài hát. 4 bài đầu phát từ file trong app (assets/audio, chỉ có trên máy, xem assets/audio/README.md).
insert into public.songs (title, artist, genre_id, duration_seconds, play_count, is_visible, audio_url) values
  ('Có Mình Và Ta',      'Nguyễn Vĩ',          (select id from public.genres where name = 'Pop'),      258, 12840, true, 'asset:///assets/audio/co-minh-va-ta.mp3'),
  ('Một Đêm Say',        'Thịnh Suy',          (select id from public.genres where name = 'Chill'),    234, 11230, true, 'asset:///assets/audio/mot-dem-say.mp3'),
  ('Thích Em Tâm Huyết', 'Kai Đinh, Juky San', (select id from public.genres where name = 'Pop'),      226,  9870, true, 'asset:///assets/audio/thich-em-tam-huyet.mp3'),
  ('Đêm Thành Phố',      'Lope Dope',          (select id from public.genres where name = 'Hip-hop'),  244,  6420, true, 'asset:///assets/audio/dem-thanh-pho.mp3'),
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
     (p.name = 'Chill buổi tối'    and s.title in ('Một Đêm Say', 'Đêm Thành Phố'))
  or (p.name = 'Tập trung học bài' and s.title in ('Acoustic Việt', 'Thích Em Tâm Huyết'))
  or (p.name = 'Khám phá hôm nay'  and s.title in ('Có Mình Và Ta', 'Một Đêm Say', 'Thích Em Tâm Huyết'))
  or (p.name = 'Nhạc Việt mới'     and s.title in ('Có Mình Và Ta', 'Thích Em Tâm Huyết'))
  or (p.name = 'Top thịnh hành'    and s.title in ('Có Mình Và Ta', 'Một Đêm Say', 'Thích Em Tâm Huyết'))
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
