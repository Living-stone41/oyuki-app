import 'dart:io';

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme.dart';
import '../utils/format.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool busy;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: busy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary,
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

class OutlineButtonX extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;

  const OutlineButtonX({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.danger,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      ),
    );
  }
}

class BackChevron extends StatelessWidget {
  final VoidCallback? onPressed;
  const BackChevron({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.chevron_left, size: 32, color: AppColors.primary),
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      tooltip: 'Back',
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.muted,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

class StatTriplet extends StatelessWidget {
  final int totalOrders;
  final int todaysOrders;
  final int todaysSales;
  const StatTriplet({
    super.key,
    required this.totalOrders,
    required this.todaysOrders,
    required this.todaysSales,
  });

  Widget _cell(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 14)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        ],
      );

  Widget get _divider => Container(
        width: 1,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: AppColors.text,
      );

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          _cell('Total orders', '$totalOrders'),
          _divider,
          _cell('Today’s order', '$todaysOrders'),
          _divider,
          Flexible(child: _cell('Today’s sales', money(todaysSales))),
        ],
      ),
    );
  }
}

/// Image for a menu item / avatar: bundled asset, local file or placeholder.
class PhotoView extends StatelessWidget {
  final String? path;
  final double width;
  final double height;
  final double radius;
  final IconData placeholder;

  const PhotoView({
    super.key,
    required this.path,
    this.width = 96,
    this.height = 84,
    this.radius = 8,
    this.placeholder = Icons.image_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final p = path;
    Widget child;
    Widget fallback() => Container(
          color: const Color(0xFFE9ECEF),
          alignment: Alignment.center,
          child: Icon(placeholder, color: AppColors.muted),
        );
    if (p == null || p.isEmpty) {
      child = fallback();
    } else if (p.startsWith('asset:')) {
      child = Image.asset(
        p.substring(6),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback(),
      );
    } else {
      child = Image.file(
        File(p),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback(),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(width: width, height: height, child: child),
    );
  }
}

class OrderLines extends StatelessWidget {
  final Order order;
  const OrderLines(this.order, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final i in order.items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${i.name} x${i.quantity}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 15),
                  ),
                ),
                const SizedBox(width: 12),
                Text(money(i.lineTotal),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
      ],
    );
  }
}

class TotalRow extends StatelessWidget {
  final int total;
  const TotalRow(this.total, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Text(money(total),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

BoxDecoration cardDecoration() => BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.border),
    );

(String, Color) statusStyle(OrderStatus s) {
  switch (s) {
    case OrderStatus.pending:
      return ('pending', AppColors.pending);
    case OrderStatus.active:
      return ('active', AppColors.primary);
    case OrderStatus.completed:
      return ('completed', AppColors.completed);
    case OrderStatus.rejected:
      return ('rejected', AppColors.danger);
  }
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool danger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, fontSize: 15)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                      label: cancelLabel, onPressed: () => Navigator.pop(ctx, false)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlineButtonX(
                    label: confirmLabel,
                    color: danger ? AppColors.danger : AppColors.primary,
                    onPressed: () => Navigator.pop(ctx, true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

void toast(BuildContext context, String message) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(content: Text(message)));
}
