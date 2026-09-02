enum MessageSender { user, ai, system }

/// Domain model for AI Companion chat message
class CompanionMessage {
  final String id;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const CompanionMessage({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.metadata,
  });

  factory CompanionMessage.fromJson(Map<String, dynamic> json) {
    return CompanionMessage(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      sender: json['sender'] == 'ai'
          ? MessageSender.ai
          : json['sender'] == 'system'
              ? MessageSender.system
              : MessageSender.user,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender': sender.name,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}
