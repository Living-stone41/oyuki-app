import 'package:flutter/material.dart';
import '../theme.dart';
import 'main_shell.dart';

class TwoFaEnabledScreen extends StatelessWidget {
  const TwoFaEnabledScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.green, width: 3),
                ),
                child: const Icon(Icons.check, color: AppColors.green, size: 36),
              ),
              const SizedBox(height: 28),
              const Text('2-Factor authentication enabled',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              const Text(
                'Your account is now protected with an extra layer of security. You will be required to enter a 6-digit code from your authenticator app when logging in.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.grey, height: 1.5),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainShell()),
                    (route) => false,
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Continue to dashboard',
                        style: TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.w600)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios,
                        color: AppColors.green, size: 14),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
