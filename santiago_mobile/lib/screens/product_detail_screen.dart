// Enhancement 2: Product Detail Screen displayed when user clicks a product card
import 'package:flutter/material.dart';

// Import Product model class representing target product details
import '../models/product.dart';

// Import CustomText widget for consistent typography styling
import '../widgets/custom_text.dart';

// Enhancement 3: Import CartService to persist the Add to Cart action to the API
import '../services/cart_service.dart';

// Enhancement 3: Import demoUserId constant used to scope the cart to a single demo user
import '../constants.dart';

// Enhancement 2: Detail screen displaying comprehensive product information and image preview
class ProductDetailScreen extends StatelessWidget {
  // Target product model instance passed into detail screen
  final Product product;

  // Constructor initializing ProductDetailScreen with target product object
  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  // Builds and returns single scrollable product detail view layout
  @override
  Widget build(BuildContext context) {
    // Evaluates whether dark theme mode is currently active in current context
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Top app bar displaying target product title text
      appBar: AppBar(
        title: CustomText(
          text: product.title,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      // Scrollable view containing image hero banner, specifications, and action buttons
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhancement 2: Large Hero product image banner container
            Container(
              height: 250,
              width: double.infinity,
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
              child: Image.network(
                product.thumbnail.isNotEmpty
                    ? product.thumbnail
                    : (product.images.isNotEmpty ? product.images.first : ''),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
            ),
            // Padding container wrapping detail specifications and specifications card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row displaying product category badge pill and star rating score
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Pill container wrapping product category text badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CustomText(
                          text: product.category.toUpperCase(),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      // Row displaying star icon and numeric product rating score
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          CustomText(
                            text: '${product.rating.toStringAsFixed(1)} / 5.0',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Full product title heading label
                  CustomText(
                    text: product.title,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  // Renders optional product brand manufacturer label if available
                  if (product.brand.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    CustomText(
                      text: 'Brand: ${product.brand}',
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Row displaying formatted price and discount percentage badge
                  Row(
                    children: [
                      // Product price label styled dynamically for light and dark theme contrast
                      CustomText(
                        text: '\$${product.price.toStringAsFixed(2)}',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.greenAccent.shade200 : Colors.green.shade700,
                      ),
                      // Renders discount percentage badge if discount is greater than 0
                      if (product.discountPercentage > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.red.shade900.withValues(alpha: 0.4)
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: CustomText(
                            text: '-${product.discountPercentage.toStringAsFixed(0)}%',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.red.shade200 : Colors.red.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  // Section header title label for product description
                  const CustomText(
                    text: 'Description',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 6),
                  // Full body description text content
                  CustomText(
                    text: product.description,
                    fontSize: 13,
                  ),
                  const SizedBox(height: 16),
                  // Stock availability, shipping, and return policy information card container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stock availability status label text
                        CustomText(
                          text: 'Availability: ${product.availabilityStatus.isNotEmpty ? product.availabilityStatus : (product.stock > 0 ? "In Stock (${product.stock})" : "Out of Stock")}',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        // Renders estimated shipping information if available
                        if (product.shippingInformation.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          CustomText(
                            text: 'Shipping: ${product.shippingInformation}',
                            fontSize: 12,
                          ),
                        ],
                        // Renders return policy terms if available
                        if (product.returnPolicy.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          CustomText(
                            text: 'Return Policy: ${product.returnPolicy}',
                            fontSize: 12,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Primary action button adding current item to shopping cart
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      // Enhancement 3: Calls the add-to-cart API endpoint with this product's id and a default quantity of 1
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          await CartService().addToCart(
                            userId: demoUserId,
                            products: [
                              {'id': product.id, 'quantity': 1},
                            ],
                          );

                          // Displays confirmation SnackBar message once the API call succeeds
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('${product.title} added to cart!'),
                            ),
                          );
                        } catch (e) {
                          // Displays error SnackBar message if the API call fails
                          messenger.showSnackBar(
                            SnackBar(content: Text('Failed to add to cart: $e')),
                          );
                        }
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text(
                        'Add to Cart',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
