import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';
import '../state/app_scope.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'orders_screen.dart' show confirmRejectOrder;

class OrderDetailScreen extends StatelessWidget {
  final int orderNumber;
  const OrderDetailScreen({super.key, required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final order = s.orderByNumber(orderNumber);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(leading: const BackChevron(), title: const Text('Order details')),
        body: const Center(child: Text('Order not found')),
      );
    }
    final (label, color) = statusStyle(order.status);

    return Scaffold(
      appBar: AppBar(leading: const BackChevron(), title: const Text('Order details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(order.customerName,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 18, color: AppColors.muted),
              const SizedBox(width: 8),
              Expanded(child: Text(order.address, style: const TextStyle(fontSize: 15))),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: order.phone));
              if (context.mounted) toast(context, 'Phone number copied');
            },
            child: Row(
              children: [
                const Icon(Icons.phone_outlined, size: 18, color: AppColors.muted),
                const SizedBox(width: 8),
                Text(order.phone, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('Order #${order.number} · ${dayLabel(order.createdAt)}, ${timeLabel(order.createdAt)}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13)),
              const Spacer(),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 28),
          const Text('Order Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          for (final i in order.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text('${i.name} x${i.quantity}',
                        style: const TextStyle(fontSize: 16)),
                  ),
                  Text(money(i.lineTotal),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          const Divider(height: 28, color: AppColors.muted),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 20)),
              Text(money(order.total),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 36),
          if (order.status == OrderStatus.pending) ...[
            PrimaryButton(
              label: 'Accept Order',
              onPressed: () async {
                await s.acceptOrder(order.number);
                if (context.mounted) toast(context, 'Order #${order.number} accepted');
              },
            ),
            const SizedBox(height: 12),
            OutlineButtonX(
              label: 'Reject Order',
              onPressed: () async {
                if (!await confirmRejectOrder(context)) return;
                await s.rejectOrder(order.number);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ] else if (order.status == OrderStatus.active)
            PrimaryButton(
              label: 'Mark as completed',
              onPressed: () async {
                await s.completeOrder(order.number);
                if (context.mounted) toast(context, 'Order #${order.number} completed');
              },
            ),
        ],
      ),
    );
  }
}
