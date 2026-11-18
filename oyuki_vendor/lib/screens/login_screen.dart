import 'package:flutter/material.dart';

import '../services/vendor_api.dart';
import '../state/app_scope.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _email;
  final _password = TextEditingController();
  bool _obscure = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: AppScope.read(context).profile.email);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, {Widget? suffix}) => InputDecoration(
        labelText: label,
        suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      final result = await VendorApi.post('/auth/login/', body: {
        'identifier': _email.text.trim(),
        'password': _password.text,
      });

      final user = result['user'];
      if (user is Map && user['role'] != 'vendor') {
        throw VendorApiException('This account is not registered as a vendor.');
      }

      final access = result['access']?.toString() ?? '';
      final refresh = result['refresh']?.toString() ?? '';
      if (access.isEmpty) {
        throw VendorApiException('The server did not return an access token.');
      }

      await VendorApi.saveSession(access, refresh);
      if (!mounted) return;
      final state = AppScope.read(context);
      await state.login(_email.text.trim(), remote: true);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Shell()),
      );
    } on VendorApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to connect to the backend.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.storefront_outlined,
                          color: Colors.white, size: 38),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Oyuki Vendor',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  const Text('Sign in to manage your store',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted, fontSize: 15)),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: _dec('Email'),
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return 'Enter your email';
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    autofillHints: const [AutofillHints.password],
                    decoration: _dec(
                      'Password',
                      suffix: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => (v ?? '').length < 6
                        ? 'Password must be at least 6 characters'
                        : null,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(label: 'Sign in', onPressed: _submit, busy: _busy),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
