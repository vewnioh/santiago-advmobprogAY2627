// Import dart:convert for decoding JSON response data
import 'dart:convert';

// Import HTTP client package to perform asynchronous network requests
import 'package:http/http.dart' as http;

// Import base API host URL constant loaded from environment configuration
import '../constants.dart';

// Import Cart model class to parse JSON payloads into Dart objects
import '../models/cart.dart';

// Service class responsible for handling external cart API network operations
class CartService {
  // Asynchronously fetches the full list of carts from the remote REST API endpoint
  Future<List<Cart>> getAllCarts() async {
    final response = await http.get(Uri.parse('$host/carts'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List cartsJson = data['carts'] ?? [];
      return cartsJson.map((json) => Cart.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load carts');
    }
  }

  // Enhancement 3: Fetches only the cart belonging to a specific user id via /carts/user/{userId}
  Future<Cart?> getCartByUserId(int userId) async {
    // Sends HTTP GET request scoped to the target user's carts
    final response = await http.get(Uri.parse('$host/carts/user/$userId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List cartsJson = data['carts'] ?? [];

      // A user may own zero or more carts; render only the first one
      if (cartsJson.isEmpty) return null;
      return Cart.fromJson(cartsJson.first);
    } else {
      throw Exception('Failed to load cart for user $userId');
    }
  }

  // Enhancement 3: Adds product(s) to a new cart for the given user via POST /carts/add
  Future<Cart> addToCart({
    required int userId,
    required List<Map<String, dynamic>> products,
  }) async {
    final response = await http.post(
      Uri.parse('$host/carts/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'products': products,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // /carts/add responds with a single cart object, not wrapped in a 'carts' list
      return Cart.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add product to cart');
    }
  }

  // Enhancement 3: Updates an existing cart's product quantities via PUT /carts/{id}
  Future<Cart> updateCart({
    required int cartId,
    required List<Map<String, dynamic>> products,
  }) async {
    final response = await http.put(
      Uri.parse('$host/carts/$cartId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'merge': false,
        'products': products,
      }),
    );

    if (response.statusCode == 200) {
      return Cart.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update cart');
    }
  }
}
