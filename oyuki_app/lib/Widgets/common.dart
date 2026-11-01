import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

TextStyle poppins({double? size, FontWeight? weight, Color? color}) =>
    GoogleFonts.poppins(fontSize: size ?? 14, fontWeight: weight, color: color);

class OyukiLogo extends StatelessWidget {
  const OyukiLogo({super.key});
  @override
  Widget build(BuildContext context) =>
      Text('Oyuki', style: poppins(size: 28, weight: FontWeight.w700, color: AppColors.green));
}

class BackArrow extends StatelessWidget {
  final VoidCallback? onTap;
  final Color color;
  const BackArrow({super.key, this.onTap, this.color = AppColors.green});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap ?? () => Navigator.pop(context),
        child: Icon(Icons.chevron_left, color: color, size: 30),
      );
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final IconData? icon;
  const PrimaryButton({super.key, required this.text, this.onTap, this.icon});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 8)],
              Text(text, style: poppins(size: 16, weight: FontWeight.w600, color: Colors.white)),
            ],
          ),
        ),
      );
}

class AppTextField extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscure;
  final bool showEye;
  final bool smallLabel;
  final TextEditingController? controller;
  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.obscure = false,
    this.showEye = false,
    this.smallLabel = false,
    this.controller,
  });
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: smallLabel
                  ? poppins(size: 13, color: AppColors.grey)
                  : poppins(size: 12, weight: FontWeight.w600, color: AppColors.text)),
          const SizedBox(height: 6),
          SizedBox(
            height: 50,
            child: TextField(
              controller: controller,
              obscureText: obscure,
              style: poppins(size: 14, color: AppColors.text),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: poppins(size: 14, color: AppColors.hint),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.green)),
                suffixIcon: showEye ? const Icon(Icons.visibility_off_outlined, color: AppColors.green, size: 20) : null,
              ),
            ),
          ),
        ],
      );
}

class OtpBoxes extends StatelessWidget {
  final List<String> values;
  const OtpBoxes({super.key, this.values = const []});
  @override
  Widget build(BuildContext context) => Row(
        children: List.generate(
          6,
          (i) => Expanded(
            child: Container(
              height: 64,
              margin: EdgeInsets.only(right: i == 5 ? 0 : 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.green, width: 1.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                i < values.length ? values[i] : '',
                style: poppins(size: 24, weight: FontWeight.w600, color: AppColors.text),
              ),
            ),
          ),
        ),
      );
}

class AuthFooter extends StatelessWidget {
  final String line1Plain;
  final String link1;
  final VoidCallback? onLink1;
  const AuthFooter({super.key, required this.line1Plain, required this.link1, this.onLink1});
  @override
  Widget build(BuildContext context) => Column(
        children: [
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 14),
          _rich(line1Plain, link1, onLink1),
          const SizedBox(height: 6),
          _rich('Want to sell on oyuki? ', 'Join here', () {}),
          const SizedBox(height: 14),
        ],
      );
  Widget _rich(String plain, String link, VoidCallback? tap) => RichText(
        text: TextSpan(
          style: poppins(size: 14, color: AppColors.text),
          children: [
            TextSpan(text: plain),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: tap,
                child: Text(link,
                    style: poppins(
                        size: 14, weight: FontWeight.w700, color: AppColors.green,
                        ).copyWith(decoration: TextDecoration.underline, decorationColor: AppColors.green)),
              ),
            ),
          ],
        ),
      );
}

class SearchBarField extends StatelessWidget {
  final String hint;
  final String? initialValue;
  final bool showClear;
  final bool autofocus;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  const SearchBarField({
    super.key,
    required this.hint,
    this.initialValue,
    this.showClear = false,
    this.autofocus = false,
    this.onTap,
    this.onSubmitted,
  });
  @override
  Widget build(BuildContext context) => Container(
        height: 54,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.green, width: 1.4),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.green, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: initialValue,
                autofocus: autofocus,
                onTap: onTap,
                onFieldSubmitted: onSubmitted,
                style: poppins(size: 15, color: AppColors.text),
                decoration: InputDecoration(
                    hintText: hint, hintStyle: poppins(size: 15, color: AppColors.hint), border: InputBorder.none),
              ),
            ),
            if (showClear)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
          ],
        ),
      );
}

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: 18,
        height: 18,
        decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
        child: const Icon(Icons.check, color: Colors.white, size: 12),
      );
}

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const SectionHeader({super.key, required this.title, this.onSeeAll});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: poppins(size: 20, weight: FontWeight.w700, color: AppColors.text)),
            GestureDetector(
              onTap: onSeeAll,
              child: Text('See all', style: poppins(size: 14, color: AppColors.grey)),
            ),
          ],
        ),
      );
}

class BottomNav extends StatelessWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  static const routes = ['/home', '/search', '/order-tracking', '/wallet', '/profile'];
  static const items = [
    (Icons.home_outlined, 'Home'),
    (Icons.search, 'Search'),
    (Icons.inventory_2_outlined, 'Orders'),
    (Icons.account_balance_wallet_outlined, 'Wallet'),
    (Icons.person_outline, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.darkGreen,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 66,
            child: Row(
              children: List.generate(
                items.length,
                (i) => Expanded(
                  child: GestureDetector(
                    onTap: i == currentIndex
                        ? null
                        : () => Navigator.pushReplacementNamed(context, routes[i]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: i == currentIndex ? AppColors.navActive : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(items[i].$1,
                              size: 22, color: i == currentIndex ? AppColors.darkGreen : Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(items[i].$2,
                                style: poppins(size: 12, color: Colors.white,
                                    weight: i == currentIndex ? FontWeight.w600 : FontWeight.w400)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class CategoryTile extends StatelessWidget {
  final Color bg;
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback? onTap;
  final double size;
  const CategoryTile({
    super.key,
    required this.bg,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.onTap,
    this.size = 68,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: size * 0.42),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 30,
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: poppins(
                    size: 12, weight: FontWeight.w500, color: AppColors.text),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
}

class TrackingToggle extends StatelessWidget {
  final bool isSummary;
  const TrackingToggle({super.key, required this.isSummary});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: isSummary ? null : () => Navigator.pushReplacementNamed(context, '/order-tracking'),
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSummary ? AppColors.green : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Summary',
                      style: poppins(size: 15,
                          weight: FontWeight.w600,
                          color: isSummary ? Colors.white : AppColors.text)),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: isSummary ? () => Navigator.pushNamed(context, '/live-tracking') : null,
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: !isSummary ? AppColors.green : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Live Tracking',
                      style: poppins(size: 15,
                          weight: FontWeight.w600,
                          color: !isSummary ? Colors.white : AppColors.text)),
                ),
              ),
            ),
          ],
        ),
      );
}