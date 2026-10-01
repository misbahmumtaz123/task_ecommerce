/// Centralized API constants for DummyJSON endpoints and configuration
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://dummyjson.com';

  // Endpoints
  static const String products = '/products';
  static const String searchProducts = '/products/search';
  static const String categories = '/products/categories';
  static const String categoryProducts = '/products/category';
  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';
  static const String usersAdd = '/users/add';

  // Network timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
