import 'package:equatable/equatable.dart';

// Restaurant Model
class Restaurant extends Equatable {
  final String id;
  final String name;
  final String cuisine;
  final double rating;
  final String deliveryTime;
  final double deliveryFee;
  final String image;

  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.image,
  });

  @override
  List<Object?> get props => [id, name, cuisine, rating, deliveryTime, deliveryFee, image];
}

// Food Item Model
class FoodItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;
  final bool isVegetarian;

  const FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    this.isVegetarian = false,
  });

  @override
  List<Object?> get props => [id, name, description, price, image, category, isVegetarian];
}

// Cart Item Model
class CartItem extends Equatable {
  final FoodItem foodItem;
  final int quantity;

  const CartItem({
    required this.foodItem,
    required this.quantity,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      foodItem: foodItem,
      quantity: quantity ?? this.quantity,
    );
  }

  double get totalPrice => foodItem.price * quantity;

  @override
  List<Object?> get props => [foodItem, quantity];
}

// Delivery Address Model
class DeliveryAddress extends Equatable {
  final String id;
  final String label;
  final String address;
  final String details;
  final bool isDefault;

  const DeliveryAddress({
    required this.id,
    required this.label,
    required this.address,
    required this.details,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [id, label, address, details, isDefault];
}

// Payment Method Model — uses String type (NOT enum)
class PaymentMethod extends Equatable {
  final String id;
  final String type; // 'upi', 'card', 'cash'
  final String displayName;
  final String? last4Digits;

  const PaymentMethod({
    required this.id,
    required this.type,
    required this.displayName,
    this.last4Digits,
  });

  // Factory constructors for standard payment options
  factory PaymentMethod.upi() => const PaymentMethod(
    id: 'upi',
    type: 'upi',
    displayName: 'Google Pay / PhonePe / UPI',
  );

  factory PaymentMethod.card() => PaymentMethod(
    id: 'card',
    type: 'card',
    displayName: 'Credit or Debit Card',
    last4Digits: '1234',
  );

  factory PaymentMethod.cod() => const PaymentMethod(
    id: 'cod',
    type: 'cash',
    displayName: 'Cash on Delivery',
  );

  @override
  List<Object?> get props => [id, type, displayName, last4Digits];
}

// Order Model
class Order extends Equatable {
  final String id;
  final Restaurant restaurant;
  final List<CartItem> items;
  final DeliveryAddress deliveryAddress;
  final PaymentMethod paymentMethod;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double total;
  final DateTime orderTime;
  final OrderStatus status;

  const Order({
    required this.id,
    required this.restaurant,
    required this.items,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.total,
    required this.orderTime,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    restaurant,
    items,
    deliveryAddress,
    paymentMethod,
    subtotal,
    deliveryFee,
    tax,
    total,
    orderTime,
    status,
  ];
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  onTheWay,
  delivered,
  cancelled,
}