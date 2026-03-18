import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../models/notification_item.dart';
import '../../widgets/empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> _notifications = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getNotifications();
      if (data['success'] == true) {
        final list = (data['data'] as List? ?? [])
            .map((n) => NotificationItem.fromJson(n))
            .toList();
        setState(() {
          _notifications = list;
          _loading = false;
        });
      } else {
        setState(() {
          _error = data['message'] ?? 'Erreur';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur réseau';
        _loading = false;
      });
    }
  }

  Future<void> _markRead(NotificationItem notif) async {
    if (notif.isRead) return;
    try {
      await ApiService.markNotificationRead(notif.id);
      setState(() {
        _notifications = _notifications.map((n) {
          if (n.id == notif.id) {
            return NotificationItem(
              id: n.id,
              type: n.type,
              title: n.title,
              body: n.body,
              isRead: true,
              createdAt: n.createdAt,
              data: n.data,
            );
          }
          return n;
        }).toList();
      });
    } catch (_) {}
  }

  String _timeAgo(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'À l\'instant';
      if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
      return 'Il y a ${diff.inDays}j';
    } catch (_) {
      return '';
    }
  }

  Map<String, dynamic> _getNotifConfig(String type) {
    switch (type) {
      case 'PRODUCT_APPROVED':
        return {
          'icon': Icons.check_circle_outline,
          'color': const Color(0xFF10B981),
          'bg': const Color(0xFF10B981),
        };
      case 'PRODUCT_REJECTED':
        return {
          'icon': Icons.cancel_outlined,
          'color': const Color(0xFFEF4444),
          'bg': const Color(0xFFEF4444),
        };
      case 'NEW_ORDER':
        return {
          'icon': Icons.shopping_bag_outlined,
          'color': const Color(0xFFF59E0B),
          'bg': const Color(0xFFF59E0B),
        };
      case 'ORDER_CANCELLED':
        return {
          'icon': Icons.remove_shopping_cart_outlined,
          'color': const Color(0xFFEF4444),
          'bg': const Color(0xFFEF4444),
        };
      default:
        return {
          'icon': Icons.notifications_outlined,
          'color': const Color(0xFF3B82F6),
          'bg': const Color(0xFF3B82F6),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: Text(l10n.t('notifications')),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: l10n.t('mark_all_read'),
            onPressed: () async {
              // Mark all as read
              for (final n in _notifications.where((n) => !n.isRead)) {
                await ApiService.markNotificationRead(n.id);
              }
              _loadNotifications();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF59E0B)))
          : _error != null
              ? _buildError(l10n)
              : _notifications.isEmpty
                  ? EmptyState(
                      icon: Icons.notifications_none_outlined,
                      title: l10n.t('no_notifications'),
                      subtitle: 'Vous n\'avez aucune notification pour le moment',
                    )
                  : RefreshIndicator(
                      color: const Color(0xFFF59E0B),
                      backgroundColor: const Color(0xFF1A1A2E),
                      onRefresh: _loadNotifications,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) =>
                            _buildNotifCard(_notifications[i]),
                      ),
                    ),
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey[600]),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: _loadNotifications, child: Text(l10n.t('retry'))),
        ],
      ),
    );
  }

  Widget _buildNotifCard(NotificationItem notif) {
    final config = _getNotifConfig(notif.type);
    final color = config['color'] as Color;
    final bgColor = config['bg'] as Color;
    final icon = config['icon'] as IconData;

    return GestureDetector(
      onTap: () => _markRead(notif),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(14),
          border: !notif.isRead
              ? Border.all(color: color.withOpacity(0.3))
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: bgColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: notif.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.body,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _timeAgo(notif.createdAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
