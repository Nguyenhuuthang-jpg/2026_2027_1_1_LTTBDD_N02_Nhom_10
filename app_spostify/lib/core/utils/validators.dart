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

  static String? validateSongInput({
    required String title,
    required String artist,
    required int durationSeconds,
  }) {
    if (title.trim().isEmpty) return 'Tên bài hát không được để trống.';
    if (title.trim().length > 60) return 'Tên bài hát tối đa 60 ký tự.';
    if (artist.trim().isEmpty) return 'Tên nghệ sĩ không được để trống.';
    if (artist.trim().length > 40) return 'Tên nghệ sĩ tối đa 40 ký tự.';
    if (durationSeconds <= 0) return 'Thời lượng phải lớn hơn 0.';
    return null;
  }

  static String? validatePlaylistName(String name) {
    final n = name.trim();
    if (n.isEmpty || n.length > 60) {
      return 'Tên playlist phải có từ 1 đến 60 ký tự.';
    }
    return null;
  }
}
