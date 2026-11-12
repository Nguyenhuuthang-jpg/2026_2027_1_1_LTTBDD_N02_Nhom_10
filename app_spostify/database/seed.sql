
-- Thể loại ( có thể thêm )
insert into public.genres (name) values
  ('Pop'), ('Indie'), ('Acoustic'), ('Hip-hop'), ('Chill')
on conflict (name) do nothing;

-- Bài hát. Nhạc phát từ link công khai trên Supabase Storage (bucket songs, xem storage.sql).
insert into public.songs (title, artist, genre_id, duration_seconds, play_count, is_visible, audio_url) values
  ('Có Mình Và Ta',      'Nguyễn Vĩ',          (select id from public.genres where name = 'Pop'),      258, 12840, true, 'https://htzmhtjhgefdkmjsugky.supabase.co/storage/v1/object/public/songs/co_minh_va_ta.mp3'),
  ('Một Đêm Say',        'Thịnh Suy',          (select id from public.genres where name = 'Chill'),    234, 11230, true, 'https://htzmhtjhgefdkmjsugky.supabase.co/storage/v1/object/public/songs/mot_dem_say.mp3'),
  ('Thích Em Tâm Huyết', 'Kai Đinh, Juky San', (select id from public.genres where name = 'Pop'),      226,  9870, true, 'https://htzmhtjhgefdkmjsugky.supabase.co/storage/v1/object/public/songs/thich_em_tam_huyet.mp3'),
  ('Đêm Thành Phố',      'Lope Dope',          (select id from public.genres where name = 'Hip-hop'),  244,  6420, true, 'https://htzmhtjhgefdkmjsugky.supabase.co/storage/v1/object/public/songs/dem_thanh_pho.mp3'),
  ('Ngày chưa giông bão', 'Bùi Lan Hương',    (select id from public.genres where name = 'Indie'),    252,  4310, true, 'https://wtarqvlqzbguqauuibfe.supabase.co/storage/v1/object/public/songs/ngay_chua_giong_bao.mp3'),
  ('Haru Haru', 'BIGBANG', (select id from public.genres where name = 'Pop'), 256, 0, true, 'https://htzmhtjhgefdkmjsugky.supabase.co/storage/v1/object/public/songs/haru_haru.mp3'),
  ('Lưu Niên', 'Jack - J97', (select id from public.genres where name = 'Pop'), 194, 0, true, 'https://htzmhtjhgefdkmjsugky.supabase.co/storage/v1/object/public/songs/luu_nien.mp3'),
  ('Quá Đủ Rồi', 'CoolKid', (select id from public.genres where name = 'Pop'), 242, 0, true, 'https://htzmhtjhgefdkmjsugky.supabase.co/storage/v1/object/public/songs/qua_du_roi.mp3'),
  ('Anh Bình Thường', 'Duniverse', (select id from public.genres where name = 'Pop'), 204, 0, true, 'https://htzmhtjhgefdkmjsugky.supabase.co/storage/v1/object/public/songs/anh_binh_thuong.mp3'),
  ('2.0', 'BTS', (select id from public.genres where name = 'Hip-hop'), 170, 0, true, 'https://htzmhtjhgefdkmjsugky.supabase.co/storage/v1/object/public/songs/2_0.mp3'),
  ('Blingy', 'NCT 127', (select id from public.genres where name = 'Hip-hop'), 201, 0, true, 'https://htzmhtjhgefdkmjsugky.supabase.co/storage/v1/object/public/songs/blingy.mp3'),
  ('Xin Đừng Rời Xa Anh (Remix)', 'Lê Gia Bảo', (select id from public.genres where name = 'Pop'), 48, 0, true, 'https://htzmhtjhgefdkmjsugky.supabase.co/storage/v1/object/public/songs/xin_dung_roi_xa_anh.mp3'),
  ('Thiên Đường Với Người Thương', 'Phương Mỹ Chi, DTAP', (select id from public.genres where name = 'Pop'), 218, 0, true, 'https://htzmhtjhgefdkmjsugky.supabase.co/storage/v1/object/public/songs/thien_duong_voi_nguoi_thuong.mp3'),
  ('Chờ Chút...', 'CONGB', (select id from public.genres where name = 'Pop'), 224, 0, true, 'https://htzmhtjhgefdkmjsugky.supabase.co/storage/v1/object/public/songs/cho_chut.mp3'),
  ('Thế Nào Là Đúng', 'Bảo Anh', (select id from public.genres where name = 'Pop'), 234, 0, true, 'https://htzmhtjhgefdkmjsugky.supabase.co/storage/v1/object/public/songs/the_nao_la_dung.mp3'),
  ('Như Một Người Rưng', 'OSAD, Hà An Huy', (select id from public.genres where name = 'Pop'), 177, 0, true, 'https://htzmhtjhgefdkmjsugky.supabase.co/storage/v1/object/public/songs/nhu_mot_nguoi_rung.mp3'),
  ('Gió Thổi Tuyết Rơi', 'Lục Tiểu Lạc', (select id from public.genres where name = 'Pop'), 200, 0, true, 'https://htzmhtjhgefdkmjsugky.supabase.co/storage/v1/object/public/songs/gio_thoi_tuyet_roi.mp3');

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
  or (p.name = 'Tập trung học bài' and s.title in ('Ngày chưa giông bão', 'Thích Em Tâm Huyết'))
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
