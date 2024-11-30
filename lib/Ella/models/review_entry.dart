// To parse this JSON data, do
//
//     final reviewEntry = reviewEntryFromJson(jsonString);

import 'dart:convert';

List<ReviewEntry> reviewEntryFromJson(String str) => List<ReviewEntry>.from(json.decode(str).map((x) => ReviewEntry.fromJson(x)));

String reviewEntryToJson(List<ReviewEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReviewEntry {
  String username;  // Updated from 'user' to 'username'
  String reviewText;
  int rating;
  DateTime createdAt;

  ReviewEntry({
    required this.username,
    required this.reviewText,
    required this.rating,
    required this.createdAt,
  });

  factory ReviewEntry.fromJson(Map<String, dynamic> json) => ReviewEntry(
        username: json["username"],  // Updated to match API response
        reviewText: json["review_text"],
        rating: json["rating"],
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "username": username,
        "review_text": reviewText,
        "rating": rating,
        "created_at": createdAt.toIso8601String(),
      };
}
