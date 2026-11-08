# Giai Điệu – ứng dụng nghe nhạc (Flutter + Supabase)

## 1. Chuẩn bị Supabase (làm một lần)
1. Tạo project tại https://supabase.com.
2. Vào **SQL Editor**, chạy lần lượt: `database/schema.sql` → `database/policies.sql` → `database/seed.sql`.
3. Tạo tài khoản admin: **Authentication → Users → Add user** (tick *Auto Confirm User*), rồi chạy:
   ```sql
   update public.profiles set role = 'admin' where email = 'admin@giaidieu.vn';
   ```
4. (Tùy chọn) Tắt *Confirm email* ở **Authentication → Providers → Email** để đăng ký xong vào app ngay.

> Tài khoản đăng ký **trước** khi chạy `schema.sql` sẽ không có dòng trong `profiles`
> và không đăng nhập được – hãy xóa và đăng ký lại.

## 2. Cấu hình khóa
Sao chép `env.example.json` thành `env.json` rồi điền giá trị ở **Project Settings → API**:
```json
{ "SUPABASE_URL": "https://xxxx.supabase.co", "SUPABASE_ANON_KEY": "sb_publishable_..." }
```
`env.json` đã nằm trong `.gitignore`. Không dùng `service_role` key trong app.

## 3. Chạy
```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=env.json
```
Trong VS Code: **Run and Debug** → chọn cấu hình *Giai Điệu (Chrome)* (file `.vscode/launch.json`).

Chạy bản Windows desktop cần Visual Studio có workload **Desktop development with C++**
(kiểm tra bằng `flutter doctor`).

## 4. Kiểm tra
```bash
flutter analyze
flutter test
```

## Cấu trúc chính
- `lib/features/auth` – đăng nhập, đăng ký
- `lib/features/user` – Trang chủ, Khám phá, Thư viện, Cá nhân, trình phát, chi tiết playlist
- `lib/features/admin` – Tổng quan, quản lý bài hát / playlist / người dùng, cài đặt
- `lib/providers` – trạng thái (Provider), gọi `lib/data/repositories`
- `lib/data/local` – cài đặt + cache ngoại tuyến (shared_preferences)

Bài hát chỉ phát được khi có `audio_url` (link .mp3 công khai, ví dụ từ Supabase Storage);
dữ liệu mẫu trong `seed.sql` chưa có link nhạc.
