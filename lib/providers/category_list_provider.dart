import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';

final categoryListProvider = StateProvider<List<CategoryModel>>((ref) => []);
