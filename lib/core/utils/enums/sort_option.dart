/// Defines sorting options for the product catalog
enum SortOption {
  featured('Featured'),
  priceLowToHigh('Price: Low to High'),
  priceHighToLow('Price: High to Low'),
  ratingHighToLow('Customer Rating');

  final String label;
  const SortOption(this.label);
}
