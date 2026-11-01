import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../user_session.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  String get refCode {
    final identifier = UserSession.email.isEmpty
        ? UserSession.fullName
        : UserSession.email;
    final suffix = identifier.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return 'ref-${suffix.isEmpty ? 'oyukiuser' : suffix.toLowerCase()}';
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        final contacts = ['Andrew', 'Bishop', 'Oladele', 'Joy', 'Osinachi'];
        final colors = [
          Colors.orange[100]!,
          Colors.green[200]!,
          Colors.purple[100]!,
          Colors.blue[100]!,
          Colors.indigo[200]!
        ];
        final shareItems = [
          (Icons.link, 'Copy link'),
          (Icons.send_outlined, 'Telegram'),
          (Icons.chat_bubble_outline, 'WhatsApp'),
          (Icons.close, 'Twitter/X'),
          (Icons.chat_outlined, 'Message'),
        ];
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: shareItems.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 22),
                  itemBuilder: (_, i) => _ShareOption(
                      icon: shareItems[i].$1, label: shareItems[i].$2),
                ),
              ),
              const Divider(height: 32),
              SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: contacts.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 20),
                  itemBuilder: (_, i) => Column(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: colors[i],
                        child: Icon(Icons.person, color: Colors.grey[800]),
                      ),
                      const SizedBox(height: 6),
                      Text(contacts[i], style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, color: AppColors.green, size: 20),
        ),
        title: const Text('Referral'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text('Refer Friends, Earn\ntogether',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.2)),
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                style: const TextStyle(color: AppColors.grey, height: 1.5),
                children: [
                  const TextSpan(text: 'Invite a friend and earn '),
                  _green('₦1,000 on their first order'),
                  _green(', ₦500 on their second order'),
                  const TextSpan(text: '. Friend earns '),
                  _green('₦500'),
                  const TextSpan(text: ' on their first order'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(refCode,
                        style: const TextStyle(color: AppColors.grey, fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 10),
                _SquareBtn(
                  icon: Icons.copy_outlined,
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: refCode));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Referral code copied')),
                      );
                    }
                  },
                ),
                const SizedBox(width: 8),
                _SquareBtn(icon: Icons.share_outlined, onTap: () => _showShareSheet(context)),
              ],
            ),
            const SizedBox(height: 36),
            const Text('Referral history',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total referral',
                          style: TextStyle(color: AppColors.grey, fontSize: 13)),
                      SizedBox(height: 6),
                      Text('0',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total earned',
                          style: TextStyle(color: AppColors.grey, fontSize: 13)),
                      SizedBox(height: 6),
                      Text('₦0',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TextSpan _green(String t) => TextSpan(
      text: t, style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w600));
}

class _SquareBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SquareBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: icon == Icons.share_outlined ? Colors.white : AppColors.green,
          border: Border.all(color: AppColors.green),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size: 20,
            color: icon == Icons.share_outlined ? AppColors.green : Colors.white),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ShareOption({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.text, width: 1.2)),
          child: Icon(icon, size: 22),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
