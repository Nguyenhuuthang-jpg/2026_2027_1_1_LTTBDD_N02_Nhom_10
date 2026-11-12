-- Gán nhạc demo (miễn phí bản quyền, nguồn SoundHelix) cho các bài hát mẫu
-- trong database đã tạo trước đó. Chạy trong Supabase SQL Editor.
-- Chỉ ghi vào bài chưa có audio_url để không đè link nhạc đã nhập từ màn admin.
-- Khi có file nhạc hợp lệ (có bản quyền/được phép), thay link qua màn admin.

update public.songs s
set audio_url = v.url
from (values
  ('Ngày chưa giông bão', 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'),
  ('Một đêm say',         'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'),
  ('Có em',               'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3'),
  ('Đêm thành phố',       'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3'),
  ('Acoustic Việt',       'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3')
) as v(title, url)
where s.title = v.title
  and (s.audio_url is null or btrim(s.audio_url) = '');
