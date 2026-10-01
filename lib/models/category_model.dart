/// Represents a product category from DummyJSON
class CategoryModel {
  final String slug;
  final String name;
  final String? url;

  const CategoryModel({
    required this.slug,
    required this.name,
    this.url,
  });

  factory CategoryModel.fromJson(dynamic json) {
    if (json is String) {
      return CategoryModel(
        slug: json,
        name: _capitalize(json.replaceAll('-', ' ')),
      );
    }

    if (json is Map<String, dynamic>) {
      return CategoryModel(
        slug: json['slug'] as String? ?? '',
        name: json['name'] as String? ?? '',
        url: json['url'] as String?,
      );
    }

    return const CategoryModel(slug: '', name: '');
  }

  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join(' ');
  }
}
