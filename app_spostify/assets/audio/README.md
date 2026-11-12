# Nhạc đóng gói trong app (tùy chọn)

Nhạc của app phát từ link công khai trên Supabase Storage (bucket `songs`,
xem `database/storage.sql`), nên **không cần chép file nào vào thư mục này**.

Thư mục chỉ dùng khi muốn phát một bài không cần mạng: chép file `.mp3` vào đây,
rồi nhập link nhạc ở màn admin theo dạng `asset:///assets/audio/<ten-file>.mp3`
và chạy lại app (không dùng hot reload).

File `.mp3` trong thư mục này không được đưa lên GitHub (đã chặn trong `.gitignore`).
Đừng xóa thư mục hay file `.gitkeep`: `pubspec.yaml` đang khai báo `assets/audio/`.
