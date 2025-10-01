import '../models/models.dart';

abstract class FoodRepository {
  Future<List<Restaurant>> getRestaurants();
  Future<List<FoodItem>> getFoodItemsByRestaurant(String restaurantId);
  Future<List<DeliveryAddress>> getDeliveryAddresses();
  Future<List<PaymentMethod>> getPaymentMethods();
  Future<Order> placeOrder({
    required Restaurant restaurant,
    required List<CartItem> items,
    required DeliveryAddress address,
    required PaymentMethod paymentMethod,
  });
}