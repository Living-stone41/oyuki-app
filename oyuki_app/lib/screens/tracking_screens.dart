import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  static const steps = [
    ('Order Received', null, true),
    ('Vendor Processing', 'Order packing in process . 12:30pm', true),
    ('Order received by rider', 'Rider heading to vendors destination . 12:45pm', true),
    ('Rider in transit', 'Rider bound to delivery destination . 1:05pm', true),
    ('Rider arrived at destination', 'Confirm package delivery', false),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: const BottomNav(currentIndex: 2),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              Row(
                children: [
                  const BackArrow(),
                  Expanded(
                    child: Center(child: Text('ORDER TRACKING', style: poppins(size: 16, weight: FontWeight.w700, color: AppColors.text))),
                  ),
                  const SizedBox(width: 30),
                ],
              ),
              const SizedBox(height: 14),
              const TrackingToggle(isSummary: true),
              const SizedBox(height: 24),
              Text('Your order is on the way!', style: poppins(size: 21, weight: FontWeight.w700, color: AppColors.text)),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: poppins(size: 15, color: AppColors.text),
                  children: [
                    TextSpan(text: 'Estimated arrival: ', style: poppins(size: 15, weight: FontWeight.w600, color: AppColors.text)),
                    TextSpan(text: '45min', style: poppins(size: 15, weight: FontWeight.w700, color: AppColors.green)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text('Tracking ID: ', style: poppins(size: 13, color: AppColors.grey)),
                  Text('#1598673B', style: poppins(size: 13, weight: FontWeight.w600, color: AppColors.text)),
                  const SizedBox(width: 4),
                  const Icon(Icons.copy, size: 15, color: AppColors.grey),
                  const SizedBox(width: 12),
                  Text('Store: ', style: poppins(size: 13, color: AppColors.grey)),
                  Text("John's Farmhouse", style: poppins(size: 13, weight: FontWeight.w600, color: AppColors.text)),
                ],
              ),
              const SizedBox(height: 26),
              for (var i = 0; i < steps.length; i++) _TimelineStep(steps[i], i),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(radius: 24, backgroundColor: Color(0xFF5A5A5A)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Adetunji Adewale', style: poppins(size: 15, weight: FontWeight.w600, color: AppColors.text)),
                            Row(
                              children: [
                                const Icon(Icons.star, color: AppColors.gold, size: 14),
                                const SizedBox(width: 4),
                                Text('4.0', style: poppins(size: 13, weight: FontWeight.w600, color: AppColors.text)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 42,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.white),
                              label: Text('Message', style: poppins(size: 14, weight: FontWeight.w600, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.green,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 42,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.phone_outlined, size: 16, color: Colors.white),
                              label: Text('Call', style: poppins(size: 14, weight: FontWeight.w600, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.green,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _TimelineStep extends StatelessWidget {
  final (String, String?, bool) step;
  final int index;
  const _TimelineStep(this.step, this.index);
  @override
  Widget build(BuildContext context) {
    final done = step.$3;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: done ? AppColors.green : const Color(0xFFD9D9D9),
                  shape: BoxShape.circle,
                ),
              ),
              if (index < 4)
                Expanded(
                  child: Container(width: 2, color: done ? AppColors.green : const Color(0xFFE3E3E3)),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.$1,
                      style: poppins(size: 14,
                          weight: FontWeight.w600,
                          color: done ? AppColors.text : AppColors.grey)),
                  if (step.$2 != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(step.$2!, style: poppins(size: 12, color: AppColors.grey)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LiveTrackingScreen extends StatelessWidget {
  const LiveTrackingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 24, 0),
                child: Row(
                  children: [
                    const BackArrow(),
                    Expanded(
                      child: Center(child: Text('ORDER TRACKING', style: poppins(size: 16, weight: FontWeight.w700, color: AppColors.text))),
                    ),
                    const SizedBox(width: 30),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: TrackingToggle(isSummary: false)),
              const SizedBox(height: 14),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset('assets/images/oyuki_assets/map.png', fit: BoxFit.cover),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rider is on the way', style: poppins(size: 19, weight: FontWeight.w700, color: AppColors.text)),
                            const SizedBox(height: 6),
                            RichText(
                              text: TextSpan(
                                style: poppins(size: 13, color: AppColors.text),
                                children: [
                                  const TextSpan(text: 'Estimated arrival: '),
                                  TextSpan(text: '15:45pm', style: poppins(size: 13, weight: FontWeight.w700, color: AppColors.green)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _outlineAction(Icons.phone_outlined, 'Call'),
                                const SizedBox(width: 10),
                                _outlineAction(Icons.chat_bubble_outline, 'Message'),
                                const SizedBox(width: 10),
                                _outlineAction(Icons.headset_mic_outlined, 'Support'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _outlineAction(IconData icon, String label) => Expanded(
        child: SizedBox(
          height: 40,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(icon, size: 15, color: AppColors.green),
            label: Text(label, style: poppins(size: 13, weight: FontWeight.w600, color: AppColors.green)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.green),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      );
}