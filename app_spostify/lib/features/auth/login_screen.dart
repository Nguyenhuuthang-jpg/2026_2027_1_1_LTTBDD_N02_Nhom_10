import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (!success && auth.errorMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(auth.errorMessage!)));
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
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    // Banner tràn hết chiều ngang; phần form bên dưới có lề 22px.
                    padding: const EdgeInsets.only(bottom: 28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _MusicBanner(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 25),
                                const _BrandMark(),
                                const SizedBox(height: 24),
                                Text(
                                  context.tr('loginHeading'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -.5,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  context.tr('loginSubtitle'),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: .62),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 27),
                                _FieldCaption(context.tr('email')),
                                const SizedBox(height: 7),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],
                                  decoration: const InputDecoration(
                                    hintText: 'name@company.com',
                                    prefixIcon: Icon(
                                      Icons.mail_outline_rounded,
                                    ),
                                  ),
                                  validator: Validators.validateEmail,
                                ),
                                const SizedBox(height: 17),
                                _FieldCaption(context.tr('password')),
                                const SizedBox(height: 7),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  autofillHints: const [AutofillHints.password],
                                  decoration: InputDecoration(
                                    hintText: context.tr('passwordHint'),
                                    prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                    ),
                                  ),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? context.tr('passwordRequired')
                                      : null,
                                  onFieldSubmitted: (_) => _submit(),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: auth.isLoading ? null : _submit,
                                    child: auth.isLoading
                                        ? const SizedBox(
                                            width: 21,
                                            height: 21,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppTheme.darkBackground,
                                            ),
                                          )
                                        : Text(
                                            context.tr('login').toUpperCase(),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 19),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  children: [
                                    Text(
                                      context.tr('noAccount'),
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: .65,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) =>
                                              const RegisterScreen(),
                                        ),
                                      ),
                                      child: Text(
                                        context.tr('register'),
                                        style: const TextStyle(
                                          color: AppTheme.primaryGreen,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  context.tr('quickTry'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: .42),
                                    fontSize: 11.5,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(22, 8, 22, 18),
                  child: _LanguageToggle(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MusicBanner extends StatelessWidget {
  const _MusicBanner();
  @override
  Widget build(BuildContext context) => Container(
    height: 174,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF244D36), Color(0xFF14251B), Color(0xFF101412)],
      ),
    ),
    child: Stack(
      children: [
        Positioned(
          right: -12,
          top: 15,
          child: Icon(
            Icons.graphic_eq_rounded,
            size: 170,
            color: AppTheme.primaryGreen.withValues(alpha: .13),
          ),
        ),
        Positioned(
          left: 23,
          bottom: 23,
          child: Row(
            children: [
              _equalizer(12),
              const SizedBox(width: 4),
              _equalizer(25),
              const SizedBox(width: 4),
              _equalizer(17),
              const SizedBox(width: 4),
              _equalizer(31),
              const SizedBox(width: 4),
              _equalizer(14),
              const SizedBox(width: 13),
              const Text(
                'GIAI ĐIỆU',
                style: TextStyle(
                  letterSpacing: 3,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  static Widget _equalizer(double h) => Container(
    width: 4,
    height: h,
    decoration: BoxDecoration(
      color: AppTheme.primaryGreen,
      borderRadius: BorderRadius.circular(4),
    ),
  );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();
  @override
  Widget build(BuildContext context) => Container(
    width: 46,
    height: 46,
    decoration: BoxDecoration(
      color: AppTheme.primaryGreen,
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Icon(
      Icons.graphic_eq_rounded,
      color: AppTheme.darkBackground,
      size: 29,
    ),
  );
}

class _FieldCaption extends StatelessWidget {
  const _FieldCaption(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: Colors.white.withValues(alpha: .72),
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
  );
}

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle();
  @override
  Widget build(BuildContext context) {
    final isVi = context.watch<SettingsProvider>().isVietnamese;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => context.read<SettingsProvider>().setLanguage('vi'),
          child: Text(
            'Tiếng Việt',
            style: TextStyle(
              color: isVi
                  ? AppTheme.primaryGreen
                  : Colors.white.withValues(alpha: .55),
              fontWeight: isVi ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        Text('•', style: TextStyle(color: Colors.white.withValues(alpha: .35))),
        TextButton(
          onPressed: () => context.read<SettingsProvider>().setLanguage('en'),
          child: Text(
            'English',
            style: TextStyle(
              color: !isVi
                  ? AppTheme.primaryGreen
                  : Colors.white.withValues(alpha: .55),
              fontWeight: !isVi ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
