import 'package:flutter/material.dart';
import '../theme.dart';
import '../user_session.dart';
import '../widgets/common.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const items = [
    ('cart1.png', 'Scotch Bonnet pepper', '10kg', '₦5,500'),
    ('cart2.png', 'Scotch Bonnet pepper', '20kg', '₦5,500'),
    ('cart3.png', 'Scotch Bonnet pepper', '23kg', '₦5,500'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: const BottomNav(currentIndex: 2),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 24, 0),
                child: Row(
                  children: [
                    const BackArrow(),
                    Expanded(
                      child: Center(child: Text('My Cart', style: poppins(size: 18, weight: FontWeight.w700, color: AppColors.text))),
                    ),
                    const SizedBox(width: 30),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  children: [
                    for (final it in items) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                              child: Image.asset('assets/images/oyuki_assets/${it.$1}', fit: BoxFit.contain),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(it.$2, style: poppins(size: 15, weight: FontWeight.w600, color: AppColors.text)),
                                  const SizedBox(height: 2),
                                  Text(it.$3, style: poppins(size: 12, color: AppColors.grey)),
                                  const SizedBox(height: 8),
                                  Text(it.$4, style: poppins(size: 15, weight: FontWeight.w700, color: AppColors.text)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Icon(Icons.delete_outline, color: AppColors.red, size: 20),
                                const SizedBox(height: 22),
                                Row(
                                  children: [
                                    const Icon(Icons.remove, color: AppColors.green, size: 20),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Text('1', style: poppins(size: 15, color: AppColors.text)),
                                    ),
                                    const Icon(Icons.add, color: AppColors.green, size: 20),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFEFEFEF)),
                    ],
                    const SizedBox(height: 20),
                    Text('Delivery Address', style: poppins(size: 17, weight: FontWeight.w700, color: AppColors.text)),
                    const SizedBox(height: 12),
                    _radioRow(
                      'Home',
                      UserSession.address.isEmpty
                          ? 'Add a delivery address in your profile'
                          : UserSession.address,
                      true,
                    ),
                    _radioRow('Work', 'Olanrewaju Street Allen Ikeja Lagos', false),
                    const SizedBox(height: 18),
                    Text('Payment Method', style: poppins(size: 17, weight: FontWeight.w700, color: AppColors.text)),
                    const SizedBox(height: 12),
                    _payRow(
                      Stack(
                        children: const [
                          Padding(padding: EdgeInsets.only(left: 8), child: CircleAvatar(radius: 8, backgroundColor: Color(0xFFF79E1B))),
                          CircleAvatar(radius: 8, backgroundColor: Color(0xFFEB001B)),
                        ],
                      ),
                      '****4398',
                      null,
                    ),
                    _payRow(const Icon(Icons.account_balance_wallet_outlined, color: AppColors.text, size: 22), '₦13,500', 'Oyuki Wallet'),
                    _payRow(const Icon(Icons.account_balance_outlined, color: AppColors.text, size: 22), 'Bank transfer', null),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _radioRow(String title, String subtitle, bool selected) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: poppins(size: 15, weight: FontWeight.w600, color: AppColors.text)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: poppins(size: 13, color: AppColors.grey)),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? AppColors.green : AppColors.border, width: 1.6),
                color: selected ? AppColors.green : Colors.transparent,
              ),
              child: selected ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
            ),
          ],
        ),
      );

  Widget _payRow(Widget icon, String title, String? subtitle) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: poppins(size: 15, weight: FontWeight.w500, color: AppColors.text)),
                  if (subtitle != null) Text(subtitle, style: poppins(size: 12, color: AppColors.grey)),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.border, width: 1.6)),
            ),
          ],
        ),
      );
}