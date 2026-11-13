# Giai Điệu — Ứng dụng nghe nhạc (Flutter + Supabase)

Bài tập lớn môn **Lập trình thiết bị di động** — **Nhóm 10**, Trường Công nghệ Thông tin, Đại học Phenikaa.  
**Giảng viên hướng dẫn:** ThS. Nguyễn Xuân Quế

---

## Thành viên nhóm

| STT | Họ và tên | Mã sinh viên | Vai trò chính |
| :-: | :--- | :---: | :--- |
| 1 | Nguyễn Hữu Thắng | 24100209 | Thiết kế CSDL Supabase, chính sách RLS, hàm RPC thống kê; Đăng nhập, đăng ký, phân quyền, khóa tài khoản |
| 2 | Kiều Vĩnh Tiến | 24100240 | Giao diện quản trị (Tổng quan, Bài hát, Playlist, Người dùng); Đa ngôn ngữ, Sáng/Tối, Cache cục bộ, Kiểm thử đơn vị |
| 3 | Nguyễn Xuân Thành | 24100115 | Giao diện người dùng (Onboarding, Trang chủ, Khám phá, Thư viện, Hồ sơ, Cài đặt); Trình phát nhạc, Yêu thích, Lịch sử nghe |

---

## Tính năng chính

### Phân hệ Người dùng (User)
- **Giới thiệu & Xác thực:** Màn hình Onboarding 3 trang khi mở lần đầu (có nút *Xem lại Onboarding* ở màn Đăng nhập), đăng ký/đăng nhập bằng email và mật khẩu qua Supabase Auth, tự động chặn tài khoản bị khóa.
- **Trang chủ:** Lời chào theo khung giờ, danh sách Playlist gợi ý (*Dành riêng cho bạn*), thẻ nổi bật `#1 THỊNH HÀNH` kèm bảng xếp hạng *Nghe nhiều nhất*, danh sách *Mới phát hành* và màn hình **Xem tất cả** cho từng mục.
- **Khám phá & Tìm kiếm:** Lọc nhanh bài hát theo tên/nghệ sĩ và theo thể loại ngay trên dữ liệu đã tải.
- **Trình phát nhạc:** Phát/tạm dừng, tua thanh tiến trình, chuyển bài trong hàng đợi, `MiniPlayer` đồng bộ xuyên suốt các tab và xem thông tin + lời bài hát.
- **Thư viện & Cá nhân:** Lưu bài hát yêu thích, tự động ghi nhận lịch sử nghe (kèm xóa lịch sử), đổi tên hiển thị, chuyển đổi Tiếng Việt / Tiếng Anh và giao diện Sáng / Tối.
- **Hỗ trợ ngoại tuyến cơ bản:** Tự động lưu cache JSON bài hát và Playlist bằng `SharedPreferences` (`LocalCacheStore`) để hiển thị lại khi mất kết nối mạng.

### Phân hệ Quản trị viên (Admin)
- **Tổng quan (Dashboard):** Thống kê tổng số tài khoản, bài hát, Playlist, lượt nghe trong ngày, biểu đồ cột 14 ngày gần nhất và Top 5 bài hát nghe nhiều nhất.
- **Quản lý bài hát:** Thêm, sửa, xóa, ẩn/hiện bài hát và cập nhật lời bài hát.
- **Quản lý Playlist:** Tạo, sửa, xóa, ẩn/hiện Playlist và gán bài hát vào Playlist.
- **Quản lý người dùng:** Tìm kiếm tài khoản, khóa hoặc mở khóa người dùng thường (không cho phép khóa tài khoản Admin).

---

## Công nghệ & Kiến trúc

- **Ngôn ngữ & Framework:** Flutter / Dart (đa nền tảng, kiểm thử chính trên Web/Chrome và Mobile)
- **Quản lý trạng thái:** `provider` (`ChangeNotifier`)
- **Backend & CSDL:** `supabase_flutter` (Supabase Auth, PostgreSQL, Row Level Security, RPC `record_play`, `admin_daily_plays`)
- **Phát âm thanh:** `just_audio`
- **Lưu trữ cục bộ:** `shared_preferences` (`PrefsStore` cho cài đặt/Onboarding, `LocalCacheStore` cho cache JSON)
- **Kiến trúc:** Phân tầng (`Presentation → Provider → Service / Repository → Data Access → Model`)

---

## Cấu trúc thư mục

```text
2026_2027_1_1_LTTBDD_N02_Nhom_10-main/
├── README.md
└── app_spostify/
    ├── assets/                  # Ảnh minh họa Onboarding & tài nguyên
    ├── database/                # Script khởi tạo CSDL Supabase
    │   ├── schema.sql           # Bảng, trigger, hàm RPC
    │   ├── policies.sql         # Chính sách Row Level Security (RLS)
    │   ├── seed.sql             # Dữ liệu mẫu thể loại, bài hát, playlist
    │   └── sample_accounts.sql  # Tài khoản mẫu để kiểm thử
    ├── lib/
    │   ├── core/                # Theme sáng/tối, đa ngôn ngữ (vi/en), validators
    │   ├── data/
    │   │   ├── local/           # PrefsStore, LocalCacheStore
    │   │   ├── remote/          # AppSupabase, AuthRemote
    │   │   └── repositories/    # Auth, Song, Playlist, History, User, Stats
    │   ├── features/
    │   │   ├── onboarding/      # OnboardingScreen
    │   │   ├── auth/            # LoginScreen, RegisterScreen
    │   │   ├── user/            # UserShell, Home, Explore, Library, Player, Profile, Settings
    │   │   └── admin/           # AdminShell, Dashboard, Song/Playlist/User Manager
    │   ├── models/              # AppUser, Song, Playlist, Genre
    │   ├── providers/           # 8 ChangeNotifier providers
    │   ├── services/            # AudioService (just_audio)
    │   └── widgets/             # MiniPlayer, SongTile, CoverArt, ConfirmDialog...
    ├── test/                    # 17 unit tests (validators, repository, provider)
    ├── env.example.json         # Mẫu cấu hình khóa Supabase
    └── pubspec.yaml
```

---

## Hướng dẫn cài đặt và chạy dự án

### 1. Thiết lập Supabase (chỉ làm một lần)
1. Tạo project mới tại [supabase.com](https://supabase.com).
2. Mở **SQL Editor** và chạy lần lượt các tệp trong thư mục `app_spostify/database/`:
   `schema.sql` → `policies.sql` → `seed.sql` (có thể chạy thêm `sample_accounts.sql` nếu cần tài khoản mẫu).
3. Tạo tài khoản quản trị trong **Authentication → Users → Add user** (chọn *Auto Confirm User*), sau đó cấp quyền Admin bằng SQL:
   ```sql
   update public.profiles
   set role = 'admin'
   where email = 'admin@giaidieu.vn';
   ```
4. *(Tùy chọn)* Tắt **Confirm email** tại **Authentication → Providers → Email** để tài khoản mới đăng ký có thể vào thẳng ứng dụng.

> **Lưu ý:** Tài khoản tạo **trước** khi chạy `schema.sql` sẽ chưa có bản ghi trong `profiles` — hãy xóa và đăng ký lại.

### 2. Cấu hình biến môi trường
Tại thư mục `app_spostify/`, sao chép tệp `env.example.json` thành `env.json` và điền thông tin từ **Project Settings → API** trên Supabase:

```json
{
  "SUPABASE_URL": "https://xxxx.supabase.co",
  "SUPABASE_ANON_KEY": "sb_publishable_..."
}
```

*(Tệp `env.json` đã được đưa vào `.gitignore`; không sử dụng `service_role` key trong mã nguồn ứng dụng).*

### 3. Cài đặt thư viện và chạy ứng dụng
```bash
cd app_spostify
flutter pub get
flutter run -d chrome --dart-define-from-file=env.json
```

---

## Kiểm thử mã nguồn

Chạy phân tích tĩnh và toàn bộ 17 ca kiểm thử đơn vị tại thư mục `app_spostify/`:

```bash
flutter analyze
flutter test
```
