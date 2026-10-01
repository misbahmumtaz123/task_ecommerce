import '../network/api_client.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/product_repository.dart';
import '../../services/auth_api_service.dart';
import '../../services/product_api_service.dart';
import 'app_dependencies.dart';

/// AppInitializer encapsulates all data layer, network layer,
/// and GetX dependency instantiations, returning a configured [AppDependencies] container.
class AppInitializer {
  /// Encapsulates initialization of ApiClient, services, repositories, and GetX dependencies.
  /// Returns the configured [AppDependencies] bundle to main.dart.
  static Future<AppDependencies> init({
    ApiClient? apiClient,
    ProductRepository? productRepository,
    AuthRepository? authRepository,
  }) async {
    // 1. Instantiation of networking layer
    final client = apiClient ?? ApiClient();

    // 2. Instantiation of API service layer
    final pService = ProductApiServiceImpl(client: client);
    final aService = AuthApiServiceImpl(client: client);

    // 3. Instantiation of Repository layer
    final pRepo = productRepository ?? ProductRepositoryImpl(apiService: pService);
    final aRepo = authRepository ?? AuthRepositoryImpl(apiService: aService);

    // 4. Handle GetX dependency registration
    final dependencies = AppDependencies.init(
      apiClient: client,
      productRepository: pRepo,
      authRepository: aRepo,
    );

    return dependencies;
  }
}
