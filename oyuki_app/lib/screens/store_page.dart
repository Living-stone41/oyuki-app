import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class StorePage extends StatelessWidget {
  const StorePage({super.key});

  static const items = [
    ('Smoked Titus Fish', '8 pieces of smoked original titus fish', '₦3,000'),
    ('Fresh Spinach', '5kg freshly packaged spinach', '₦2,500'),
    ('Ofada Rice', 'One paint of ofada rice', '₦2,500'),
    ('Palm Oil', '2Litres of fresh palm oil', '₦2,500'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: const BottomNav(currentIndex: 0),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Stack(
                children: [
                  Image.asset('assets/images/oyuki_assets/store_banner.png', height: 160, width: double.infinity, fit: BoxFit.cover),
                  Positioned(
                    top: 8,
                    left: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 18,
                      child: BackArrow(onTap: () => Navigator.pop(context)),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
                  children: [
                    Row(
                      children: [
                        Text('James and Co. Farmhouse',
                            style: poppins(size: 18, weight: FontWeight.w700, color: AppColors.text)),
                        const SizedBox(width: 6),
                        const VerifiedBadge(),
                        const Spacer(),
                        const Icon(Icons.favorite_border, size: 22),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.gold, size: 16),
                        const SizedBox(width: 4),
                        Text('4.5/5 ', style: poppins(size: 13, weight: FontWeight.w600, color: AppColors.text)),
                        Text('(120)', style: poppins(size: 13, color: AppColors.grey)),
                        const SizedBox(width: 12),
                        const Icon(Icons.schedule, size: 15, color: AppColors.grey),
                        const SizedBox(width: 4),
                        Text('9am - 12am', style: poppins(size: 13, color: AppColors.grey)),
                        const SizedBox(width: 12),
                        const Icon(Icons.electric_bolt, size: 15, color: AppColors.grey),
                        const SizedBox(width: 4),
                        Text('19 - 24 min', style: poppins(size: 13, color: AppColors.grey)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final t in ['All', 'Vegetables', 'Grains', 'Roots and Tube'])
                            Padding(
                              padding: const EdgeInsets.only(right: 18),
                              child: t == 'All'
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(4)),
                                      child: Text(t, style: poppins(size: 14, weight: FontWeight.w600, color: Colors.white)),
                                    )
                                  : Text(t, style: poppins(size: 14, color: AppColors.grey)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final it in items) ...[
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/product'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(it.$1, style: poppins(size: 16, weight: FontWeight.w600, color: AppColors.text)),
                                    const SizedBox(height: 4),
                                    Text(it.$2, style: poppins(size: 13, color: AppColors.grey)),
                                    const SizedBox(height: 8),
                                    Text(it.$3, style: poppins(size: 16, weight: FontWeight.w700, color: AppColors.text)),
                                  ],
                                ),
                              ),
                              Container(
                                width: 130,
                                height: 92,
                                decoration: BoxDecoration(color: const Color(0xFFECECEC), borderRadius: BorderRadius.circular(8)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFEFEFEF)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}