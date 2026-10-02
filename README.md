# AuraStore - Flutter eCommerce Application

A production-ready eCommerce mobile application built with **Flutter**, showcasing **Clean Architecture**, public **DummyJSON REST API** integration, robust error handling, and a hybrid state management architecture leveraging **Riverpod** for catalog/search/pagination and **GetX** for product details, favorites synchronization, and authentication.

---

## 📋 Table of Contents
- [Project Overview](#-project-overview)
- [Project Setup & Installation](#-project-setup--installation)
- [Architecture & Flow](#-architecture--flow)
- [State Management Architecture](#-state-management-architecture)
  - [Riverpod (Product Listing)](#1-riverpod-product-listing)
  - [GetX (Details, Favorites & Auth)](#2-getx-details-favorites--auth)
  - [Provider (Shopping Cart)](#3-provider-shopping-cart)
- [API Layer & Integration](#-api-layer--integration)
- [Key Features](#-key-features)
- [Testing Suite](#-testing-suite)
- [Release APK Submission](#-release-apk-submission)

---

## 🌟 Project Overview
- **Framework**: Flutter (Dart 3.x, Null-Safe)
- **API Backend**: Public [DummyJSON REST API](https://dummyjson.com/)
- **State Management**:
  - **Riverpod**: Product catalog, search with debounce, category filtering, infinite scroll pagination, and pull-to-refresh.
  - **GetX**: Cross-screen reactive Favorites synchronization, Product Details by ID, and Authentication session flow.
  - **Provider**: Shopping cart state and real-time total calculations.
- **Design System**: Responsive UI, glassmorphic elements, Google Fonts, Tutorial Coach Marks, and native Android/iOS launcher icons.

---

## 🚀 Project Setup & Installation

### Prerequisites
- **Flutter SDK**: `^3.19.0` or higher (tested on Flutter `3.38.x` / `3.10.x`)
- **Dart SDK**: `^3.3.0` or higher
- **Android Studio** or **VS Code** with Flutter & Dart extensions
- **Android SDK** (API Level 21+) / Android Emulator or Physical Device

### Step-by-Step Setup
1. **Clone the repository**:
   ```bash
   git clone https://github.com/misbahmumtaz123/task_ecommerce.git
   cd task_ecommerce
   ```

2. **Install project dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify static analysis**:
   ```bash
   flutter analyze
   ```
   *(Expected output: `No issues found!`)*

4. **Run the automated test suite**:
   ```bash
   flutter test --concurrency=1
   ```
   *(Expected output: `All 44 tests passed!`)*

5. **Run the application**:
   ```bash
   flutter run
   ```

---

## 🏗️ Architecture & Flow

### Architecture Flow
The application strictly enforces separation of concerns so that UI widgets never contain direct API or business logic:

```
┌─────────────────────────────────────────────────────────────┐
│                          UI Layer                           │
│   (Screens, Custom Widgets, Form Inputs, Dialogs)           │
└──────────────┬──────────────────────────────┬───────────────┘
               │                              │
               ▼                              ▼
┌──────────────────────────────┐┌─────────────────────────────┐
│     Riverpod State Layer     ││      GetX State Layer       │
│ (ProductListNotifier, State) ││ (Favorites, Detail, Auth)   │
└──────────────┬───────────────┘└─────────────┬───────────────┘
               │                              │
               └──────────────┬───────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Repository Layer                       │
│  (ProductRepository: contract & concrete implementation)    │
└─────────────────────────────┬───────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      API Service Layer                      │
│       (ApiClient, ProductApiService, Error Handling)        │
└─────────────────────────────┬───────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    DummyJSON REST API                       │
│           (https://dummyjson.com/products/...)              │
└─────────────────────────────────────────────────────────────┘
```

### Folder Structure
```
lib/
├── core/
│   ├── constants/             # AppColors, ApiEndpoints, Asset paths
│   ├── network/               # ApiClient, HTTP interceptors & error handlers
│   ├── routing/               # AppRouter & named navigation routes
│   ├── theme/                 # Typography and component themes
│   └── utils/                 # Enums (SortOption), Result wrapper, and Validators
├── models/                    # Immutable JSON models (Product, Category, User, Pagination)
├── repositories/              # ProductRepository interface & concrete implementation
├── services/                  # ProductApiService, AuthApiService, TutorialService
├── providers/                 # Riverpod notifiers, ProductListState, CartProvider
├── controllers/               # GetX controllers (Favorites, Detail, Auth, Onboarding)
├── screens/                   # UI Screens (Splash, Onboarding, Auth, Catalog, Detail, Cart, Favorites)
├── widgets/                   # Reusable UI components (ProductCard, SearchBar, CategorySelector)
└── main.dart                  # Dependency injection & bootstrap initializer
```

---

## ⚡ State Management Architecture

### 1. Riverpod (Product Listing)
Riverpod is used for the complete Product Listing feature because of its compile-time safety, unidirectional data flow, and granular rebuild control.

- **Why Riverpod for Product Listing?**:
  - Handles complex asynchronous catalog state (loading, error, empty, pagination) predictably.
  - Keeps state immutable through `ProductListState` data classes.
  - Allows easy testing through dependency injection overrides without mocking entire widgets.

- **Providers & Notifiers Created**:
  - `productRepositoryProvider`: Declares the repository instance accessible to notifiers.
  - `productListNotifierProvider`: `StateNotifierProvider<ProductListNotifier, ProductListState>` managing catalog items, search query, category slug, sorting, and pagination counters.
  - `categoryListNotifierProvider`: Loads and caches available product categories for horizontal chip selection.

- **Modern Riverpod Patterns Demonstrated**:
  - **`ref.watch()`**: Used in `ProductListScreen` to observe `productListNotifierProvider` for rendering the product grid, active filters, and loading/error states.
  - **`ref.read()`**: Used in user event handlers without triggering rebuilds:
    - Scroll listener: `ref.read(productListNotifierProvider.notifier).loadMore();`
    - Search input: `ref.read(productListNotifierProvider.notifier).setSearch(query);`
    - Category chips: `ref.read(productListNotifierProvider.notifier).setCategory(slug);`
    - Pull-to-refresh: `ref.read(productListNotifierProvider.notifier).refresh();`
  - **`ref.listen()`**: Listens to state transitions to trigger temporary feedback (e.g. snackbars on pagination error) without modifying UI tree state.
  - **Rebuild Optimization with `select()`**:
    - `ref.watch(productListNotifierProvider.select((s) => s.isLoadingMore))`: Limits rebuilds of the bottom loading spinner only when pagination loading toggles, keeping the main grid static.
    - `ref.watch(productListNotifierProvider.select((s) => s.products.length))`: Rebuilds the product count badge only when total count changes.

---

### 2. GetX (Details, Favorites & Auth)
GetX is leveraged for Product Details, Favorites, and Authentication for high-performance reactive state (`.obs` & `Obx`) and cross-screen synchronization.

- **Why GetX for Details & Favorites?**:
  - Provides instant cross-screen state propagation between Product List, Product Details, and Favorites screens without passing callbacks through the widget tree.
  - Allows micro-reactive widgets (`Obx`) to rebuild only the heart icon rather than rebuilding the entire screen or product card.

- **Controllers Created**:
  - `FavoritesController`: Manages an observable list (`RxList<ProductModel>`). Exposes `isFavorite(id)`, `toggleFavorite(product)`, and `removeFavorite(id)`.
  - `DetailController`: Manages the state of the active product detail screen, fetching by product ID, tracking selected image carousel index, and handling fallback data.
  - `AuthController`: Manages user authentication state, demo credentials auto-fill, and session logout.
  - `LoginController` & `RegisterController`: Handle form inputs, reactivity, and strict input validation rules.

- **Dependency Injection**:
  - `Get.put<FavoritesController>(FavoritesController(), permanent: true)`: Registered as a permanent singleton at app startup so favorite state persists across all screens.
  - `Get.lazyPut()` / `Get.put(DetailController(id))`: Cleanly injected for each detail screen lifecycle.
  - `Get.find<FavoritesController>()`: Efficiently located inside `ProductCard` and `ProductDetailScreen`.

- **Controller Lifecycle Management**:
  - `onInit()`: Initializes controller listeners and automatically triggers API fetching by ID.
  - `onClose()`: Automatically frees memory, disposes timers, and tears down reactive subscriptions when navigating away.
  - `Obx()`: Targeted reactive wrapping around favorite heart icons and image gallery indicators.

---

### 3. Provider (Shopping Cart)
- `CartProvider`: Extends `ChangeNotifier` to manage shopping cart items, quantity increments/decrements, item removal, and subtotal/tax/shipping calculations.
- Integrated with protected guest checkout modal prompting users to sign in.

---

## 🌐 API Layer & Integration

Interacts directly with the public **DummyJSON REST API** using an abstract repository pattern:

| Endpoint | Method | Purpose in Application |
|---|---|---|
| `/products?limit={limit}&skip={skip}` | `GET` | Catalog browsing with pagination (`limit: 6`). |
| `/products/search?q={query}` | `GET` | Live search with 500ms debounce. |
| `/products/{id}` | `GET` | Detailed product specifications fetched by ID. |
| `/products/categories` | `GET` | Category filter chips. |
| `/products/category/{slug}` | `GET` | Products filtered by category. |

### Error Handling & Resilience
- **Result Pattern**: All repository calls return a `Result<T>` sealed class (`Success<T>` or `Failure<Exception>`), eliminating uncaught exceptions.
- **State Views**: Dedicated `LoadingView`, `ErrorView` (with a retry button), and `EmptyView` with custom iconography and messaging.
- **No Silently Swallowed Exceptions**: Errors are surfaced to the UI with user-friendly descriptions and retry mechanisms.

---

## ✨ Key Features

### 1. Search & Pagination
- **Debounced Live Search**: Search input debounced by 500ms using a `Timer` to prevent unnecessary API requests.
- **Infinite Scroll Pagination**: Initially fetches **6 products**, then loads the **next 6 products** when the user scrolls within 300px of the bottom.
- **Automatic Exhaustion Check**: `hasNextPage` checks `total` vs loaded products, cleanly stopping requests once all items are fetched.

### 2. Product Details Experience
- **Fetch by ID**: Product details are fetched using the ID endpoint rather than simply relying on passed data.
- **Equal-Sized Specification Containers**: Stock Status, Shipping Information, Warranty Policy, and Return Policy styled in uniform 84px responsive cards.
- **'NEW' Tag Badge**: Product images feature an elegant 'NEW' badge overlay.
- **Interactive Carousel**: Thumbnail selector with active index indicator and full-screen zoom support.

### 3. Synchronized Favorites (Wishlist)
- Instant synchronization across **Product List ↔ Product Details ↔ Favorites Screen**.
- Immediate visual reflection via GetX `Obx` without lag or screen refresh.

### 4. Tutorial Coach Mark
- First-time user onboarding coach mark highlighting key features:
  - Search Bar
  - Category Filters
  - Sort Dropdown
  - Favorites Button
  - Cart Button
  - Profile / Account Button
- Persisted locally with `SharedPreferences` so it only displays once.

### 5. Responsive Onboarding & Form Validation
- **Responsive Layout**: Designed with `LayoutBuilder` and `IntrinsicHeight` ensuring zero bottom dead space on compact or tall mobile displays.
- **Fixed Name Fields**: First Name and Last Name fields stay perfectly aligned and responsive across all device widths.
- **Strict Password Validation**: Requires 8+ characters, at least 1 uppercase letter, at least 1 digit, and at least 1 special character.
- **Seamless Flow**: Directs to Sign In page after logout and registration.

### 6. Clear Cart Dialog
- Modern rounded `AlertDialog` with top circular warning badge and two stylish buttons:
  - **Cancel**: Outlined button with soft surface fill.
  - **Clear**: Elevated button in danger red with trash icon and subtle drop shadow.

---

## 🧪 Testing Suite

The project includes **44 automated tests** covering unit, repository, controller, and widget logic:

```bash
# Run the entire test suite
flutter test --concurrency=1

# Run individual test files
flutter test test/validators_test.dart
flutter test test/auth_controller_test.dart
flutter test test/detail_controller_test.dart
flutter test test/favorites_controller_test.dart
flutter test test/product_repository_test.dart
flutter test test/cart_screen_test.dart
flutter test test/product_detail_screen_test.dart
flutter test test/onboarding_screen_test.dart
```

### Test Coverage Highlights:
- `validators_test.dart`: Validates email formats and password rules (uppercase, digit, special char, length).
- `auth_controller_test.dart` & `auth_validation_flow_test.dart`: Login, registration, and logout flows.
- `detail_controller_test.dart`: Detail fetching by ID, fallback caching, and image carousel updates.
- `favorites_controller_test.dart`: Adding/removing items and cross-screen sync.
- `product_repository_test.dart`: JSON deserialization and API error mapping.
- `cart_screen_test.dart`: Clear Cart dialog rendering, cancel, and clear actions.
- `product_detail_screen_test.dart`: Equal-sized specs verification, 'NEW' badge display, and reviews rendering.
- `onboarding_screen_test.dart`: Multi-screen aspect ratio responsiveness.
- `widget_test.dart`: End-to-end smoke test.

---

## 📦 Release APK Submission

The standalone release APK is compiled and ready for distribution:

- **Build Command**:
  ```bash
  flutter build apk --release
  ```
- **Generated File**:
  ```
  build/app/outputs/flutter-apk/app-release.apk
  ```
- **APK Size**: ~49.8 MB (52,225,503 bytes)
- **Installation**:
  ```bash
  adb install build/app/outputs/flutter-apk/app-release.apk
  ```

---

## 📄 License
This project is open-source and available under the [MIT License](LICENSE).
