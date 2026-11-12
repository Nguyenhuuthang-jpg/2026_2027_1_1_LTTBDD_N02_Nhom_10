-- Thêm cột lời bài hát cho database tạo trước khi app có tính năng lời bài hát.
-- Thiếu cột này thì màn admin không thêm / sửa được bài hát
-- (lỗi "Could not find the 'lyrics' column of 'songs' in the schema cache").
-- Chạy trong Supabase SQL Editor. Chạy lại nhiều lần cũng không sao.
-- Database tạo mới bằng schema.sql bản hiện tại thì không cần chạy file này.

alter table public.songs add column if not exists lyrics text;

-- Báo cho API của Supabase nạp lại cấu trúc bảng ngay.
notify pgrst, 'reload schema';
