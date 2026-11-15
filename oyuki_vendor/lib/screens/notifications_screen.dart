import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/app_scope.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final items = s.notifications;

    return Scaffold(
      appBar: AppBar(
        leading: const BackChevron(),
        title: const Text('Notification'),
        actions: [
          if (s.unreadCount > 0)
            TextButton(
              onPressed: s.markAllRead,
              child: const Text('Read all', style: TextStyle(color: AppColors.primary)),
            ),
        ],
      ),
      body: items.isEmpty
          ? const Center(
              child: Text('No notifications yet', style: TextStyle(color: AppColors.muted)),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final n = items[i];
                return InkWell(
                  onTap: () => s.markNotificationRead(n.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          n.kind == NotificationKind.rider
                              ? Icons.pedal_bike
                              : Icons.notifications_none,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      n.title,
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight:
                                            n.read ? FontWeight.w500 : FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if (!n.read) ...[
                                    const SizedBox(width: 10),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                          color: AppColors.primary, shape: BoxShape.circle),
                                    ),
                                  ],
                                ],
                              ),
                              if (n.body.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(n.body,
                                    style: const TextStyle(
                                        color: AppColors.muted, fontSize: 15)),
                              ],
                              const SizedBox(height: 4),
                              Text(relativeTime(n.createdAt),
                                  style: const TextStyle(
                                      color: AppColors.muted, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
