class ApiConstants {
  ApiConstants._();
  static const String baseUrl = 'https://dummyjson.com';
  static const String products = '/products';
  static const String searchProducts = '/products/search';
  static const String categories = '/products/categories';
  static const String categoryProducts = '/products/category';
  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';
  static const String usersAdd = '/users/add';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
