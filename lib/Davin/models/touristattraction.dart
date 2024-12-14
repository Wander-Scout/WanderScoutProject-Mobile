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

  // Updated factory method with explicit type casting
  factory TouristAttraction.fromJson(Map<String, dynamic> json) => TouristAttraction(
    id: json["id"],
    no: json["no"] is int ? json["no"] : int.tryParse(json["no"].toString()) ?? 0,
    nama: json["nama"],
    rating: (json["rating"] as num).toDouble(),
    voteAverage: (json["vote_average"] as num?)?.toDouble() ?? 0.0,
    voteCount: json["vote_count"] is int ? json["vote_count"] : (json["vote_count"] as num).toInt(),
    type: json["type"],
    htmWeekday: json["htm_weekday"] is int ? json["htm_weekday"] : (json["htm_weekday"] as num).toInt(),
    htmWeekend: json["htm_weekend"] is int ? json["htm_weekend"] : (json["htm_weekend"] as num).toInt(),
    description: json["description"],
    gmapsUrl: json["gmaps_url"],
    latitude: (json["latitude"] as num?)?.toDouble() ?? 0.0,
    longitude: (json["longitude"] as num?)?.toDouble() ?? 0.0,
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
