// Import Flutter material package for UI widgets and layout components
import 'package:flutter/material.dart';

// Import ScreenUtil for screen density responsiveness and relative scaling
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Import Product model class for data typing and structure
import '../models/product.dart';

// Import ProductService class to fetch products from external REST API endpoint
import '../services/product_service.dart';

// Import CustomText widget for consistent typography styling
import '../widgets/custom_text.dart';

// Enhancement 2: Import ProductDetailScreen for product card tap navigation
import 'detail_screen.dart';

// Primary screen component displaying product catalog list and interactive search bar
class ProductScreen extends StatefulWidget {
  // Constructor initializing ProductScreen stateful widget
  const ProductScreen({super.key});

  // Creates mutable state instance for ProductScreen widget
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

// State class managing async product loading, search filtering, and grid layout rendering
class _ProductScreenState extends State<ProductScreen> {
  // Future variable holding asynchronous product list API fetch operation
  late Future<List<Product>> _productsFuture;

  // Complete master list of products fetched from the API endpoint
  List<Product> _allProducts = [];

  // Filtered subset list of products matching user search input query
  List<Product> _filteredProducts = [];
  
  // Enhancement 1: TextEditingController for managing search input field text state
  final TextEditingController _searchController = TextEditingController();

  // Enhancement 1: String storing active user search filter query
  String _searchQuery = '';

  // Lifecycle method initializing API data fetch operation when widget enters tree
  @override
  void initState() {
    super.initState();

    // Initiates async product retrieval operation via ProductService API client
    _productsFuture = ProductService().getAllProducts();
  }

  // Lifecycle method disposing search text controller to release system resources
  @override
  void dispose() {
    // Releases text editing controller listener bindings
    _searchController.dispose();
    super.dispose();
  }

  // Enhancement 1: Filtering logic executed whenever user types in search input field
  void _filterProducts(String query) {
    // Triggers local component rebuild with updated search filter state
    setState(() {
      _searchQuery = query;

      // Restores full product list if search query input is empty
      if (query.isEmpty) {
        _filteredProducts = List.from(_allProducts);
      } else {
        // Filters products matching title, category, or brand against search query
        _filteredProducts = _allProducts.where((product) {
          final titleMatches = product.title.toLowerCase().contains(query.toLowerCase());
          final categoryMatches = product.category.toLowerCase().contains(query.toLowerCase());
          final brandMatches = product.brand.toLowerCase().contains(query.toLowerCase());
          return titleMatches || categoryMatches || brandMatches;
        }).toList();
      }
    });
  }

  // Builds and returns search bar header and responsive product grid view
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Enhancement 1: Search Bar container input field positioned above product grid list
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                // Enhancement 1: TextField capturing real-time user search input
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterProducts,
                  decoration: InputDecoration(
                    hintText: 'Search products by title, category...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    // Renders clear button suffix icon when search query is non-empty
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _filterProducts('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 8.h),

            // Async FutureBuilder resolving API connection states and rendering grid
            FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                // Renders centered loading spinner while waiting for API network response
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // Renders error message widget if API fetch operation failed
                if (snapshot.hasError) {
                  return Center(
                    child: CustomText(
                      text: 'Error: ${snapshot.error}',
                      fontSize: 14.sp,
                    ),
                  );
                }

                // Caches master product list data on initial successful API snapshot arrival
                if (_allProducts.isEmpty && snapshot.hasData) {
                  _allProducts = snapshot.data ?? [];
                  _filteredProducts = List.from(_allProducts);
                }

                // Renders empty state message if no products match active search query
                if (_filteredProducts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: CustomText(
                        text: 'No products found.',
                        fontSize: 14.sp,
                      ),
                    ),
                  );
                }

                // GridView builder populating 2-column grid of product card items
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredProducts.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    // Current product model entry for this grid index item
                    final product = _filteredProducts[index];
                    
                    // Enhancement 2: Product Card item wrapped with InkWell for click handling
                    return Card(
                      elevation: 2,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: InkWell(
                        // Enhancement 2: Navigates user to ProductDetailScreen on card tap
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(product: product),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             // Expanded container displaying product thumbnail image
                             Expanded(
                               child: Image.network(
                                 product.thumbnail,
                                 width: double.infinity,
                                 fit: BoxFit.cover,
                                 errorBuilder: (context, error, stackTrace) => Icon(
                                   Icons.image,
                                   size: 24.sp,
                                 ),
                               ),
                             ),

                            // Padding wrapper holding product title and price text
                            Padding(
                              padding: EdgeInsets.all(8.r),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product title text label truncated with ellipsis overflow
                                  CustomText(
                                    text: product.title,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  // Formatted product price tag label
                                  CustomText(
                                    text: '\$${product.price.toStringAsFixed(2)}',
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
