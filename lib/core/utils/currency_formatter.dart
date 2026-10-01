/// Utility class to format prices and discounts
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats a number to USD currency representation: $XX.XX
  static String format(num? value) {
    if (value == null) return r'$0.00';
    return '\$${value.toStringAsFixed(2)}';
  }

  /// Calculates the original price before discount
  static double getOriginalPrice(double price, double discountPercentage) {
    if (discountPercentage <= 0) return price;
    return price / (1 - (discountPercentage / 100));
  }
}
