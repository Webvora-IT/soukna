import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String? ?? json['titleFr'] as String? ?? '',
      body: json['body'] as String? ?? json['bodyFr'] as String? ?? '',
      type: json['type'] as String? ?? 'INFO',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id, title: title, body: body, type: type,
    isRead: isRead ?? this.isRead, createdAt: createdAt,
  );
}

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _loading = false;
  int _unreadCount = 0;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      final res = await ApiService.get('/notifications');
      final list = res['notifications'] as List? ?? res['data'] as List? ?? [];
      _notifications = list.map((n) => AppNotification.fromJson(n as Map<String, dynamic>)).toList();
      _unreadCount = res['unreadCount'] as int? ?? _notifications.where((n) => !n.isRead).length;
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }

  Future<void> markRead(String id) async {
    try {
      await ApiService.patch('/notifications/$id', {'isRead': true});
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1 && !_notifications[idx].isRead) {
        _notifications[idx] = _notifications[idx].copyWith(isRead: true);
        _unreadCount = (_unreadCount - 1).clamp(0, 9999);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await ApiService.patch('/notifications', {'isRead': true});
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (_) {}
  }

  void incrementUnread() {
    _unreadCount++;
    notifyListeners();
  }

  void clearOnLogout() {
    _notifications = [];
    _unreadCount = 0;
    notifyListeners();
  }
}
