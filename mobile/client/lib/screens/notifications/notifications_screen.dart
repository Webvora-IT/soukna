import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().load();
    });
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'STATUS_UPDATE': return Icons.local_shipping_outlined;
      case 'ORDER_CONFIRMED': return Icons.check_circle_outline;
      case 'PROMO': return Icons.local_offer_outlined;
      default: return Icons.notifications_outlined;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'STATUS_UPDATE': return const Color(0xFFF59E0B);
      case 'ORDER_CONFIRMED': return const Color(0xFF10B981);
      case 'PROMO': return const Color(0xFF8B5CF6);
      default: return const Color(0xFF3B82F6);
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    return DateFormat('dd MMM', 'fr').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final notifications = provider.notifications;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: () => context.read<NotificationProvider>().markAllRead(),
              child: Text(
                'Tout lire',
                style: GoogleFonts.cairo(color: const Color(0xFFF59E0B), fontSize: 13),
              ),
            ),
        ],
      ),
      body: provider.loading && notifications.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B)))
          : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none_outlined, size: 72, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune notification',
                        style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vous êtes à jour !',
                        style: GoogleFonts.cairo(color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => context.read<NotificationProvider>().load(),
                  color: const Color(0xFFF59E0B),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      final color = _typeColor(notif.type);

                      return InkWell(
                        onTap: () {
                          if (!notif.isRead) {
                            context.read<NotificationProvider>().markRead(notif.id);
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: notif.isRead ? Colors.white : color.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: notif.isRead ? Colors.grey.shade100 : color.withOpacity(0.3),
                              width: notif.isRead ? 1 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(_typeIcon(notif.type), color: color, size: 20),
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
                                            style: GoogleFonts.cairo(
                                              fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.bold,
                                              fontSize: 14,
                                              color: const Color(0xFF1F2937),
                                            ),
                                          ),
                                        ),
                                        if (!notif.isRead)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            margin: const EdgeInsets.only(left: 8),
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notif.body,
                                      style: GoogleFonts.cairo(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _timeAgo(notif.createdAt),
                                      style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
