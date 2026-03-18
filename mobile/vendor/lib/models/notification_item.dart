class NotificationItem {
  final String id;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final String createdAt;
  final Map<String, dynamic>? data;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: json['id'] ?? '',
        type: json['type'] ?? 'GENERAL',
        title: json['title'] ?? '',
        body: json['body'] ?? json['message'] ?? '',
        isRead: json['isRead'] ?? json['read'] ?? false,
        createdAt: json['createdAt'] ?? '',
        data: json['data'],
      );
}
