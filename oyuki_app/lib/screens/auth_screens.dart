import 'package:flutter/material.dart';
import 'package:oyuki_vendor/screens/login_screen.dart' as vendor_login;
import 'package:oyuki_vendor/screens/shell.dart' as vendor_shell;
import 'package:oyuki_vendor/state/app_scope.dart' as vendor_scope;
import 'package:oyuki_vendor/state/app_state.dart' as vendor_state;
import 'package:oyuki_vendor/theme.dart' as vendor_theme;
import '../theme.dart';
import '../user_session.dart';
import '../widgets/common.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

class _AuthScaffold extends StatelessWidget {
  final List<Widget> children;
  final Widget? footer;
  final bool showBack;
  const _AuthScaffold({required this.children, this.footer, this.showBack = false});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    if (showBack) ...[
                      const SizedBox(height: 8),
                      const Align(alignment: Alignment.centerLeft, child: BackArrow()),
                    ],
                    const SizedBox(height: 24),
                    const OyukiLogo(),
                    const SizedBox(height: 16),
                    ...children,
                  ],
                ),
              ),
              if (footer != null) Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: footer),
            ],
          ),
        ),
      );
}

class _VendorAuthGate extends StatelessWidget {
  const _VendorAuthGate();

  @override
  Widget build(BuildContext context) {
    final state = vendor_scope.AppScope.of(context);
    return state.loggedIn ? const vendor_shell.Shell() : const vendor_login.LoginScreen();
  }
}

class VendorRouteScreen extends StatefulWidget {
  const VendorRouteScreen({super.key});

  @override
  State<VendorRouteScreen> createState() => _VendorRouteScreenState();
}

class _VendorRouteScreenState extends State<VendorRouteScreen> {
  late final Future<vendor_state.AppState> _vendorState;

  @override
  void initState() {
    super.initState();
    _vendorState = vendor_state.AppState.load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<vendor_state.AppState>(
      future: _vendorState,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final state = snapshot.data!;
        return vendor_scope.AppScope(
          state: state,
          child: MaterialApp(
            title: 'Oyuki Vendor',
            debugShowCheckedModeBanner: false,
            theme: vendor_theme.buildTheme(),
            home: const _VendorAuthGate(),
          ),
        );
      },
    );
  }
}

void _openVendorSide(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const VendorRouteScreen()),
  );
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _AuthScaffold(
        footer: AuthFooter(
            line1Plain: 'Already have an account? ', link1: 'Log in', onLink1: () => Navigator.pushReplacementNamed(context, '/login')),
        children: [
          Text('Create Account', style: poppins(size: 26, weight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 6),
          Text('Join us today. Enter your details below to set up your profile',
              style: poppins(size: 14, color: AppColors.grey)),
          const SizedBox(height: 24),
          AppTextField(
              label: 'FULL NAME',
              hint: 'John Doe',
              controller: _nameController),
          const SizedBox(height: 16),
          AppTextField(
              label: 'EMAIL ADDRESS',
              hint: 'johndoe1819@gmail.com',
              controller: _emailController),
          const SizedBox(height: 16),
          AppTextField(
            label: 'PASSWORD',
            hint: '************',
            obscure: true,
            showEye: true,
            controller: _passwordController,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'CONFIRM PASSWORD',
            hint: '************',
            obscure: true,
            showEye: true,
            controller: _confirmPasswordController,
          ),
          const SizedBox(height: 16),
          const AppTextField(label: 'REFERRAL CODE', hint: 'rey735#'),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _openVendorSide(context),
            child: Text(
              'Want to sell on Oyuki? Click here',
              style: poppins(size: 14, weight: FontWeight.w600, color: AppColors.green),
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            text: 'Sign Up',
            onTap: () {
              _register();
            },
          ),
        ],
      );

  Future<void> _register() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showError('Enter your name, email, and password.');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match.');
      return;
    }

    try {
      await AuthService.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } on ApiException catch (error) {
      _showError(error.message);
    } catch (error) {
      _showError(ApiClient.connectionError(error));
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_usernameController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showError('Enter your username and password.');
      return;
    }

    try {
      await AuthService.login(
        identifier: _usernameController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } on ApiException catch (error) {
      _showError(error.message);
    } catch (error) {
      _showError(ApiClient.connectionError(error));
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) => _AuthScaffold(
        footer: AuthFooter(
            line1Plain: "Don't have an account? ",
            link1: 'Create account',
            onLink1: () => Navigator.pushReplacementNamed(context, '/signup')),
        children: [
          Text('Sign In', style: poppins(size: 26, weight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 6),
          Text('Log in to your existing account', style: poppins(size: 14, color: AppColors.grey)),
          const SizedBox(height: 24),
          AppTextField(
            label: 'USERNAME OR EMAIL',
            hint: 'johndoe1819@gmail.com',
            controller: _usernameController,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'PASSWORD',
            hint: '************',
            obscure: true,
            showEye: true,
            controller: _passwordController,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/forgot'),
            child: Text('Forgot password', style: poppins(size: 13, weight: FontWeight.w600, color: AppColors.green)),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _openVendorSide(context),
            child: Text(
              'Want to sell on Oyuki? Click here',
              style: poppins(size: 14, weight: FontWeight.w600, color: AppColors.green),
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(text: 'Log In', onTap: _login),
        ],
      );
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) => _AuthScaffold(
        showBack: true,
        children: [
          Text('Forgot your password?', style: poppins(size: 26, weight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 6),
          Text('Enter email address or phone number linked to your account',
              style: poppins(size: 14, color: AppColors.grey)),
          const SizedBox(height: 20),
          const AppTextField(label: 'Email or phone number', hint: '', smallLabel: true),
          const SizedBox(height: 24),
          PrimaryButton(text: 'Send code', onTap: () => Navigator.pushNamed(context, '/otp-forgot')),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text('Back to login', style: poppins(size: 14, weight: FontWeight.w600, color: AppColors.green)),
            ),
          ),
        ],
      );
}

class OtpForgotScreen extends StatelessWidget {
  const OtpForgotScreen({super.key});
  @override
  Widget build(BuildContext context) => _AuthScaffold(
        showBack: true,
        children: [
          Text('Forgot your password?', style: poppins(size: 26, weight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 6),
          Text('Enter reset code sent to email or phone number', style: poppins(size: 14, color: AppColors.grey)),
          const SizedBox(height: 24),
          const OtpBoxes(),
          const SizedBox(height: 20),
          Text('Resend code', style: poppins(size: 14, weight: FontWeight.w600, color: AppColors.green)),
          const SizedBox(height: 24),
          PrimaryButton(text: 'Verify', onTap: () => Navigator.pushNamed(context, '/reset')),
        ],
      );
}

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) => _AuthScaffold(
        showBack: true,
        children: [
          Text('Reset password', style: poppins(size: 26, weight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 6),
          Text('Enter six-digit code sent to reset password', style: poppins(size: 14, color: AppColors.grey)),
          const SizedBox(height: 20),
          const AppTextField(label: 'NEW PASSWORD', hint: '************', obscure: true, showEye: true),
          const SizedBox(height: 16),
          const AppTextField(label: 'CONFIRM PASSWORD', hint: '************', obscure: true, showEye: true),
          const SizedBox(height: 28),
          PrimaryButton(text: 'Reset password', onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false)),
        ],
      );
}

class OtpSignUpScreen extends StatefulWidget {
  final bool filled;
  final int? userId;
  const OtpSignUpScreen({
    super.key,
    this.filled = false,
    this.userId,
  });

  @override
  State<OtpSignUpScreen> createState() => _OtpSignUpScreenState();
}

class _OtpSignUpScreenState extends State<OtpSignUpScreen> {
  late final TextEditingController _otpController;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_otpController.text.trim().isEmpty) {
      _showError('Enter the 6-digit verification code.');
      return;
    }

    try {
      await ApiClient.post('/auth/verify/', body: {
        'email': UserSession.email,
        'otp': _otpController.text.trim(),
      }, authenticated: true);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } on ApiException catch (error) {
      _showError(error.message);
    } catch (error) {
      _showError(ApiClient.connectionError(error));
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) => _AuthScaffold(
        showBack: true,
        children: [
          Text('OTP Verification', style: poppins(size: 26, weight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: poppins(size: 14, color: AppColors.grey),
              children: [
                const TextSpan(text: 'We sent a six-digit code to\n'),
                TextSpan(
                  text: UserSession.email,
                  style: poppins(
                    size: 14,
                    weight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              labelText: '6-digit code',
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 20),
          Text(widget.filled ? 'Resend code' : 'Resend code in 30s',
              style: widget.filled
                  ? poppins(size: 14, weight: FontWeight.w600, color: AppColors.green)
                  : poppins(size: 14, color: AppColors.grey)),
          const SizedBox(height: 8),
          Text('Already have an account? Log in',
              style: poppins(size: 14, weight: FontWeight.w600, color: AppColors.green)),
          const SizedBox(height: 24),
          PrimaryButton(text: 'Verify and continue', onTap: _verify),
        ],
      );
}

class RolePickerScreen extends StatelessWidget {
  const RolePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      children: [
        Text(
          'Continue as',
          style: poppins(size: 26, weight: FontWeight.w700, color: AppColors.text),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the side you want to access',
          style: poppins(size: 14, color: AppColors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Buyer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _openVendorSide(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.green,
              side: const BorderSide(color: AppColors.green),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Seller', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}