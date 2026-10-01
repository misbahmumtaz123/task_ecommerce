import 'package:get/get.dart';
import '../network/api_client.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/detail_controller.dart';
import '../../controllers/favorites_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/product_repository.dart';
import '../../services/auth_api_service.dart';
import '../../services/product_api_service.dart';

/// Central dependency injection orchestrator that initializes
/// networking, repositories, and GetX controllers cleanly and without conflict.
class AppDependencies {
  final ApiClient apiClient;
  final ProductApiService productApiService;
  final ProductRepository productRepository;
  final AuthApiService authApiService;
  final AuthRepository authRepository;

  AppDependencies({
    required this.apiClient,
    required this.productApiService,
    required this.productRepository,
    required this.authApiService,
    required this.authRepository,
  });

  /// Factory method to initialize all application singletons and GetX dependencies
  static AppDependencies init({
    ApiClient? apiClient,
    ProductRepository? productRepository,
    AuthRepository? authRepository,
  }) {
    final client = apiClient ?? ApiClient();
    final pService = ProductApiServiceImpl(client: client);
    final pRepo = productRepository ?? ProductRepositoryImpl(apiService: pService);

    final aService = AuthApiServiceImpl(client: client);
    final aRepo = authRepository ?? AuthRepositoryImpl(apiService: aService);

    // Register Repositories in GetX for easy lookup by bindings/controllers
    if (!Get.isRegistered<ProductRepository>()) {
      Get.put<ProductRepository>(pRepo, permanent: true);
    }
    if (!Get.isRegistered<AuthRepository>()) {
      Get.put<AuthRepository>(aRepo, permanent: true);
    }
    if (!Get.isRegistered<NavigationController>()) {
      Get.put<NavigationController>(NavigationController(), permanent: true);
    }

    // Register GetX Controllers safely as permanent singletons
    if (!Get.isRegistered<FavoritesController>()) {
      Get.put<FavoritesController>(FavoritesController(), permanent: true);
    }
    if (!Get.isRegistered<DetailController>()) {
      Get.put<DetailController>(DetailController(pRepo), permanent: true);
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(authRepository: aRepo), permanent: true);
    }

    return AppDependencies(
      apiClient: client,
      productApiService: pService,
      productRepository: pRepo,
      authApiService: aService,
      authRepository: aRepo,
    );
  }
}
