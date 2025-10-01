import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/domain/models/models.dart';

void main() {
  group('Restaurant', () {
    test('should create instance with correct properties', () {
      const restaurant = Restaurant(
        id: '1',
        name: 'Test Restaurant',
        cuisine: 'Italian',
        rating: 4.5,
        deliveryTime: '30 min',
        deliveryFee: 2.99,
        image: '🍕',
      );

      expect(restaurant.id, '1');
      expect(restaurant.name, 'Test Restaurant');
      expect(restaurant.cuisine, 'Italian');
      expect(restaurant.rating, 4.5);
      expect(restaurant.deliveryTime, '30 min');
      expect(restaurant.deliveryFee, 2.99);
      expect(restaurant.image, '🍕');
    });

    test('should support equality comparison', () {
      const restaurant1 = Restaurant(
        id: '1',
        name: 'Test',
        cuisine: 'Italian',
        rating: 4.5,
        deliveryTime: '30 min',
        deliveryFee: 2.99,
        image: '🍕',
      );

      const restaurant2 = Restaurant(
        id: '1',
        name: 'Test',
        cuisine: 'Italian',
        rating: 4.5,
        deliveryTime: '30 min',
        deliveryFee: 2.99,
        image: '🍕',
      );

      expect(restaurant1, restaurant2);
    });
  });

  group('FoodItem', () {
    test('should create instance with correct properties', () {
      const foodItem = FoodItem(
        id: '1',
        name: 'Pizza',
        description: 'Delicious pizza',
        price: 12.99,
        image: '🍕',
        category: 'Main',
        isVegetarian: true,
      );

      expect(foodItem.id, '1');
      expect(foodItem.name, 'Pizza');
      expect(foodItem.description, 'Delicious pizza');
      expect(foodItem.price, 12.99);
      expect(foodItem.image, '🍕');
      expect(foodItem.category, 'Main');
      expect(foodItem.isVegetarian, true);
    });

    test('should default isVegetarian to false', () {
      const foodItem = FoodItem(
        id: '1',
        name: 'Burger',
        description: 'Beef burger',
        price: 9.99,
        image: '🍔',
        category: 'Main',
      );

      expect(foodItem.isVegetarian, false);
    });
  });

  group('CartItem', () {
    const testFoodItem = FoodItem(
      id: '1',
      name: 'Pizza',
      description: 'Test',
      price: 10.00,
      image: '🍕',
      category: 'Main',
    );

    test('should calculate total price correctly', () {
      const cartItem = CartItem(
        foodItem: testFoodItem,
        quantity: 3,
      );

      expect(cartItem.totalPrice, 30.00);
    });

    test('should copy with new quantity', () {
      const original = CartItem(
        foodItem: testFoodItem,
        quantity: 1,
      );

      final copied = original.copyWith(quantity: 5);

      expect(copied.quantity, 5);
      expect(copied.foodItem, testFoodItem);
      expect(original.quantity, 1); // Original unchanged
    });
  });

  group('DeliveryAddress', () {
    test('should create instance with correct properties', () {
      const address = DeliveryAddress(
        id: '1',
        label: 'Home',
        address: '123 Main St',
        details: 'Ring bell',
        isDefault: true,
      );

      expect(address.id, '1');
      expect(address.label, 'Home');
      expect(address.address, '123 Main St');
      expect(address.details, 'Ring bell');
      expect(address.isDefault, true);
    });

    test('should default isDefault to false', () {
      const address = DeliveryAddress(
        id: '1',
        label: 'Work',
        address: '456 Office Blvd',
        details: 'Reception',
      );

      expect(address.isDefault, false);
    });
  });

  group('PaymentMethod', () {
    test('should create card payment method', () {
      const paymentMethod = PaymentMethod(
        id: '1',
        type: 'card',
        displayName: 'Visa',
        last4Digits: '4242',
      );

      expect(paymentMethod.id, '1');
      expect(paymentMethod.type, 'card');
      expect(paymentMethod.displayName, 'Visa');
      expect(paymentMethod.last4Digits, '4242');
    });

    test('should create cash payment method without last4Digits', () {
      const paymentMethod = PaymentMethod(
        id: '2',
        type: 'cash',
        displayName: 'Cash on Delivery',
      );

      expect(paymentMethod.last4Digits, null);
    });
  });

  group('Order', () {
    test('should create complete order', () {
      final order = Order(
        id: 'ORD123',
        restaurant: const Restaurant(
          id: '1',
          name: 'Test',
          cuisine: 'Italian',
          rating: 4.5,
          deliveryTime: '30 min',
          deliveryFee: 2.99,
          image: '🍕',
        ),
        items: const [
          CartItem(
            foodItem: FoodItem(
              id: '1',
              name: 'Pizza',
              description: 'Test',
              price: 12.99,
              image: '🍕',
              category: 'Main',
            ),
            quantity: 1,
          ),
        ],
        deliveryAddress: const DeliveryAddress(
          id: '1',
          label: 'Home',
          address: '123 Main St',
          details: 'Ring bell',
        ),
        paymentMethod: const PaymentMethod(
          id: '1',
          type: 'card',
          displayName: 'Visa',
        ),
        subtotal: 12.99,
        deliveryFee: 2.99,
        tax: 1.04,
        total: 17.02,
        orderTime: DateTime(2024, 1, 1),
        status: OrderStatus.confirmed,
      );

      expect(order.id, 'ORD123');
      expect(order.subtotal, 12.99);
      expect(order.total, 17.02);
      expect(order.status, OrderStatus.confirmed);
    });
  });
}