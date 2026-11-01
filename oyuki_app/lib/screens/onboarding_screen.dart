import 'dart:async';

import 'package:flutter/material.dart';
import '../theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _word = 'Oyuki';
  int _visibleLetters = 0;
  Timer? _letterTimer;

  @override
  void initState() {
    super.initState();
    _letterTimer = Timer.periodic(const Duration(milliseconds: 220), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _visibleLetters++);
      if (_visibleLetters == _word.length) {
        timer.cancel();
        Timer(const Duration(milliseconds: 900), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/get-started');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _letterTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green,
      body: Center(
        child: Text(
          _word.substring(0, _visibleLetters.clamp(0, _word.length)),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 52,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 36),
          child: Column(
            children: [
              const Spacer(),
              const CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.navActive,
                child: Icon(
                  Icons.shopping_basket_outlined,
                  color: AppColors.green,
                  size: 48,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Fresh goods, delivered to you',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Shop fresh kitchen foods and farm produce from trusted sellers on Oyuki.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Get started',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/signup'),
                child: const Text(
                  'Create an account',
                  style: TextStyle(color: AppColors.green),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
