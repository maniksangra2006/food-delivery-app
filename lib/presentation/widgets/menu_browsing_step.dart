import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import '../../domain/models/models.dart';
import '../bloc/order_bloc.dart';

class MenuBrowsingStep extends StatelessWidget {
  final Restaurant restaurant;
  final List<FoodItem> foodItems;
  final List<CartItem> cart;

  const MenuBrowsingStep({
    super.key,
    required this.restaurant,
    required this.foodItems,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    final groupedItems = groupBy(foodItems, (item) => item.category);

    return Column(
      children: [
        _RestaurantHeader(restaurant: restaurant),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedItems.length,
            itemBuilder: (context, index) {
              final category = groupedItems.keys.elementAt(index);
              final items = groupedItems[category]!;
              return _CategorySection(
                category: category,
                items: items,
                cart: cart,
              );
            },
          ),
        ),
        if (cart.isNotEmpty) _CartSummaryBar(cart: cart),
      ],
    );
  }
}

class _RestaurantHeader extends StatelessWidget {
  final Restaurant restaurant;

  const _RestaurantHeader({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            restaurant.image,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFFFFB800)),
                    const SizedBox(width: 4),
                    Text(
                      '${restaurant.rating} • ${restaurant.deliveryTime}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String category;
  final List<FoodItem> items;
  final List<CartItem> cart;

  const _CategorySection({
    required this.category,
    required this.items,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            category,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...items.map((item) => _FoodItemCard(
          foodItem: item,
          cartItem: cart.firstWhereOrNull(
                (ci) => ci.foodItem.id == item.id,
          ),
        )),
      ],
    );
  }
}

class _FoodItemCard extends StatelessWidget {
  final FoodItem foodItem;
  final CartItem? cartItem;

  const _FoodItemCard({
    required this.foodItem,
    this.cartItem,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  foodItem.image,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (foodItem.isVegetarian)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green, width: 1.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Icon(
                            Icons.circle,
                            color: Colors.green,
                            size: 8,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          foodItem.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    foodItem.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${foodItem.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B35),
                        ),
                      ),
                      if (cartItem == null)
                        ElevatedButton(
                          onPressed: () {
                            context.read<OrderBloc>().add(AddToCart(foodItem));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B35),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: const Text('Add'),
                        )
                      else
                        _QuantitySelector(cartItem: cartItem!),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final CartItem cartItem;

  const _QuantitySelector({required this.cartItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B35),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            color: Colors.white,
            onPressed: () {
              context.read<OrderBloc>().add(
                UpdateCartItemQuantity(
                  cartItem.foodItem.id,
                  cartItem.quantity - 1,
                ),
              );
            },
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            padding: EdgeInsets.zero,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${cartItem.quantity}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            color: Colors.white,
            onPressed: () {
              context.read<OrderBloc>().add(
                UpdateCartItemQuantity(
                  cartItem.foodItem.id,
                  cartItem.quantity + 1,
                ),
              );
            },
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _CartSummaryBar extends StatelessWidget {
  final List<CartItem> cart;

  const _CartSummaryBar({required this.cart});

  @override
  Widget build(BuildContext context) {
    final itemCount = cart.fold<int>(0, (sum, item) => sum + item.quantity);
    final total = cart.fold<double>(0, (sum, item) => sum + item.totalPrice);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$itemCount items',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '₹${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                context.read<OrderBloc>().add(ProceedToDelivery());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}