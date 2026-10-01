import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

/// Single item within the shopping cart
class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get subtotal => product.price * quantity;
}

/// Provider managing local user shopping cart state
class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => _items.values.fold(0.0, (sum, item) => sum + item.subtotal);

  bool isInCart(int productId) => _items.containsKey(productId);

  int getQuantity(int productId) => _items[productId]?.quantity ?? 0;

  void addItem(ProductModel product) {
    addItemWithQuantity(product, 1);
  }

  void addItemWithQuantity(ProductModel product, int quantity) {
    if (quantity <= 0) return;
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += quantity;
    } else {
      _items[product.id] = CartItem(product: product, quantity: quantity);
    }
    notifyListeners();
  }

  void removeSingleItem(int productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity -= 1;
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
