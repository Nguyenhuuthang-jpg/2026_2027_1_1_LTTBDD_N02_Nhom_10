# Giai Điệu – cập nhật giao diện phần 4–8

## Những file đã chỉnh
- `lib/features/auth/login_screen.dart`: làm mới màn hình đăng nhập theo phong cách của `Giai_Dieu_Demo1.html` (nền tối, xanh #1ED760, banner âm nhạc, form gọn, CTA xanh).
- `lib/features/auth/register_screen.dart`: làm mới màn hình đăng ký đồng bộ với đăng nhập.
- `lib/core/utils/validators.dart`: đồng bộ điều kiện mật khẩu tối thiểu 6 ký tự theo nội dung demo HTML.

Các luồng đăng nhập/đăng ký vẫn gọi `AuthProvider` và Supabase hiện có; không thay thế bằng dữ liệu giả, không sửa phần shell Admin/User thuộc thành viên khác.

## Chạy ứng dụng
Cần cấu hình Supabase như trước:

```bash
flutter pub get
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLISHABLE_OR_ANON_KEY
```

## Kiểm tra
```bash
flutter analyze
flutter test
```

Bản ZIP này là source Flutter đã cập nhật giao diện đăng nhập/đăng ký, không phải ảnh mockup hay file HTML giả lập. Do môi trường đóng gói không có Flutter SDK nên chưa thể chạy `flutter analyze`/`flutter test` tại đây.
