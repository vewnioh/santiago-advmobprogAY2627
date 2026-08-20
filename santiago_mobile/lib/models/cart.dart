// Main data model representing a single shopping cart fetched from the API
class Cart {
  // Unique numeric identifier for the cart
  final int id;

  // List of individual product line items contained in this cart
  final List<CartProduct> products;

  // Total price of all cart items before discounts are applied
  final double total;

  // Total price of all cart items after discounts are applied
  final double discountedTotal;

  // Identifier of the user who owns this cart
  final int userId;

  // Total count of distinct products in the cart
  final int totalProducts;

  // Total combined quantity of all items in the cart
  final int totalQuantity;

  // Constructor initializing all required cart fields
  Cart({
    required this.id,
    required this.products,
    required this.total,
    required this.discountedTotal,
    required this.userId,
    required this.totalProducts,
    required this.totalQuantity,
  });

  // Factory constructor deserializing JSON map data into a strongly-typed Cart object
  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] ?? 0,
      products: (json['products'] as List?)
              ?.map((e) => CartProduct.fromJson(e))
              .toList() ??
          [],
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      discountedTotal: (json['discountedTotal'] as num?)?.toDouble() ?? 0.0,
      userId: json['userId'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      totalQuantity: json['totalQuantity'] ?? 0,
    );
  }

  // Serializes this Cart instance back into a JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'products': products.map((e) => e.toJson()).toList(),
      'total': total,
      'discountedTotal': discountedTotal,
      'userId': userId,
      'totalProducts': totalProducts,
      'totalQuantity': totalQuantity,
    };
  }
}

// Data model representing a single product line item within a cart
class CartProduct {
  // Unique numeric identifier of the underlying product
  final int id;

  // Title name of the product
  final String title;

  // Unit price of the product
  final double price;

  // Quantity of this product currently in the cart
  final int quantity;

  // Total price for this line item before discount (price * quantity)
  final double total;

  // Percentage discount applied to this line item
  final double discountPercentage;

  // Total price for this line item after discount is applied
  final double discountedTotal;

  // Thumbnail image URL for the product
  final String thumbnail;

  // Constructor initializing all required cart product fields
  CartProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.total,
    required this.discountPercentage,
    required this.discountedTotal,
    required this.thumbnail,
  });

  // Factory constructor deserializing JSON map data into a strongly-typed CartProduct object
  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      discountedTotal: (json['discountedTotal'] as num?)?.toDouble() ?? 0.0,
      thumbnail: json['thumbnail'] ?? '',
    );
  }

  // Serializes this CartProduct instance back into a JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'quantity': quantity,
      'total': total,
      'discountPercentage': discountPercentage,
      'discountedTotal': discountedTotal,
      'thumbnail': thumbnail,
    };
  }
}
