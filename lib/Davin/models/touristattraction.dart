import 'dart:convert';

List<TouristAttraction> touristAttractionFromJson(String str) => List<TouristAttraction>.from(json.decode(str).map((x) => TouristAttraction.fromJson(x)));

String touristAttractionToJson(List<TouristAttraction> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TouristAttraction {
  String id;
  int no;
  String nama;
  double rating;
  double voteAverage;
  int voteCount;
  String type;
  int htmWeekday;
  int htmWeekend;
  String description;
  String gmapsUrl;
  double latitude;
  double longitude;

  TouristAttraction({
    required this.id,
    required this.no,
    required this.nama,
    required this.rating,
    required this.voteAverage,
    required this.voteCount,
    required this.type,
    required this.htmWeekday,
    required this.htmWeekend,
    required this.description,
    required this.gmapsUrl,
    required this.latitude,
    required this.longitude,
  });

  factory TouristAttraction.fromJson(Map<String, dynamic> json) => TouristAttraction(
    id: json["id"],
    no: json["no"],
    nama: json["nama"],
    rating: json["rating"],
    voteAverage: json["vote_average"]?.toDouble() ?? 0.0,
    voteCount: json["vote_count"],
    type: json["type"],
    htmWeekday: json["htm_weekday"],
    htmWeekend: json["htm_weekend"],
    description: json["description"],
    gmapsUrl: json["gmaps_url"],
    latitude: json["latitude"]?.toDouble() ?? 0.0,
    longitude: json["longitude"]?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "no": no,
    "nama": nama,
    "rating": rating,
    "vote_average": voteAverage,
    "vote_count": voteCount,
    "type": type,
    "htm_weekday": htmWeekday,
    "htm_weekend": htmWeekend,
    "description": description,
    "gmaps_url": gmapsUrl,
    "latitude": latitude,
    "longitude": longitude,
  };
}
