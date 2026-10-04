enum AiMessageRole { user, assistant }

class AiMessage {
  final String id;
  final String content;
  final AiMessageRole role;
  final DateTime createdAt;

  AiMessage({
    required this.id,
    required this.content,
    required this.role,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
