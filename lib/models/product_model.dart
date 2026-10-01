/// Represents product dimensions from DummyJSON
class ProductDimensionsModel {
  final double width;
  final double height;
  final double depth;

  const ProductDimensionsModel({
    this.width = 0.0,
    this.height = 0.0,
    this.depth = 0.0,
  });

  factory ProductDimensionsModel.fromJson(Map<String, dynamic> json) {
    return ProductDimensionsModel(
      width: (json['width'] as num?)?.toDouble() ?? 0.0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      depth: (json['depth'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'depth': depth,
    };
  }

  String get formatted =>
      '${width.toStringAsFixed(1)} × ${height.toStringAsFixed(1)} × ${depth.toStringAsFixed(1)} cm';

  bool get hasDimensions => width > 0 || height > 0 || depth > 0;
}

/// Represents a customer review from DummyJSON
class ProductReviewModel {
  final int rating;
  final String comment;
  final String date;
  final String reviewerName;
  final String reviewerEmail;

  const ProductReviewModel({
    required this.rating,
    required this.comment,
    required this.date,
    required this.reviewerName,
    required this.reviewerEmail,
  });

  factory ProductReviewModel.fromJson(Map<String, dynamic> json) {
    return ProductReviewModel(
      rating: (json['rating'] as num?)?.toInt() ??
          int.tryParse(json['rating']?.toString() ?? '0') ??
          0,
      comment: json['comment']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      reviewerName: json['reviewerName']?.toString() ?? 'Shopper',
      reviewerEmail: json['reviewerEmail']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
      'date': date,
      'reviewerName': reviewerName,
      'reviewerEmail': reviewerEmail,
    };
  }
}

/// Represents a product item from DummyJSON with full specification data
class ProductModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String? brand;
  final String thumbnail;
  final List<String> images;
  final String? warrantyInformation;
  final String? shippingInformation;
  final String? availabilityStatus;
  final String? returnPolicy;
  final int? minimumOrderQuantity;
  final String? sku;
  final num? weight;
  final ProductDimensionsModel? dimensions;
  final String? barcode;
  final String? qrCode;
  final List<String> tags;
  final List<ProductReviewModel> reviews;

  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    this.discountPercentage = 0.0,
    this.rating = 0.0,
    this.stock = 0,
    this.brand,
    required this.thumbnail,
    this.images = const [],
    this.warrantyInformation,
    this.shippingInformation,
    this.availabilityStatus,
    this.returnPolicy,
    this.minimumOrderQuantity,
    this.sku,
    this.weight,
    this.dimensions,
    this.barcode,
    this.qrCode,
    this.tags = const [],
    this.reviews = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    ProductDimensionsModel? parsedDimensions;
    if (json['dimensions'] is Map) {
      parsedDimensions = ProductDimensionsModel.fromJson(
        Map<String, dynamic>.from(json['dimensions'] as Map),
      );
    }

    String? parsedBarcode;
    String? parsedQrCode;
    if (json['meta'] is Map) {
      final meta = json['meta'] as Map;
      parsedBarcode = meta['barcode']?.toString();
      parsedQrCode = meta['qrCode']?.toString();
    }

    return ProductModel(
      id: (json['id'] as num?)?.toInt() ??
          int.tryParse(json['id']?.toString() ?? '0') ??
          0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      brand: json['brand']?.toString(),
      thumbnail: json['thumbnail']?.toString() ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .where((url) => url.trim().isNotEmpty)
              .toList() ??
          [],
      warrantyInformation: json['warrantyInformation']?.toString(),
      shippingInformation: json['shippingInformation']?.toString(),
      availabilityStatus: json['availabilityStatus']?.toString(),
      returnPolicy: json['returnPolicy']?.toString(),
      minimumOrderQuantity: (json['minimumOrderQuantity'] as num?)?.toInt(),
      sku: json['sku']?.toString(),
      weight: json['weight'] as num?,
      dimensions: parsedDimensions,
      barcode: parsedBarcode,
      qrCode: parsedQrCode,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      reviews: (json['reviews'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((r) =>
                  ProductReviewModel.fromJson(Map<String, dynamic>.from(r)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'brand': brand,
      'thumbnail': thumbnail,
      'images': images,
      'warrantyInformation': warrantyInformation,
      'shippingInformation': shippingInformation,
      'availabilityStatus': availabilityStatus,
      'returnPolicy': returnPolicy,
      'minimumOrderQuantity': minimumOrderQuantity,
      'sku': sku,
      'weight': weight,
      'dimensions': dimensions?.toJson(),
      'meta': {
        if (barcode != null) 'barcode': barcode,
        if (qrCode != null) 'qrCode': qrCode,
      },
      'tags': tags,
      'reviews': reviews.map((r) => r.toJson()).toList(),
    };
  }

  /// Calculates the original price before discount
  double get originalPrice {
    if (discountPercentage <= 0) return price;
    return price / (1 - (discountPercentage / 100));
  }

  /// Calculates savings in dollars
  double get savingsAmount {
    if (discountPercentage <= 0) return 0.0;
    return originalPrice - price;
  }
}
