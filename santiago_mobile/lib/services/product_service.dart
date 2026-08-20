// Import dart:convert for decoding JSON response data
import 'dart:convert';

// Import HTTP client package to perform asynchronous network requests
import 'package:http/http.dart' as http;

// Import base API host URL constant loaded from environment configuration
import '../constants.dart';

// Import Product model class to parse JSON payloads into Dart objects
import '../models/product.dart';

// Service class responsible for handling external API network operations
class ProductService {
  // Asynchronously fetches product list from the remote REST API endpoint
  Future<List<Product>> getAllProducts() async {
    // Sends HTTP GET request to the target API endpoint URL
    final response = await http.get(Uri.parse('$host/products'));

    // Checks if the server responded with an HTTP 200 OK status code
    if (response.statusCode == 200) {
      // Decodes raw JSON response body into a Dart Map
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Extracts the products array from JSON data payload
      final List productsJson = data['products'] ?? [];

      // Maps each JSON map entry into a Product model instance and returns the list
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } else {
      // Throws an exception if the HTTP request failed or returned a error code
      throw Exception('Failed to load products');
    }
  }

  // Enhancement 1: Fetches a single full product by id, used when a cart item is tapped
  // so the existing ProductDetailScreen (which needs the full Product shape) can be reused,
  // since CartProduct only carries a partial subset of product fields.
  Future<Product> getProductById(int id) async {
    final response = await http.get(Uri.parse('$host/products/$id'));

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load product $id');
    }
  }
}
