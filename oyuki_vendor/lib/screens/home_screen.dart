import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/app_scope.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'notifications_screen.dart';
import 'order_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final active = s.activeOrders;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => Future<void>.delayed(const Duration(milliseconds: 400)),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${greeting()},\n${s.profile.ownerName} \u{1F44B}',
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w700, height: 1.2),
                    ),
                  ),
                  // Long-press the bell to simulate an incoming customer order.
                  IconButton(
                    tooltip: 'Notifications',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    ),
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.notifications_none,
                            color: AppColors.primary, size: 28),
                        if (s.unreadCount > 0)
                          Positioned(
                            right: 1,
                            top: 1,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppColors.danger,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const SectionLabel('Sales overview'),
              const SizedBox(height: 12),
              const Text('Total sales',
                  style: TextStyle(color: AppColors.muted, fontSize: 15)),
              const SizedBox(height: 4),
              Text(money(s.totalRevenue),
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              StatTriplet(
                totalOrders: s.totalOrders,
                todaysOrders: s.todaysOrders,
                todaysSales: s.todaysSales,
              ),
              const SizedBox(height: 28),
              const SectionLabel('Active orders'),
              const SizedBox(height: 12),
              if (active.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: cardDecoration(),
                  child: const Center(
                    child: Text('No active orders right now',
                        style: TextStyle(color: AppColors.muted)),
                  ),
                )
              else
                for (final o in active) _ActiveOrderCard(order: o),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  final Order order;
  const _ActiveOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
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
                  Text('Order #${order.number}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                        color: AppColors.completed, shape: BoxShape.circle),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              OrderLines(order),
              TotalRow(order.total),
            ],
          ),
        ),
      ),
    );
  }
}
