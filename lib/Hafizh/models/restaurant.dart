class Restaurant {
  final String id;
  final String name;
  final String foodPreference;
  final double averagePrice;
  final double rating;
  final String atmosphere;
  final String foodVariety;

  Restaurant({
    required this.id,
    required this.name,
    required this.foodPreference,
    required this.averagePrice,
    required this.rating,
    required this.atmosphere,
    required this.foodVariety,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    final fields = json['fields']; // Extract the "fields" key
    return Restaurant(
      id: fields['id'],
      name: fields['name'],
      foodPreference: fields['food_preference'],
      averagePrice: fields['average_price'].toDouble(),
      rating: fields['rating'].toDouble(),
      atmosphere: fields['atmosphere'],
      foodVariety: fields['food_variety'],
    );
  }
}
