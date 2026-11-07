import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.infoMessage ?? 'Đăng ký thành công.')));
      if (auth.isAuthenticated) Navigator.of(context).pop();
    } else if (auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
                  child: Form(
                    key: _formKey,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Align(alignment: Alignment.centerLeft, child: IconButton(onPressed: () => Navigator.of(context).maybePop(), icon: const Icon(Icons.arrow_back_rounded), tooltip: 'Quay lại')),
                      const SizedBox(height: 15),
                      Container(width: 46, height: 46, decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.graphic_eq_rounded, color: AppTheme.darkBackground, size: 29)),
                      const SizedBox(height: 25),
                      Text('Tạo tài khoản', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -.5)),
                      const SizedBox(height: 6),
                      Text('Mất chưa tới một phút', style: TextStyle(color: Colors.white.withValues(alpha: .62))),
                      const SizedBox(height: 28),
                      _caption('Tên hiển thị'), const SizedBox(height: 7),
                      TextFormField(controller: _nameController, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(hintText: 'Tên của bạn', prefixIcon: Icon(Icons.person_outline_rounded)), validator: Validators.validateDisplayName),
                      const SizedBox(height: 17),
                      _caption('Email'), const SizedBox(height: 7),
                      TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'name@company.com', prefixIcon: Icon(Icons.mail_outline_rounded)), validator: Validators.validateEmail),
                      const SizedBox(height: 17),
                      _caption('Mật khẩu'), const SizedBox(height: 7),
                      TextFormField(controller: _passwordController, obscureText: _obscurePassword, decoration: InputDecoration(hintText: 'Ít nhất 6 ký tự', prefixIcon: const Icon(Icons.lock_outline_rounded), suffixIcon: IconButton(onPressed: () => setState(() => _obscurePassword = !_obscurePassword), icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined))), validator: Validators.validatePassword),
                      const SizedBox(height: 17),
                      _caption('Nhập lại mật khẩu'), const SizedBox(height: 7),
                      TextFormField(controller: _confirmController, obscureText: _obscureConfirm, decoration: InputDecoration(hintText: 'Xác nhận mật khẩu', prefixIcon: const Icon(Icons.lock_reset_rounded), suffixIcon: IconButton(onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm), icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined))), validator: (value) => Validators.validateConfirmPassword(value, _passwordController.text)),
                      const SizedBox(height: 25),
                      SizedBox(height: 50, child: ElevatedButton(onPressed: auth.isLoading ? null : _submit, child: auth.isLoading ? const SizedBox(width: 21, height: 21, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.darkBackground)) : const Text('ĐĂNG KÝ'))),
                      const SizedBox(height: 20),
                      Wrap(alignment: WrapAlignment.center, children: [Text('Đã có tài khoản? ', style: TextStyle(color: Colors.white.withValues(alpha: .65))), GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Text('Đăng nhập', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w700)))]),
                    ]),
                  ),
                ),
              ),
              Padding(padding: const EdgeInsets.only(bottom: 18), child: Text('GIAI ĐIỆU  •  ÂM NHẠC KẾT NỐI CẢM XÚC', style: TextStyle(color: Colors.white.withValues(alpha: .35), fontSize: 10, letterSpacing: 1.1))),
            ]),
          ),
        ),
      ),
    );
  }

  static Widget _caption(String text) => Text(text, style: TextStyle(color: Colors.white.withValues(alpha: .72), fontSize: 13, fontWeight: FontWeight.w500));
}
