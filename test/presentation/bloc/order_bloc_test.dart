import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/domain/models/models.dart';
import 'package:food_delivery_app/domain/repositories/food_repository.dart';
import 'package:food_delivery_app/presentation/bloc/order_bloc.dart';

class MockFoodRepository extends Mock implements FoodRepository {}

void main() {
  late MockFoodRepository mockRepository;

  setUp(() {
    mockRepository = MockFoodRepository();
  });

  group('OrderBloc', () {
    final testRestaurant = const Restaurant(
      id: '1',
      name: 'Test Restaurant',
      cuisine: 'Italian',
      rating: 4.5,
      deliveryTime: '30 min',
      deliveryFee: 2.99,
      image: '🍕',
    );

    final testFoodItem = const FoodItem(
      id: '1',
      name: 'Pizza',
      description: 'Delicious pizza',
      price: 12.99,
      image: '🍕',
      category: 'Main',
    );

    final testAddress = const DeliveryAddress(
      id: '1',
      label: 'Home',
      address: '123 Main St',
      details: 'Ring bell',
      isDefault: true,
    );

    final testPaymentMethod = const PaymentMethod(
      id: '1',
      type: 'card',
      displayName: 'Visa',
      last4Digits: '4242',
    );

    test('initial state is correct', () {
      final bloc = OrderBloc(repository: mockRepository);
      expect(bloc.state, const OrderState());
      bloc.close();
    });

    blocTest<OrderBloc, OrderState>(
      'emits loading and success states when LoadRestaurants succeeds',
      build: () {
        when(() => mockRepository.getRestaurants())
            .thenAnswer((_) async => [testRestaurant]);
        return OrderBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(LoadRestaurants()),
      expect: () => [
        const OrderState(isLoading: true),
        OrderState(isLoading: false, restaurants: [testRestaurant]),
      ],
      verify: (_) {
        verify(() => mockRepository.getRestaurants()).called(1);
      },
    );

    blocTest<OrderBloc, OrderState>(
      'emits error when LoadRestaurants fails',
      build: () {
        when(() => mockRepository.getRestaurants())
            .thenThrow(Exception('Network error'));
        return OrderBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(LoadRestaurants()),
      expect: () => [
        const OrderState(isLoading: true),
        const OrderState(
          isLoading: false,
          error: 'Failed to load restaurants: Exception: Network error',
        ),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'selects restaurant and loads food items',
      build: () {
        when(() => mockRepository.getFoodItemsByRestaurant('1'))
            .thenAnswer((_) async => [testFoodItem]);
        return OrderBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(SelectRestaurant(testRestaurant)),
      expect: () => [
        OrderState(
          selectedRestaurant: testRestaurant,
          currentStep: OrderStep.menuBrowsing,
        ),
        OrderState(
          selectedRestaurant: testRestaurant,
          currentStep: OrderStep.menuBrowsing,
          isLoading: true,
        ),
        OrderState(
          selectedRestaurant: testRestaurant,
          currentStep: OrderStep.menuBrowsing,
          isLoading: false,
          foodItems: [testFoodItem],
        ),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'adds item to cart',
      build: () => OrderBloc(repository: mockRepository),
      act: (bloc) => bloc.add(AddToCart(testFoodItem)),
      expect: () => [
        OrderState(
          cart: [CartItem(foodItem: testFoodItem, quantity: 1)],
        ),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'increments quantity when adding existing item to cart',
      build: () => OrderBloc(repository: mockRepository),
      seed: () => OrderState(
        cart: [CartItem(foodItem: testFoodItem, quantity: 1)],
      ),
      act: (bloc) => bloc.add(AddToCart(testFoodItem)),
      expect: () => [
        OrderState(
          cart: [CartItem(foodItem: testFoodItem, quantity: 2)],
        ),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'removes item from cart',
      build: () => OrderBloc(repository: mockRepository),
      seed: () => OrderState(
        cart: [CartItem(foodItem: testFoodItem, quantity: 1)],
      ),
      act: (bloc) => bloc.add(RemoveFromCart('1')),
      expect: () => [
        const OrderState(cart: []),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'updates cart item quantity',
      build: () => OrderBloc(repository: mockRepository),
      seed: () => OrderState(
        cart: [CartItem(foodItem: testFoodItem, quantity: 1)],
      ),
      act: (bloc) => bloc.add(UpdateCartItemQuantity('1', 3)),
      expect: () => [
        OrderState(
          cart: [CartItem(foodItem: testFoodItem, quantity: 3)],
        ),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'removes item when quantity updated to 0',
      build: () => OrderBloc(repository: mockRepository),
      seed: () => OrderState(
        cart: [CartItem(foodItem: testFoodItem, quantity: 1)],
      ),
      act: (bloc) => bloc.add(UpdateCartItemQuantity('1', 0)),
      expect: () => [
        const OrderState(cart: []),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'emits error when proceeding to delivery with empty cart',
      build: () => OrderBloc(repository: mockRepository),
      act: (bloc) => bloc.add(ProceedToDelivery()),
      expect: () => [
        const OrderState(error: 'Cart is empty. Please add items first.'),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'proceeds to delivery and loads addresses',
      build: () {
        when(() => mockRepository.getDeliveryAddresses())
            .thenAnswer((_) async => [testAddress]);
        return OrderBloc(repository: mockRepository);
      },
      seed: () => OrderState(
        cart: [CartItem(foodItem: testFoodItem, quantity: 1)],
      ),
      act: (bloc) => bloc.add(ProceedToDelivery()),
      expect: () => [
        OrderState(
          cart: [CartItem(foodItem: testFoodItem, quantity: 1)],
          currentStep: OrderStep.delivery,
        ),
        OrderState(
          cart: [CartItem(foodItem: testFoodItem, quantity: 1)],
          currentStep: OrderStep.delivery,
          isLoading: true,
        ),
        OrderState(
          cart: [CartItem(foodItem: testFoodItem, quantity: 1)],
          currentStep: OrderStep.delivery,
          isLoading: false,
          addresses: [testAddress],
          selectedAddress: testAddress,
        ),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'selects delivery address',
      build: () => OrderBloc(repository: mockRepository),
      act: (bloc) => bloc.add(SelectDeliveryAddress(testAddress)),
      expect: () => [
        OrderState(selectedAddress: testAddress),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'emits error when proceeding to payment without address',
      build: () => OrderBloc(repository: mockRepository),
      act: (bloc) => bloc.add(ProceedToPayment()),
      expect: () => [
        const OrderState(error: 'Please select a delivery address.'),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'proceeds to payment and loads payment methods',
      build: () {
        when(() => mockRepository.getPaymentMethods())
            .thenAnswer((_) async => [testPaymentMethod]);
        return OrderBloc(repository: mockRepository);
      },
      seed: () => OrderState(selectedAddress: testAddress),
      act: (bloc) => bloc.add(ProceedToPayment()),
      expect: () => [
        OrderState(
          selectedAddress: testAddress,
          currentStep: OrderStep.payment,
        ),
        OrderState(
          selectedAddress: testAddress,
          currentStep: OrderStep.payment,
          isLoading: true,
        ),
        OrderState(
          selectedAddress: testAddress,
          currentStep: OrderStep.payment,
          isLoading: false,
          paymentMethods: [testPaymentMethod],
          selectedPaymentMethod: testPaymentMethod,
        ),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'selects payment method',
      build: () => OrderBloc(repository: mockRepository),
      act: (bloc) => bloc.add(SelectPaymentMethod(testPaymentMethod)),
      expect: () => [
        OrderState(selectedPaymentMethod: testPaymentMethod),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'places order successfully',
      build: () {
        final testOrder = Order(
          id: 'ORD123',
          restaurant: testRestaurant,
          items: [CartItem(foodItem: testFoodItem, quantity: 1)],
          deliveryAddress: testAddress,
          paymentMethod: testPaymentMethod,
          subtotal: 12.99,
          deliveryFee: 2.99,
          tax: 1.04,
          total: 17.02,
          orderTime: DateTime.now(),
          status: OrderStatus.confirmed,
        );

        when(() => mockRepository.placeOrder(
          restaurant: any(named: 'restaurant'),
          items: any(named: 'items'),
          address: any(named: 'address'),
          paymentMethod: any(named: 'paymentMethod'),
        )).thenAnswer((_) async => testOrder);

        return OrderBloc(repository: mockRepository);
      },
      seed: () => OrderState(
        selectedRestaurant: testRestaurant,
        cart: [CartItem(foodItem: testFoodItem, quantity: 1)],
        selectedAddress: testAddress,
        selectedPaymentMethod: testPaymentMethod,
      ),
      act: (bloc) => bloc.add(PlaceOrder()),
      expect: () => [
        OrderState(
          selectedRestaurant: testRestaurant,
          cart: [CartItem(foodItem: testFoodItem, quantity: 1)],
          selectedAddress: testAddress,
          selectedPaymentMethod: testPaymentMethod,
          isLoading: true,
        ),
        isA<OrderState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.currentStep, 'currentStep', OrderStep.confirmation)
            .having((s) => s.placedOrder, 'placedOrder', isNotNull),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'emits error when place order fails',
      build: () {
        when(() => mockRepository.placeOrder(
          restaurant: any(named: 'restaurant'),
          items: any(named: 'items'),
          address: any(named: 'address'),
          paymentMethod: any(named: 'paymentMethod'),
        )).thenThrow(Exception('Payment failed'));

        return OrderBloc(repository: mockRepository);
      },
      seed: () => OrderState(
        selectedRestaurant: testRestaurant,
        cart: [CartItem(foodItem: testFoodItem, quantity: 1)],
        selectedAddress: testAddress,
        selectedPaymentMethod: testPaymentMethod,
      ),
      act: (bloc) => bloc.add(PlaceOrder()),
      expect: () => [
        OrderState(
          selectedRestaurant: testRestaurant,
          cart: [CartItem(foodItem: testFoodItem, quantity: 1)],
          selectedAddress: testAddress,
          selectedPaymentMethod: testPaymentMethod,
          isLoading: true,
        ),
        OrderState(
          selectedRestaurant: testRestaurant,
          cart: [CartItem(foodItem: testFoodItem, quantity: 1)],
          selectedAddress: testAddress,
          selectedPaymentMethod: testPaymentMethod,
          isLoading: false,
          error: 'Failed to place order: Exception: Payment failed',
        ),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'resets order and reloads restaurants',
      build: () {
        when(() => mockRepository.getRestaurants())
            .thenAnswer((_) async => [testRestaurant]);
        return OrderBloc(repository: mockRepository);
      },
      seed: () => OrderState(
        selectedRestaurant: testRestaurant,
        cart: [CartItem(foodItem: testFoodItem, quantity: 1)],
        currentStep: OrderStep.confirmation,
      ),
      act: (bloc) => bloc.add(ResetOrder()),
      expect: () => [
        const OrderState(),
        const OrderState(isLoading: true),
        OrderState(isLoading: false, restaurants: [testRestaurant]),
      ],
    );

    test('calculates subtotal correctly', () {
      final state = OrderState(
        cart: [
          CartItem(foodItem: testFoodItem, quantity: 2),
          CartItem(
            foodItem: const FoodItem(
              id: '2',
              name: 'Salad',
              description: 'Fresh salad',
              price: 8.99,
              image: '🥗',
              category: 'Appetizer',
            ),
            quantity: 1,
          ),
        ],
      );

      expect(state.subtotal, 34.97); // 12.99 * 2 + 8.99
    });

    test('calculates total correctly', () {
      final state = OrderState(
        selectedRestaurant: testRestaurant,
        cart: [CartItem(foodItem: testFoodItem, quantity: 1)],
      );

      expect(state.subtotal, 12.99);
      expect(state.deliveryFee, 2.99);
      expect(state.tax, closeTo(1.04, 0.01)); // 12.99 * 0.08
      expect(state.total, closeTo(17.02, 0.01));
    });
  });
}