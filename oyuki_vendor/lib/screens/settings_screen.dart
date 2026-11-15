import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'analytics_screen.dart';
import 'store_profile_screen.dart';
import 'support_screen.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onBack;
  const SettingsScreen({super.key, required this.onBack});

  Future<void> _logout(BuildContext context) async {
    final ok = await confirmDialog(
      context,
      title: 'Log out',
      message: 'Are you sure you want to log out of your account?',
      confirmLabel: 'Log out',
      danger: false,
    );
    if (!ok || !context.mounted) return;
    final state = AppScope.read(context);
    Navigator.of(context).popUntil((r) => r.isFirst);
    await state.logout();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final p = s.profile;

    Widget row(IconData icon, String label, {Widget? trailing, VoidCallback? onTap, double fontSize = 16}) {
      return InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: TextStyle(fontSize: fontSize))),
              trailing ??
                  const Icon(Icons.chevron_right, color: AppColors.primary, size: 28),
            ],
          ),
        ),
      );
    }

    const line = Divider(height: 1, thickness: 1, color: Color(0xFF9AA0A6));

    Widget header(String t) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        );

    return Scaffold(
      appBar: AppBar(
        leading: BackChevron(onPressed: onBack),
        title: const Text('SETTINGS'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                ClipOval(
                  child: PhotoView(
                    path: p.imagePath,
                    width: 70,
                    height: 70,
                    radius: 0,
                    placeholder: Icons.storefront_outlined,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Color(0xFFFFE066)),
                          const SizedBox(width: 4),
                          Text(p.rating.toStringAsFixed(1)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          header('Account'),
          line,
          row(Icons.storefront_outlined, 'Store Profile',
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StoreProfileScreen()))),
          line,
          header('Business'),
          line,
          row(
            Icons.door_front_door_outlined,
            p.isOpen ? 'Store status · Open' : 'Store status · Closed',
            fontSize: 14,
            trailing: Switch(
              value: p.isOpen,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primary,
              onChanged: (v) async {
                await s.setStoreOpen(v);
                if (context.mounted) {
                  toast(context, v ? 'Your store is now open' : 'Your store is now closed');
                }
              },
            ),
            onTap: () => s.setStoreOpen(!p.isOpen),
          ),
          line,
          row(Icons.bar_chart, 'Analytics',
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const AnalyticsScreen()))),
          line,
          row(Icons.headset_mic_outlined, 'Support',
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const SupportScreen()))),
          line,
          row(Icons.logout, 'Log out', onTap: () => _logout(context)),
          line,
        ],
      ),
    );
  }
}
