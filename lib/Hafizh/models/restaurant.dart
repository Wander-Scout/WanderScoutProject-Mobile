import 'dart:convert';

List<Restaurant> restaurantFromJson(String str) =>
    List<Restaurant>.from(json.decode(str).map((x) => Restaurant.fromJson(x)));

String restaurantToJson(List<Restaurant> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Restaurant {
  String id;
  String name;
  FoodPreference foodPreference;
  int averagePrice;
  double rating;
  Atmosphere atmosphere;
  String foodVariety;

  Restaurant({
    required this.id,
    required this.name,
    required this.foodPreference,
    required this.averagePrice,
    required this.rating,
    required this.atmosphere,
    required this.foodVariety,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json["id"],
        name: json["name"],
        foodPreference:
            FoodPreferenceExtension.fromString(json["food_preference"]),
        averagePrice: json["average_price"],
        rating: json["rating"]?.toDouble() ?? 0.0,
        atmosphere: AtmosphereExtension.fromString(json["atmosphere"]),
        foodVariety: json["food_variety"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "food_preference": foodPreference.displayName,
        "average_price": averagePrice,
        "rating": rating,
        "atmosphere": atmosphere.displayName,
        "food_variety": foodVariety,
      };
}

enum Atmosphere { FORMAL, SANTAI }

extension AtmosphereExtension on Atmosphere {
  String get displayName {
    switch (this) {
      case Atmosphere.FORMAL:
        return "Formal";
      case Atmosphere.SANTAI:
        return "Santai";
    }
  }

  static Atmosphere fromString(String value) {
    switch (value) {
      case "Formal":
        return Atmosphere.FORMAL;
      case "Santai":
        return Atmosphere.SANTAI;
      default:
        throw Exception("Unknown atmosphere: $value");
    }
  }
}

enum FoodPreference {
  CHINESE,
  INDONESIA,
  JAPANESE,
  MIDDLE_EASTERN,
  WESTERN,
}

extension FoodPreferenceExtension on FoodPreference {
  String get displayName {
    switch (this) {
      case FoodPreference.CHINESE:
        return "Chinese";
      case FoodPreference.INDONESIA:
        return "Indonesia";
      case FoodPreference.JAPANESE:
        return "Japanese";
      case FoodPreference.MIDDLE_EASTERN:
        return "Middle Eastern";
      case FoodPreference.WESTERN:
        return "Western";
    }
  }

  static FoodPreference fromString(String value) {
    switch (value) {
      case "Chinese":
        return FoodPreference.CHINESE;
      case "Indonesia":
        return FoodPreference.INDONESIA;
      case "Japanese":
        return FoodPreference.JAPANESE;
      case "Middle Eastern":
        return FoodPreference.MIDDLE_EASTERN;
      case "Western":
        return FoodPreference.WESTERN;
      default:
        throw Exception("Unknown food preference: $value");
    }
  }
}
