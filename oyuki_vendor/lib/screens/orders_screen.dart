import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/app_scope.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  final VoidCallback onBack;
  const OrdersScreen({super.key, required this.onBack});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  /// null = show everything.
  OrderStatus? _filter;

  static const _filters = [
    (OrderStatus.active, 'Active'),
    (OrderStatus.pending, 'Pending'),
    (OrderStatus.completed, 'Completed'),
  ];

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final list = s.orders.where((o) => _filter == null || o.status == _filter).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final children = <Widget>[];
    String? lastLabel;
    for (final o in list) {
      final label = dayLabel(o.createdAt);
      if (label != lastLabel) {
        children.add(Padding(
          padding: EdgeInsets.only(top: lastLabel == null ? 4 : 18, bottom: 10),
          child: Text(label,
              style: const TextStyle(color: AppColors.muted, fontSize: 15, fontWeight: FontWeight.w500)),
        ));
        lastLabel = label;
      }
      children.add(_OrderCard(order: o));
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackChevron(onPressed: widget.onBack),
        title: const Text('Orders'),
        actions: [
          PopupMenuButton<OrderStatus>(
            tooltip: 'Filter',
            icon: Badge(
              isLabelVisible: _filter != null,
              smallSize: 8,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.filter_list, color: AppColors.primary),
            ),
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onSelected: (v) => setState(() => _filter = _filter == v ? null : v),
            itemBuilder: (_) => [
              for (final f in _filters)
                PopupMenuItem<OrderStatus>(
                  value: f.$1,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: _filter == f.$1 ? AppColors.navBar : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          child: _filter == f.$1
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : null,
                        ),
                        Text(
                          f.$2,
                          style: TextStyle(
                            color: _filter == f.$1 ? Colors.white : AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: list.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.muted),
                  const SizedBox(height: 12),
                  Text(
                    _filter == null
                        ? 'No orders yet'
                        : 'No ${_filters.firstWhere((f) => f.$1 == _filter).$2.toLowerCase()} orders',
                    style: const TextStyle(color: AppColors.muted, fontSize: 16),
                  ),
                  if (_filter != null)
                    TextButton(
                      onPressed: () => setState(() => _filter = null),
                      child: const Text('Show all orders'),
                    ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: children,
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.read(context);
    final (label, color) = statusStyle(order.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => OrderDetailScreen(orderNumber: order.number)),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(order.customerName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                  Text(label, style: TextStyle(color: color, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 4),
              Text('Order #${order.number} · ${timeLabel(order.createdAt)}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 15)),
              const SizedBox(height: 8),
              OrderLines(order),
              TotalRow(order.total),
              if (order.status == OrderStatus.pending) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: 'Accept order',
                        onPressed: () async {
                          await s.acceptOrder(order.number);
                          if (context.mounted) toast(context, 'Order #${order.number} accepted');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlineButtonX(
                        label: 'Reject order',
                        onPressed: () async {
                          final ok = await confirmRejectOrder(context);
                          if (!ok) return;
                          await s.rejectOrder(order.number);
                          if (context.mounted) toast(context, 'Order #${order.number} rejected');
                        },
                      ),
                    ),
                  ],
                ),
              ],
              if (order.status == OrderStatus.active) ...[
                const SizedBox(height: 14),
                PrimaryButton(
                  label: 'Mark as completed',
                  onPressed: () async {
                    await s.completeOrder(order.number);
                    if (context.mounted) toast(context, 'Order #${order.number} completed');
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> confirmRejectOrder(BuildContext context) => confirmDialog(
      context,
      title: 'Reject order',
      message: 'Are you sure you want to reject this order? This cannot be undone.',
      confirmLabel: 'Reject',
      cancelLabel: 'Keep',
      danger: true,
    );
