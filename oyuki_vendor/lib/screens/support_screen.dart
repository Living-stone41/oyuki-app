import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../theme.dart';
import '../widgets/common.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _open(BuildContext context, Uri uri) async {
    var ok = false;
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!ok && context.mounted) toast(context, 'Could not open that on this device');
  }

  @override
  Widget build(BuildContext context) {
    Widget tile(IconData icon, String title, String subtitle, Uri uri) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: cardDecoration(),
          child: ListTile(
            leading: Icon(icon, color: AppColors.primary),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
            onTap: () => _open(context, uri),
          ),
        );

    const faqs = [
      (
        'How do I accept or reject an order?',
        'Open the Order tab, then tap Accept order or Reject order on any pending order. You can also open an order to see full details first.'
      ),
      (
        'How do I add or edit menu items?',
        'Go to the Menu tab and tap the + button. To change or remove an item, tap the ⋯ menu beside it.'
      ),
      (
        'How do I stop receiving orders?',
        'In Settings, switch off Store status. Switch it back on when you are ready to take orders again.'
      ),
      (
        'Where can I see my sales?',
        'Settings › Analytics shows your revenue, a sales chart and your top selling products.'
      ),
    ];

    return Scaffold(
      appBar: AppBar(leading: const BackChevron(), title: const Text('SUPPORT')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Contact us',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          tile(Icons.phone_outlined, 'Call support', supportPhone,
              Uri(scheme: 'tel', path: supportPhone)),
          tile(Icons.email_outlined, 'Email us', supportEmail,
              Uri(scheme: 'mailto', path: supportEmail, query: 'subject=Vendor%20support')),
          tile(Icons.chat_outlined, 'WhatsApp', 'Chat with our team',
              Uri.parse('https://wa.me/$supportWhatsapp')),
          const SizedBox(height: 16),
          const Text('Frequently asked',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (final f in faqs)
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 12),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                iconColor: AppColors.primary,
                title: Text(f.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
                children: [Text(f.$2, style: const TextStyle(color: AppColors.muted))],
              ),
            ),
        ],
      ),
    );
  }
}
