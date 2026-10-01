import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';

/// StateProvider holding the list of fetched categories
final categoryListProvider = StateProvider<List<CategoryModel>>((ref) => []);
