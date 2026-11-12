-- Đổi 4 bài hát mẫu sang 4 bài phát từ file trong app (assets/audio).
-- Dùng cho database ĐÃ chạy seed.sql bản cũ. Chạy trong Supabase SQL Editor.
-- Database tạo mới bằng seed.sql bản hiện tại thì không cần chạy file này.
-- File .mp3 phải có sẵn trong app_spostify/assets/audio/ (xem assets/audio/README.md).

update public.songs s
set title            = v.new_title,
    artist           = v.artist,
    genre_id         = (select id from public.genres g where g.name = v.genre),
    duration_seconds = v.seconds,
    audio_url        = v.url
from (values
  ('Ngày chưa giông bão', 'Có Mình Và Ta',      'Nguyễn Vĩ',          'Pop',     258, 'asset:///assets/audio/co-minh-va-ta.mp3'),
  ('Một đêm say',         'Một Đêm Say',        'Thịnh Suy',          'Chill',   234, 'asset:///assets/audio/mot-dem-say.mp3'),
  ('Có em',               'Thích Em Tâm Huyết', 'Kai Đinh, Juky San', 'Pop',     226, 'asset:///assets/audio/thich-em-tam-huyet.mp3'),
  ('Đêm thành phố',       'Đêm Thành Phố',      'Lope Dope',          'Hip-hop', 244, 'asset:///assets/audio/dem-thanh-pho.mp3')
) as v(old_title, new_title, artist, genre, seconds, url)
where s.title = v.old_title;
