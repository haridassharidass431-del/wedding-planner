class AppNotificationItem {
  final String id;
  final String title;
  final String message;
  final String relatedBookingId;
  final DateTime createdAt;
  final bool isRead;

  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.relatedBookingId,
    required this.createdAt,
    this.isRead = false,
  });

  AppNotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    String? relatedBookingId,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AppNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      relatedBookingId: relatedBookingId ?? this.relatedBookingId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
