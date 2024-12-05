import 'dart:convert';

class ReviewEntry {
  final int id;
  final String username;
  final String reviewText;
  final int rating;
  final DateTime createdAt;
  final List<AdminReply> adminReplies; // New field for admin replies

  ReviewEntry({
    required this.id,
    required this.username,
    required this.reviewText,
    required this.rating,
    required this.createdAt,
    required this.adminReplies, // Include in constructor
  });

  factory ReviewEntry.fromJson(Map<String, dynamic> json) {
    return ReviewEntry(
      id: json['id'] as int,
      username: json['username'] as String,
      reviewText: json['review_text'] as String,
      rating: json['rating'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      adminReplies: json['admin_replies'] != null
          ? List<AdminReply>.from(
              json['admin_replies'].map((x) => AdminReply.fromJson(x)),
            )
          : [], // Parse admin replies or set an empty list
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "review_text": reviewText,
        "rating": rating,
        "created_at": createdAt.toIso8601String(),
        "admin_replies":
            List<dynamic>.from(adminReplies.map((x) => x.toJson())), // Convert replies to JSON
      };

  static List<ReviewEntry> listFromJson(String str) =>
      List<ReviewEntry>.from(json.decode(str).map((x) => ReviewEntry.fromJson(x)));

  static String listToJson(List<ReviewEntry> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}

class AdminReply {
  final String replyText;
  final String adminUsername;
  final DateTime createdAt;

  AdminReply({
    required this.replyText,
    required this.adminUsername,
    required this.createdAt,
  });

  factory AdminReply.fromJson(Map<String, dynamic> json) {
    return AdminReply(
      replyText: json['reply_text'] as String,
      adminUsername: json['admin_username'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        "reply_text": replyText,
        "admin_username": adminUsername,
        "created_at": createdAt.toIso8601String(),
      };
}
