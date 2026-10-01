# AuraStore - Modern Flutter eCommerce App

A production-grade, feature-rich eCommerce mobile application built with **Flutter**, demonstrating **Clean Architecture** and a harmonious multi-state-management approach using **Riverpod**, **Provider**, and **GetX**.

---

## 🌟 Key Features

### 🛍️ 1. Product Catalog & Discovery
- **Fixed Header Layout**: Search bar, category filter chips, active product count, and sort controls remain fixed at the top while only catalog items scroll.
- **Dynamic Category Filtering**: Seamless switching between categories with an instant "All" reset filter.
- **Glassmorphic Sort Dropdown**: Modern floating frosted-glass container with clean sort options (Default, Price: Low to High, Price: High to Low, Rating, Title).
- **Search & Pagination**: Live search with debounce and infinite-scroll pagination fetching from DummyJSON REST API.

### 🔍 2. Product Detail Experience
- **Interactive Image Gallery**: High-resolution gallery carousel with thumbnail selection and full-screen zoomable photo viewer.
- **Clean Specifications**: Streamlined product specifications focusing on key purchase decision factors (Stock status, Shipping information, Return & Warranty policies).
- **Customer Reviews**: Dynamic star rating breakdown with user review cards and formatted dates.
- **Auto-Dismissing Feedback**: Floating "Added to Cart" notification with View Cart action that automatically dismisses on timeout or when navigating across screens.

### 🛒 3. Shopping Cart & Checkout Protection
- **Real-Time Cart Management**: Quantity increments, decrements, item deletion, and live subtotal/total calculations powered by Provider.
- **Guest Checkout Restriction**: Seamless guest browsing with protected checkout—clicking "Proceed to Checkout" as a guest triggers an interactive "Sign In Required" modal prompt guiding the user to authenticate before completing the order.

### 💖 4. Reactive Favorites / Wishlist
- **Instant Synchronization**: Double-tap and heart-icon toggling with instant cross-screen synchronization using GetX reactive state (`.obs` & `Obx`).

### 🔐 5. Modern Authentication Flow
- **Fixed Viewport Sign In**: Streamlined, non-scrollable Sign In screen layout with zero overflow across screen sizes and keyboard-safe bottom inset handling.
- **Quick-Fill Demo Credentials**: One-tap demo account fill (`emilys` / `emilyspass`) for instant testing.
- **Unified Form Styling**: Matching input decoration, font scales, icon dimensions, and button sizing across Sign In and Sign Up (`register_screen.dart`).

### 🎨 6. Branding & Design
- **Custom Launcher Icons**: Native launcher icons generated and deployed across all Android mipmap densities (`hdpi`, `mdpi`, `xhdpi`, `xxhdpi`, `xxxhdpi`).
- **Timed Splash Screen**: Elegant branding splash screen guaranteed to display for at least 3.0 seconds before smoothly transitioning.

---

## 🏗️ Architecture & State Management

The application adheres strictly to Clean Architecture principles with separation of concerns:

```
lib/
├── app.dart                   # Application entry widget & theme configuration
├── main.dart                  # Dependency injection & bootstrap initializer
├── core/
│   ├── constants/             # AppColors, ApiEndpoints, Asset paths
│   ├── network/               # ApiClient, HTTP interceptors & error handlers
│   ├── routing/               # AppRouter & named navigation routes
│   ├── theme/                 # AppTheme typography and component themes
│   └── utils/                 # Enums, formatters, and helper extensions
├── models/                    # Immutable JSON data models
├── repositories/              # Repository interfaces & concrete implementations
├── services/                  # Network API service layer (DummyJSON)
├── providers/                 # Riverpod notifiers & Provider ChangeNotifier (Cart)
├── controllers/               # GetX controllers (Auth, Detail, Favorites)
├── screens/                   # UI Screens (Splash, Onboarding, Auth, Catalog, Detail, Cart, Favorites)
└── widgets/                   # Reusable UI components & custom widgets
```

### State Management Synergy:
| Technology | Responsibility |
|---|---|
| **Riverpod** | Product catalog state, pagination, category filtering, search queries, and sorting. |
| **Provider** | Shopping cart state, quantity increments, item removals, and total calculations. |
| **GetX** | Authentication state, user session, favorites synchronization, and reactive UI dialogs. |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.19.0 or higher / tested on Flutter 3.38.x)
- Dart SDK (v3.3.0 or higher)
- Android Studio / VS Code with Flutter extension
- An Android Emulator or physical device

### Installation
1. **Clone the repository**:
   ```bash
   git clone https://github.com/misbahmumtaz123/task_ecommerce.git
   cd task_ecommerce
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify analyzer**:
   ```bash
   flutter analyze
   ```

4. **Run the test suite**:
   ```bash
   flutter test
   ```

5. **Launch the application**:
   ```bash
   flutter run
   ```

---

## 🧪 Automated Testing

Comprehensive test suite covering unit, repository, controller, and widget tests:
- `auth_controller_test.dart`: Authentication state, demo fill, login success, error handling, and logout.
- `detail_controller_test.dart`: Product detail loading, fallback caching, and gallery index updates.
- `favorites_controller_test.dart`: Wishlist toggling, duplicates prevention, and removals.
- `login_screen_test.dart`: Non-scrollable viewport verification, drag assertions, and component rendering.
- `product_repository_test.dart`: JSON deserialization and API error mapping.
- `product_detail_screen_test.dart`: Specs, gallery image counter, and review breakdown.
- `widget_test.dart`: Complete end-to-end app smoke test.

Run all tests:
```bash
flutter test
```

---

## 📄 License
This project is open-source and available under the [MIT License](LICENSE).
