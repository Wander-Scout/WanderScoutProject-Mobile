// To parse this JSON data, do
//
//     final cartDetails = cartDetailsFromJson(jsonString);

import 'dart:convert';

CartDetails cartDetailsFromJson(String str) => CartDetails.fromJson(json.decode(str));

String cartDetailsToJson(CartDetails data) => json.encode(data.toJson());

class CartDetails {
    Cart cart;

    CartDetails({
        required this.cart,
    });

    factory CartDetails.fromJson(Map<String, dynamic> json) => CartDetails(
        cart: Cart.fromJson(json["cart"]),
    );

    Map<String, dynamic> toJson() => {
        "cart": cart.toJson(),
    };
}

class Cart {
    int id;
    String user;
    DateTime createdAt;
    List<Item> items;

    Cart({
        required this.id,
        required this.user,
        required this.createdAt,
        required this.items,
    });

    factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        id: json["id"],
        user: json["user"],
        createdAt: DateTime.parse(json["created_at"]),
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user": user,
        "created_at": createdAt.toIso8601String(),
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
    };
}

class Item {
    String id;
    String name;
    int price;
    bool isWeekend;
    int quantity;

    Item({
        required this.id,
        required this.name,
        required this.price,
        required this.isWeekend,
        required this.quantity,
    });

    factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        name: json["name"],
        price: json["price"],
        isWeekend: json["is_weekend"],
        quantity: json["quantity"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
        "is_weekend": isWeekend,
        "quantity": quantity,
    };
}

class Receipt {
  String bookingId;
  double totalPrice;
  List<Item> items;

  Receipt({
    required this.bookingId,
    required this.totalPrice,
    required this.items,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) => Receipt(
        bookingId: json['booking_id']?.toString() ?? 'Unknown', // Handle null booking_id
        totalPrice: json['total_price'] is double
            ? json['total_price']
            : double.parse(json['total_price'].toString()),
        items: List<Item>.from(json['items'].map((x) => Item.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'booking_id': bookingId,
        'total_price': totalPrice,
        'items': List<dynamic>.from(items.map((x) => x.toJson())),
      };
}



