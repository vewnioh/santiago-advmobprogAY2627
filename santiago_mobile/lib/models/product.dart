// Main data model representing a single product fetched from the API
class Product {
  // Unique numeric identifier for the product
  final int id;

  // Title name of the product
  final String title;

  // Detailed textual description of the product
  final String description;

  // Product category classification
  final String category;

  // Retail price of the product in USD
  final double price;

  // Percentage discount applied to the product price
  final double discountPercentage;

  // Average user rating score out of 5.0
  final double rating;

  // Total quantity of units available in stock
  final int stock;

  // List of descriptive search tags associated with the product
  final List<String> tags;

  // Brand name or manufacturer of the product
  final String brand;

  // Stock keeping unit code for inventory tracking
  final String sku;

  // Weight of the product in kilograms
  final double weight;

  // Physical dimensions object containing width, height, and depth
  final ProductDimensions? dimensions;

  // Terms and details regarding warranty coverage
  final String warrantyInformation;

  // Estimated delivery and shipping details
  final String shippingInformation;

  // Stock availability status text
  final String availabilityStatus;

  // List of customer reviews and ratings
  final List<ProductReview>? reviews;

  // Return and exchange policy details
  final String returnPolicy;

  // Minimum required quantity per order
  final int minimumOrderQuantity;

  // Metadata object containing creation date, barcodes, and QR codes
  final ProductMeta? meta;

  // List of full-resolution image URLs for the product
  final List<String> images;

  // Thumbnail image URL used for list displays
  final String thumbnail;

  // Constructor initializing all required product fields
  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.tags,
    required this.brand,
    required this.sku,
    required this.weight,
    required this.dimensions,
    required this.warrantyInformation,
    required this.shippingInformation,
    required this.availabilityStatus,
    required this.reviews,
    required this.returnPolicy,
    required this.minimumOrderQuantity,
    required this.meta,
    required this.images,
    required this.thumbnail,
  });

  // Factory constructor deserializing JSON map data into a strongly-typed Product object
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      brand: json['brand'] ?? '',
      sku: json['sku'] ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      dimensions: json['dimensions'] != null
          ? ProductDimensions.fromJson(json['dimensions'])
          : null,
      warrantyInformation: json['warrantyInformation'] ?? '',
      shippingInformation: json['shippingInformation'] ?? '',
      availabilityStatus: json['availabilityStatus'] ?? '',
      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((e) => ProductReview.fromJson(e)).toList()
          : null,
      returnPolicy: json['returnPolicy'] ?? '',
      minimumOrderQuantity: json['minimumOrderQuantity'] ?? 0,
      meta: json['meta'] != null ? ProductMeta.fromJson(json['meta']) : null,
      images: List<String>.from(json['images'] ?? []),
      thumbnail: json['thumbnail'] ?? '',
    );
  }
}

// Data model representing physical product dimensions
class ProductDimensions {
  // Product width measurement
  final double width;

  // Product height measurement
  final double height;

  // Product depth measurement
  final double depth;

  // Constructor initializing physical product dimension values
  ProductDimensions({
    required this.width,
    required this.height,
    required this.depth,
  });

  // Factory constructor deserializing JSON data into ProductDimensions instance
  factory ProductDimensions.fromJson(Map<String, dynamic> json) {
    return ProductDimensions(
      width: (json['width'] as num?)?.toDouble() ?? 0.0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      depth: (json['depth'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// Data model representing individual customer product reviews
class ProductReview {
  // Numerical rating score given by the reviewer
  final int rating;

  // Review comment text submitted by the user
  final String comment;

  // ISO timestamp string when the review was submitted
  final String date;

  // Full name of the customer reviewer
  final String reviewerName;

  // Contact email address of the reviewer
  final String reviewerEmail;

  // Constructor initializing review details
  ProductReview({
    required this.rating,
    required this.comment,
    required this.date,
    required this.reviewerName,
    required this.reviewerEmail,
  });

  // Factory constructor deserializing JSON data into ProductReview instance
  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      date: json['date'] ?? '',
      reviewerName: json['reviewerName'] ?? '',
      reviewerEmail: json['reviewerEmail'] ?? '',
    );
  }
}

// Data model representing system metadata for a product
class ProductMeta {
  // Timestamp string recording product creation date
  final String createdAt;

  // Timestamp string recording last product update date
  final String updatedAt;

  // Barcode identification string
  final String barcode;

  // QR code string representation
  final String qrCode;

  // Constructor initializing metadata properties
  ProductMeta({
    required this.createdAt,
    required this.updatedAt,
    required this.barcode,
    required this.qrCode,
  });

  // Factory constructor deserializing JSON data into ProductMeta instance
  factory ProductMeta.fromJson(Map<String, dynamic> json) {
    return ProductMeta(
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      barcode: json['barcode'] ?? '',
      qrCode: json['qrCode'] ?? '',
    );
  }
}
