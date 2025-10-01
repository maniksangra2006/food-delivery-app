import 'dart:math';
import '../../domain/models/models.dart';
import '../../domain/repositories/food_repository.dart';

class MockFoodRepository implements FoodRepository {
  final Random _random = Random();

  @override
  Future<List<Restaurant>> getRestaurants() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockRestaurants;
  }

  @override
  Future<List<FoodItem>> getFoodItemsByRestaurant(String restaurantId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockFoodItems;
  }

  @override
  Future<List<DeliveryAddress>> getDeliveryAddresses() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockAddresses;
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockPaymentMethods;
  }

  @override
  Future<Order> placeOrder({
    required Restaurant restaurant,
    required List<CartItem> items,
    required DeliveryAddress address,
    required PaymentMethod paymentMethod,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    // Simulate occasional failures
    if (_random.nextDouble() < 0.1) {
      throw Exception('Payment processing failed. Please try again.');
    }

    final subtotal = items.fold<double>(
      0,
          (sum, item) => sum + item.totalPrice,
    );
    final deliveryFee = restaurant.deliveryFee;
    final tax = subtotal * 0.08;
    final total = subtotal + deliveryFee + tax;

    return Order(
      id: 'ORD${DateTime.now().millisecondsSinceEpoch}',
      restaurant: restaurant,
      items: items,
      deliveryAddress: address,
      paymentMethod: paymentMethod,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      tax: tax,
      total: total,
      orderTime: DateTime.now(),
      status: OrderStatus.confirmed,
    );
  }

  // Mock Data
  static final List<Restaurant> _mockRestaurants = [
    const Restaurant(
      id: '1',
      name: 'Bella Italia',
      cuisine: 'Italian',
      rating: 4.5,
      deliveryTime: '25-35 min',
      deliveryFee: 49.0,
      image: '🍕',
    ),
    const Restaurant(
      id: '2',
      name: 'Dragon Palace',
      cuisine: 'Chinese',
      rating: 4.7,
      deliveryTime: '30-40 min',
      deliveryFee: 59.0,
      image: '🥡',
    ),
    const Restaurant(
      id: '3',
      name: 'Spice Garden',
      cuisine: 'Indian',
      rating: 4.6,
      deliveryTime: '20-30 min',
      deliveryFee: 39.0,
      image: '🍛',
    ),
    const Restaurant(
      id: '4',
      name: 'Burger House',
      cuisine: 'American',
      rating: 4.3,
      deliveryTime: '15-25 min',
      deliveryFee: 29.0,
      image: '🍔',
    ),
    const Restaurant(
      id: '5',
      name: 'Sushi Express',
      cuisine: 'Japanese',
      rating: 4.8,
      deliveryTime: '35-45 min',
      deliveryFee: 69.0,
      image: '🍣',
    ),
  ];

  static final List<FoodItem> _mockFoodItems = [
    const FoodItem(
      id: '1',
      name: 'Margherita Pizza',
      description: 'Classic pizza with tomato sauce, mozzarella, and basil',
      price: 299.0,
      image: '🍕',
      category: 'Pizza',
      isVegetarian: true,
    ),
    const FoodItem(
      id: '2',
      name: 'Pepperoni Pizza',
      description: 'Traditional pizza loaded with pepperoni and cheese',
      price: 349.0,
      image: '🍕',
      category: 'Pizza',
    ),
    const FoodItem(
      id: '3',
      name: 'Caesar Salad',
      description: 'Fresh romaine lettuce with Caesar dressing and croutons',
      price: 199.0,
      image: '🥗',
      category: 'Salads',
      isVegetarian: true,
    ),
    const FoodItem(
      id: '4',
      name: 'Garlic Bread',
      description: 'Toasted bread with garlic butter and herbs',
      price: 99.0,
      image: '🥖',
      category: 'Appetizers',
      isVegetarian: true,
    ),
    const FoodItem(
      id: '5',
      name: 'Tiramisu',
      description: 'Classic Italian dessert with coffee-soaked ladyfingers',
      price: 149.0,
      image: '🍰',
      category: 'Desserts',
      isVegetarian: true,
    ),
    const FoodItem(
      id: '6',
      name: 'Chicken Alfredo',
      description: 'Creamy fettuccine with grilled chicken',
      price: 379.0,
      image: '🍝',
      category: 'Pasta',
    ),
    const FoodItem(
      id: '7',
      name: 'Bruschetta',
      description: 'Toasted bread topped with tomatoes and basil',
      price: 129.0,
      image: '🍞',
      category: 'Appetizers',
      isVegetarian: true,
    ),
    const FoodItem(
      id: '8',
      name: 'Lasagna',
      description: 'Layered pasta with meat sauce and cheese',
      price: 329.0,
      image: '🍝',
      category: 'Pasta',
    ),
  ];

  static final List<DeliveryAddress> _mockAddresses = [
    const DeliveryAddress(
      id: '1',
      label: 'Home',
      address: 'BETA 1 ,E-73',
      details: 'Ring doorbell twice',
      isDefault: true,
    ),
    const DeliveryAddress(
      id: '2',
      label: 'Work',
      address: 'ADVANT NOIDA',
      details: 'Reception desk, 2nd floor',
    ),
    const DeliveryAddress(
      id: '3',
      label: 'Parents House',
      address: 'BISHNAH,JAMMU',
      details: 'Main entrance',
    ),
  ];

  static final List<PaymentMethod> _mockPaymentMethods = [
    const PaymentMethod(
      id: '1',
      type: 'card',
      displayName: 'Visa',
      last4Digits: '4242',
    ),
    const PaymentMethod(
      id: '2',
      type: 'card',
      displayName: 'Mastercard',
      last4Digits: '8888',
    ),
    const PaymentMethod(
      id: '3',
      type: 'cash',
      displayName: 'Cash on Delivery',
    ),
    const PaymentMethod(
      id: '4',
      type: 'wallet',
      displayName: 'Digital Wallet',
    ),
  ];
}