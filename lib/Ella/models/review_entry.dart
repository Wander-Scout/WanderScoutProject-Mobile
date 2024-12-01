// To parse this JSON data, do
//
//     final reviewEntry = reviewEntryFromJson(jsonString);

import 'dart:convert';

class ReviewEntry {
  final int id;
  final String username;
  final String reviewText;
  final int rating;
  final DateTime createdAt;

  ReviewEntry({
    required this.id,
    required this.username,
    required this.reviewText,
    required this.rating,
    required this.createdAt,
  });

  factory ReviewEntry.fromJson(Map<String, dynamic> json) {
    return ReviewEntry(
      id: json['id'] as int,
      username: json['username'] as String,
      reviewText: json['review_text'] as String,
      rating: json['rating'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "review_text": reviewText,
        "rating": rating,
        "created_at": createdAt.toIso8601String(),
      };

  static List<ReviewEntry> listFromJson(String str) =>
      List<ReviewEntry>.from(json.decode(str).map((x) => ReviewEntry.fromJson(x)));

  static String listToJson(List<ReviewEntry> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}
