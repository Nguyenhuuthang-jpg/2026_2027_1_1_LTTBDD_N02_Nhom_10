# Nhạc phát trong app (assets/audio)

Thư mục này chứa file nhạc mà app phát trực tiếp, không cần mạng.
Đường dẫn lưu trong cột `audio_url` có dạng `asset:///assets/audio/<ten-file>.mp3`.

**File `.mp3` KHÔNG được đưa lên GitHub** (đã chặn trong `app_spostify/.gitignore`)
vì đây là các bài hát có bản quyền. Mỗi thành viên tự chép file vào thư mục này
trên máy của mình trước khi chạy app.

| Tên file cần đặt          | Bài hát            | Ca sĩ              |
|---------------------------|--------------------|--------------------|
| `co-minh-va-ta.mp3`       | Có Mình Và Ta      | Nguyễn Vĩ          |
| `mot-dem-say.mp3`         | Một Đêm Say        | Thịnh Suy          |
| `thich-em-tam-huyet.mp3`  | Thích Em Tâm Huyết | Kai Đinh, Juky San |
| `dem-thanh-pho.mp3`       | Đêm Thành Phố      | Lope Dope          |

Sau khi chép file, chạy `flutter pub get` rồi chạy lại app (không dùng hot reload).

Database tạo trước khi đổi bài hát: chạy thêm `database/nhac_tren_may.sql`
trong Supabase SQL Editor để cập nhật tên bài và đường dẫn nhạc.
