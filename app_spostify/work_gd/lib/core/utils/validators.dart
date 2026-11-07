/// Các hàm kiểm tra dữ liệu đầu vào dùng chung cho form.
class Validators {
  Validators._();

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Vui lòng nhập email.';
    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
    if (!emailPattern.hasMatch(email)) return 'Email không đúng định dạng.';
    return null;
  }

  static String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Vui lòng nhập mật khẩu.';
    if (password.length < 6) return 'Mật khẩu cần ít nhất 6 ký tự.';
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if ((value ?? '').isEmpty) return 'Vui lòng xác nhận mật khẩu.';
    if (value != password) return 'Mật khẩu xác nhận không khớp.';
    return null;
  }

  static String? validateDisplayName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Vui lòng nhập họ tên.';
    if (name.length > 60) return 'Họ tên không được vượt quá 60 ký tự.';
    return null;
  }
}
