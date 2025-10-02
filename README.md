# Food Delivery App

A modern, feature-rich food delivery application built with Flutter using BLoC architecture for state management.

## Features

- **Complete Order Workflow**: Restaurant selection → Menu browsing → Cart management → Delivery address → Payment → Order confirmation
- **BLoC Architecture**: Clean separation of business logic and UI with proper state management
- **SOLID Principles**: Well-structured, maintainable code following industry best practices
- **Error Handling**: Comprehensive error handling throughout the workflow
- **Mock Data**: Realistic mock data for testing without API integration
- **Unit Tests**: Complete test coverage for BLoC logic
- **Beautiful UI**: Modern, aesthetically pleasing design with smooth animations

## Screenshots

### Restaurant Selection
The app starts with a list of restaurants showing ratings, delivery times, and fees.
  <img width="412" height="701" alt="Screenshot 2025-10-01 at 1 10 07 PM" src="https://github.com/user-attachments/assets/8761ff18-5d7c-4242-a964-23907d2580e5" />


### Menu Browsing & Cart
Browse menu items by category, add items to cart with quantity controls.
 <img width="443" height="750" alt="Screenshot 2025-10-02 at 10 37 10 PM" src="https://github.com/user-attachments/assets/437f05d2-24b4-4075-89eb-1bc57637418b" />

### Delivery Address
Select from saved addresses or add a new one.
 <img width="442" height="737" alt="Screenshot 2025-10-02 at 10 36 52 PM" src="https://github.com/user-attachments/assets/8034f241-4ee3-4258-b875-bf86be02b9ec" />


### Payment & Order Summary
Choose payment method and review order details.
 <img width="429" height="748" alt="Screenshot 2025-10-02 at 10 37 27 PM" src="https://github.com/user-attachments/assets/9b185328-6d56-4295-995b-dc4be4988181" />

### Order Confirmation
Confirmation screen with order details and tracking information.
 <img width="433" height="748" alt="Screenshot 2025-10-02 at 10 37 39 PM" src="https://github.com/user-attachments/assets/20dfdaba-8b8a-43a6-abc8-d96d748712f2" />


## Architecture

### Project Structure

```
lib/
├── core/
│   └── di/
│       └── service_locator.dart          # Dependency injection
├── data/
│   └── repositories/
│       └── mock_food_repository.dart     # Mock data implementation
├── domain/
│   ├── models/
│   │   └── models.dart                   # Domain models
│   └── repositories/
│       └── food_repository.dart          # Repository interface
└── presentation/
    ├── bloc/
    │   └── order_bloc.dart               # BLoC for state management
    ├── screens/
    │   └── food_order_workflow_screen.dart
    └── widgets/
        ├── restaurant_selection_step.dart
        ├── menu_browsing_step.dart
        ├── delivery_step.dart
        ├── payment_step.dart
        ├── confirmation_step.dart
        ├── progress_indicator_widget.dart
        └── error_dialog.dart
```

### SOLID Principles Implementation

1. **Single Responsibility**: Each class has one clear purpose
   - Models represent data structures
   - BLoC handles business logic
   - Widgets handle UI rendering
   - Repository handles data operations

2. **Open/Closed**: Easy to extend without modification
   - Repository interface allows different implementations
   - BLoC events can be extended for new features

3. **Liskov Substitution**: Repository implementations are interchangeable
   - MockFoodRepository can be replaced with real API implementation

4. **Interface Segregation**: Focused interfaces
   - FoodRepository only contains necessary methods

5. **Dependency Inversion**: Depends on abstractions
   - BLoC depends on repository interface, not concrete implementation
   - Service locator manages dependencies

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd food_delivery_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Running Tests

Execute all unit tests:
```bash
flutter test
```

Run tests with coverage:
```bash
flutter test --coverage
```

## Key Features Explained

### BLoC Architecture

The app uses the BLoC (Business Logic Component) pattern:

- **Events**: User actions trigger events (e.g., `AddToCart`, `PlaceOrder`)
- **States**: UI reacts to state changes from the BLoC
- **Separation**: Business logic is completely separated from UI

### Error Handling

Comprehensive error handling at multiple levels:

- Network errors during data fetching
- Validation errors (empty cart, missing address)
- Payment processing failures (simulated 10% failure rate)
- User-friendly error dialogs with clear messages

### State Management

The OrderState manages:
- Current workflow step
- Selected restaurant and menu items
- Shopping cart with quantities
- Delivery address selection
- Payment method selection
- Loading and error states

### Mock Data

Realistic mock data includes:
- 5 restaurants with different cuisines
- 8 food items with categories
- 3 delivery addresses
- 4 payment methods
- Simulated network delays
- Random order failures for testing

## Dependencies

```yaml
dependencies:
   flutter_bloc: ^8.1.3    # State management
   equatable: ^2.0.5        # Value equality
   collection: ^1.18.0      # Collection utilities

dev_dependencies:
   bloc_test: ^9.1.4        # BLoC testing
   mocktail: ^1.0.0         # Mocking
   flutter_lints: ^2.0.0    # Linting
```

## Future Enhancements

- Real API integration
- User authentication
- Order tracking with real-time updates
- Restaurant search and filters
- Favorites and order history
- Push notifications
- Multiple language support
- Dark mode

## License

This project is created for educational purposes.

## Author

Developed as a demonstration of Flutter BLoC architecture and SOLID principles.
