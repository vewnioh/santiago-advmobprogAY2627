// Enhancement 1 & 3: Cart Screen rendering the logged-in user's single cart from the API
import 'package:flutter/material.dart';

// Import ScreenUtil package for responsive screen dimensions and font scaling
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Import Cart and CartProduct models for data typing and structure
import '../models/cart.dart';

// Import Product model, needed once a cart item is resolved to its full product record
import '../models/product.dart';

// Import CartService to fetch and mutate the user's cart via the REST API
import '../services/cart_service.dart';

// Import ProductService to resolve a cart line item's full Product before opening the detail screen
import '../services/product_service.dart';

// Import CustomText widget for consistent typography styling
import '../widgets/custom_text.dart';

// Enhancement 3 (Lab 4): Import UserService to scope the cart to the currently logged-in user
import '../services/user_service.dart';

// Enhancement 1: Import ProductDetailScreen so cart items can navigate to the same detail screen widget
import 'detail_screen.dart';

// Primary screen component displaying the demo user's cart and its line items
class CartScreen extends StatefulWidget {
  // Constructor initializing CartScreen stateful widget
  const CartScreen({super.key});

  // Creates mutable state instance for CartScreen widget
  @override
  State<CartScreen> createState() => _CartScreenState();
}

// State class managing async cart loading, quantity updates, and item navigation
class _CartScreenState extends State<CartScreen> {
  // Service instances used to call the cart, product, and user REST API endpoints
  final CartService _cartService = CartService();
  final ProductService _productService = ProductService();
  final UserService _userService = UserService();

  // Holds the loaded cart once the initial fetch completes; updated in place afterwards
  // so quantity changes don't have to re-run the FutureBuilder's loading state on every tap
  Cart? _cart;

  // True only while the very first cart fetch is in flight
  bool _isLoading = true;

  // Error message from the initial fetch, if any
  String? _errorMessage;

  // Lifecycle method initializing the cart fetch operation when widget enters tree
  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  // Enhancement 3 (Lab 4): Loads only the cart belonging to the saved, logged-in user via GET /carts/user/{userId}
  Future<void> _loadCart() async {
    try {
      final currentUser = await _userService.getUser();
      final Cart? cart = await _cartService.getCartByUserId(currentUser.id);
      if (!mounted) return;
      setState(() {
        _cart = cart;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Enhancement 3: Adjusts a line item's quantity by delta and persists it via PUT /carts/{id}
  Future<void> _changeQuantity(Cart cart, CartProduct item, int delta) async {
    final int newQuantity = item.quantity + delta;

    // Rebuilds the full product payload, dropping the item entirely once its quantity reaches zero
    final List<Map<String, dynamic>> payload = cart.products
        .map((p) => p.id == item.id
            ? {'id': p.id, 'quantity': newQuantity}
            : {'id': p.id, 'quantity': p.quantity})
        .where((p) => (p['quantity'] as int) > 0)
        .toList();

    try {
      // DummyJSON's PUT /carts/{id} doesn't persist server-side, so this response is the
      // only place the updated quantities/totals actually exist - written straight into
      // _cart instead of re-fetching, so the list updates in place without a loading flash.
      final Cart updatedCart =
          await _cartService.updateCart(cartId: cart.id, products: payload);
      setState(() {
        _cart = updatedCart;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update quantity: $e')),
      );
    }
  }

  // Enhancement 1: Resolves a cart line item's full Product record, then navigates to the shared detail screen
  Future<void> _openProductDetail(CartProduct item) async {
    // Shows a blocking loading indicator while the full product record is fetched
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final Product product = await _productService.getProductById(item.id);
      if (!mounted) return;
      Navigator.pop(context); // Dismisses the loading dialog

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(product: product),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Dismisses the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open product: $e')),
      );
    }
  }

  // Builds and returns the cart list once loaded, driven by plain state instead of FutureBuilder
  // so per-item quantity updates only rebuild in place instead of flashing a full loading state
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Builder(
        builder: (context) {
          // Renders centered loading spinner only while the initial fetch is in flight
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Renders error message widget if the initial API fetch operation failed
          if (_errorMessage != null) {
            return Center(
              child: CustomText(
                text: 'Error: $_errorMessage',
                fontSize: 14.sp,
              ),
            );
          }

          final Cart? cart = _cart;

          // Renders empty state message if the user has no cart or no items in it
          if (cart == null || cart.products.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: CustomText(
                  text: 'Your cart is empty.',
                  fontSize: 14.sp,
                ),
              ),
            );
          }

          return Column(
            children: [
              // Scrollable list of cart line items
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: cart.products.length,
                  separatorBuilder: (context, index) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    final item = cart.products[index];

                    return Card(
                      elevation: 2,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      // Enhancement 1: Tapping a cart item navigates to the shared product detail screen
                      child: InkWell(
                        onTap: () => _openProductDetail(item),
                        child: Padding(
                          padding: EdgeInsets.all(10.w),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product thumbnail image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.network(
                                  item.thumbnail,
                                  width: 60.w,
                                  height: 60.w,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.image, size: 24.sp),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              // Title, price, and discount details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      text: item.title,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4.h),
                                    CustomText(
                                      text: '\$${item.price.toStringAsFixed(2)}',
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade700,
                                    ),
                                    if (item.discountPercentage > 0)
                                      CustomText(
                                        text:
                                            '${item.discountPercentage.toStringAsFixed(0)}% off - \$${item.discountedTotal.toStringAsFixed(2)} total',
                                        fontSize: 11.sp,
                                        color: Colors.red.shade400,
                                      ),
                                  ],
                                ),
                              ),
                              // Enhancement 3: Quantity +/- controls persisted live via PUT /carts/{id}
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.add_circle, color: Colors.orange, size: 20.sp),
                                    onPressed: () => _changeQuantity(cart, item, 1),
                                  ),
                                  CustomText(
                                    text: '${item.quantity}',
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.remove_circle, color: Colors.grey, size: 20.sp),
                                    onPressed: () => _changeQuantity(cart, item, -1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Order summary and confirm action pinned to the bottom of the screen
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(text: 'Subtotal:', fontSize: 13.sp),
                        CustomText(
                          text: '\$${cart.total.toStringAsFixed(2)}',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(text: 'Total:', fontSize: 15.sp, fontWeight: FontWeight.bold),
                        CustomText(
                          text: '\$${cart.discountedTotal.toStringAsFixed(2)}',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      height: 44.h,
                      child: ElevatedButton(
                        // No dedicated order-placement endpoint exists on DummyJSON's cart API,
                        // so this simply confirms the action locally.
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Order confirmed!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: const Text(
                          'Confirm Order',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
