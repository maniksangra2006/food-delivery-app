import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/service_locator.dart';
import '../bloc/order_bloc.dart';
import '../widgets/restaurant_selection_step.dart';
import '../widgets/menu_browsing_step.dart';
import '../widgets/delivery_step.dart';
import '../widgets/payment_step.dart';
import '../widgets/confirmation_step.dart';
import '../widgets/progress_indicator_widget.dart';
import '../widgets/error_dialog.dart';

class FoodOrderWorkflowScreen extends StatelessWidget {
  const FoodOrderWorkflowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderBloc(repository: foodRepository)
        ..add(LoadRestaurants()),
      child: const _FoodOrderWorkflowContent(),
    );
  }
}

class _FoodOrderWorkflowContent extends StatelessWidget {
  const _FoodOrderWorkflowContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: _shouldShowBackButton(state.currentStep)
                ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _handleBackPress(context, state),
            )
                : null,
            title: const Text(
              'Food Delivery',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              BlocBuilder<OrderBloc, OrderState>(
                builder: (context, state) {
                  if (state.currentStep == OrderStep.menuBrowsing ||
                      state.currentStep == OrderStep.cart) {
                    final itemCount = state.cart.fold<int>(
                        0, (sum, item) => sum + item.quantity);
                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined),
                          onPressed: () {
                            if (state.cart.isNotEmpty) {
                              context.read<OrderBloc>().add(ProceedToDelivery());
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Your cart is empty'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                        if (itemCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF6B35),
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '$itemCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          body: BlocConsumer<OrderBloc, OrderState>(
            listener: (context, state) {
              if (state.error != null) {
                showDialog(
                  context: context,
                  builder: (context) => ErrorDialog(message: state.error!),
                );
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  if (state.currentStep != OrderStep.confirmation)
                    OrderProgressIndicatorWidget(currentStep: state.currentStep),
                  Expanded(
                    child: _buildStepContent(context, state),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStepContent(BuildContext context, OrderState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF6B35),
        ),
      );
    }

    switch (state.currentStep) {
      case OrderStep.restaurantSelection:
        return RestaurantSelectionStep(restaurants: state.restaurants);
      case OrderStep.menuBrowsing:
      case OrderStep.cart:
        return MenuBrowsingStep(
          restaurant: state.selectedRestaurant!,
          foodItems: state.foodItems,
          cart: state.cart,
        );
      case OrderStep.delivery:
        return DeliveryStep(
          addresses: state.addresses,
          selectedAddress: state.selectedAddress,
        );
      case OrderStep.payment:
        return PaymentStep(
          paymentMethods: state.paymentMethods,
          selectedPaymentMethod: state.selectedPaymentMethod,
          subtotal: state.subtotal,
          deliveryFee: state.deliveryFee,
          tax: state.tax,
          total: state.total,
        );
      case OrderStep.confirmation:
        return ConfirmationStep(order: state.placedOrder!);
    }
  }

  bool _shouldShowBackButton(OrderStep currentStep) {
    return currentStep != OrderStep.restaurantSelection &&
        currentStep != OrderStep.confirmation;
  }

  void _handleBackPress(BuildContext context, OrderState state) {
    final bloc = context.read<OrderBloc>();

    switch (state.currentStep) {
      case OrderStep.menuBrowsing:
      case OrderStep.cart:
      // Go back to restaurant selection
        bloc.add(ResetOrder());
        break;
      case OrderStep.delivery:
      // Go back to menu
        bloc.add(state.selectedRestaurant != null
            ? SelectRestaurant(state.selectedRestaurant!)
            : ResetOrder());
        break;
      case OrderStep.payment:
      // Go back to delivery
        bloc.add(ProceedToDelivery());
        break;
      case OrderStep.restaurantSelection:
      case OrderStep.confirmation:
      // No back action needed
        break;
    }
  }
}