import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNav(currentIndex: 3),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            Row(
              children: [
                BackArrow(
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/home'),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'WALLET',
                      style: poppins(
                        size: 16,
                        weight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 30),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available balance',
                    style: poppins(size: 14, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₦0.00',
                    style: poppins(
                      size: 30,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                          ),
                          child: const Text('Deposit'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                          ),
                          child: const Text('Withdraw'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Recent transactions',
              style: poppins(
                size: 18,
                weight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'No transactions yet',
                style: poppins(size: 14, color: AppColors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
