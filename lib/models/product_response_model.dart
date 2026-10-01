import 'product_model.dart';

/// Paginated product response from DummyJSON (/products).
/// Parses metadata fields [total], [skip], and [limit] to accurately track pagination state.
class ProductResponseModel {
  final List<ProductModel> products;
  final int total;
  final int skip;
  final int limit;

  const ProductResponseModel({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductResponseModel.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'] as List<dynamic>? ?? [];
    return ProductResponseModel(
      products: rawProducts
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      skip: (json['skip'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
    );
  }

  /// Helper to check if there are more items to load across infinite scrolls or pages
  bool get hasMore => (skip + products.length) < total;

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((p) => p.toJson()).toList(),
      'total': total,
      'skip': skip,
      'limit': limit,
    };
  }
}
