# Task eCommerce App

A comprehensive eCommerce mobile application built with Flutter, showcasing clean architecture and state management with Riverpod, Provider, and GetX.

## Features
- **Product Catalog**: Paginated product listing, category filtering, search, and sorting powered by Riverpod.
- **Product Details**: Complete specifications, interactive gallery carousel with image zoom, customer reviews, and quantity controls.
- **Shopping Cart**: Real-time quantity adjustments, price calculations, and item removal managed via Provider.
- **Favorites / Wishlist**: Real-time reactive wishlisting synchronized using GetX.
- **Authentication Flow**: User onboarding, login, register, and guest browsing.

## Tech Stack
- **Framework**: Flutter (Dart)
- **State Management**: Riverpod (catalog/filtering), Provider (shopping cart), GetX (favorites/auth/navigation)
- **Networking**: HTTP client communicating with DummyJSON REST API
- **Testing**: Comprehensive unit and widget tests covering controllers, repositories, and UI screens

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/misbahmumtaz123/task_ecommerce.git
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```
4. Run tests:
   ```bash
   flutter test
   ```
