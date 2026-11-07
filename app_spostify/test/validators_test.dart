import 'package:flutter_test/flutter_test.dart';
import 'package:app_spostify/core/utils/validators.dart';

void main() {
  group('Validators.validateEmail', () {
    test('chấp nhận email hợp lệ', () {
      expect(Validators.validateEmail('user@example.com'), isNull);
    });

    test('từ chối email rỗng hoặc sai định dạng', () {
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail('abc'), isNotNull);
    });
  });

  group('Validators.validatePassword', () {
    test('yêu cầu mật khẩu tối thiểu 6 ký tự theo bản demo', () {
      expect(Validators.validatePassword('123456'), isNull);
      expect(Validators.validatePassword('12345'), isNotNull);
    });
  });

  test('xác nhận mật khẩu phải trùng khớp', () {
    expect(Validators.validateConfirmPassword('abc12345', 'abc12345'), isNull);
    expect(Validators.validateConfirmPassword('wrong', 'abc12345'), isNotNull);
  });

  test('tên hiển thị bắt buộc và tối đa 60 ký tự', () {
    expect(Validators.validateDisplayName('Nguyen Van A'), isNull);
    expect(Validators.validateDisplayName(' '), isNotNull);
    expect(Validators.validateDisplayName(List.filled(61, 'a').join()), isNotNull);
  });
}
