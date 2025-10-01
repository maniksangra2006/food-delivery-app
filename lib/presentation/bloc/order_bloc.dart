import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/food_repository.dart';

// Events
abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadRestaurants extends OrderEvent {}

class SelectRestaurant extends OrderEvent {
  final Restaurant restaurant;
  const SelectRestaurant(this.restaurant);

  @override
  List<Object?> get props => [restaurant];
}

class LoadFoodItems extends OrderEvent {
  final String restaurantId;
  const LoadFoodItems(this.restaurantId);

  @override
  List<Object?> get props => [restaurantId];
}

class AddToCart extends OrderEvent {
  final FoodItem foodItem;
  const AddToCart(this.foodItem);

  @override
  List<Object?> get props => [foodItem];
}

class RemoveFromCart extends OrderEvent {
  final String foodItemId;
  const RemoveFromCart(this.foodItemId);

  @override
  List<Object?> get props => [foodItemId];
}

class UpdateCartItemQuantity extends OrderEvent {
  final String foodItemId;
  final int quantity;
  const UpdateCartItemQuantity(this.foodItemId, this.quantity);

  @override
  List<Object?> get props => [foodItemId, quantity];
}

class ProceedToDelivery extends OrderEvent {}

class LoadDeliveryAddresses extends OrderEvent {}

class SelectDeliveryAddress extends OrderEvent {
  final DeliveryAddress address;
  const SelectDeliveryAddress(this.address);

  @override
  List<Object?> get props => [address];
}

class ProceedToPayment extends OrderEvent {}

class LoadPaymentMethods extends OrderEvent {}

class SelectPaymentMethod extends OrderEvent {
  final PaymentMethod paymentMethod;
  const SelectPaymentMethod(this.paymentMethod);

  @override
  List<Object?> get props => [paymentMethod];
}

class PlaceOrder extends OrderEvent {}

class ResetOrder extends OrderEvent {}

// States
enum OrderStep {
  restaurantSelection,
  menuBrowsing,
  cart,
  delivery,
  payment,
  confirmation,
}

class OrderState extends Equatable {
  final OrderStep currentStep;
  final List<Restaurant> restaurants;
  final Restaurant? selectedRestaurant;
  final List<FoodItem> foodItems;
  final List<CartItem> cart;
  final List<DeliveryAddress> addresses;
  final DeliveryAddress? selectedAddress;
  final List<PaymentMethod> paymentMethods;
  final PaymentMethod? selectedPaymentMethod;
  final Order? placedOrder;
  final bool isLoading;
  final String? error;

  const OrderState({
    this.currentStep = OrderStep.restaurantSelection,
    this.restaurants = const [],
    this.selectedRestaurant,
    this.foodItems = const [],
    this.cart = const [],
    this.addresses = const [],
    this.selectedAddress,
    this.paymentMethods = const [],
    this.selectedPaymentMethod,
    this.placedOrder,
    this.isLoading = false,
    this.error,
  });

  double get subtotal => cart.fold(0, (sum, item) => sum + item.totalPrice);
  double get deliveryFee => selectedRestaurant?.deliveryFee ?? 0;
  double get tax => subtotal * 0.08;
  double get total => subtotal + deliveryFee + tax;

  OrderState copyWith({
    OrderStep? currentStep,
    List<Restaurant>? restaurants,
    Restaurant? selectedRestaurant,
    List<FoodItem>? foodItems,
    List<CartItem>? cart,
    List<DeliveryAddress>? addresses,
    DeliveryAddress? selectedAddress,
    List<PaymentMethod>? paymentMethods,
    PaymentMethod? selectedPaymentMethod,
    Order? placedOrder,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return OrderState(
      currentStep: currentStep ?? this.currentStep,
      restaurants: restaurants ?? this.restaurants,
      selectedRestaurant: selectedRestaurant ?? this.selectedRestaurant,
      foodItems: foodItems ?? this.foodItems,
      cart: cart ?? this.cart,
      addresses: addresses ?? this.addresses,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      placedOrder: placedOrder ?? this.placedOrder,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    restaurants,
    selectedRestaurant,
    foodItems,
    cart,
    addresses,
    selectedAddress,
    paymentMethods,
    selectedPaymentMethod,
    placedOrder,
    isLoading,
    error,
  ];
}

// BLoC
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final FoodRepository repository;

  OrderBloc({required this.repository}) : super(const OrderState()) {
    on<LoadRestaurants>(_onLoadRestaurants);
    on<SelectRestaurant>(_onSelectRestaurant);
    on<LoadFoodItems>(_onLoadFoodItems);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateCartItemQuantity>(_onUpdateCartItemQuantity);
    on<ProceedToDelivery>(_onProceedToDelivery);
    on<LoadDeliveryAddresses>(_onLoadDeliveryAddresses);
    on<SelectDeliveryAddress>(_onSelectDeliveryAddress);
    on<ProceedToPayment>(_onProceedToPayment);
    on<LoadPaymentMethods>(_onLoadPaymentMethods);
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
    on<PlaceOrder>(_onPlaceOrder);
    on<ResetOrder>(_onResetOrder);
  }

  Future<void> _onLoadRestaurants(
      LoadRestaurants event,
      Emitter<OrderState> emit,
      ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final restaurants = await repository.getRestaurants();
      emit(state.copyWith(
        restaurants: restaurants,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load restaurants: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSelectRestaurant(
      SelectRestaurant event,
      Emitter<OrderState> emit,
      ) async {
    emit(state.copyWith(
      selectedRestaurant: event.restaurant,
      currentStep: OrderStep.menuBrowsing,
    ));
    add(LoadFoodItems(event.restaurant.id));
  }

  Future<void> _onLoadFoodItems(
      LoadFoodItems event,
      Emitter<OrderState> emit,
      ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final foodItems = await repository.getFoodItemsByRestaurant(event.restaurantId);
      emit(state.copyWith(
        foodItems: foodItems,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load menu: ${e.toString()}',
      ));
    }
  }

  void _onAddToCart(AddToCart event, Emitter<OrderState> emit) {
    final existingIndex = state.cart.indexWhere(
          (item) => item.foodItem.id == event.foodItem.id,
    );

    List<CartItem> updatedCart;
    if (existingIndex >= 0) {
      updatedCart = List.from(state.cart);
      updatedCart[existingIndex] = updatedCart[existingIndex].copyWith(
        quantity: updatedCart[existingIndex].quantity + 1,
      );
    } else {
      updatedCart = [...state.cart, CartItem(foodItem: event.foodItem, quantity: 1)];
    }

    emit(state.copyWith(cart: updatedCart));
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<OrderState> emit) {
    final updatedCart = state.cart.where(
          (item) => item.foodItem.id != event.foodItemId,
    ).toList();

    emit(state.copyWith(cart: updatedCart));
  }

  void _onUpdateCartItemQuantity(
      UpdateCartItemQuantity event,
      Emitter<OrderState> emit,
      ) {
    if (event.quantity <= 0) {
      add(RemoveFromCart(event.foodItemId));
      return;
    }

    final updatedCart = state.cart.map((item) {
      if (item.foodItem.id == event.foodItemId) {
        return item.copyWith(quantity: event.quantity);
      }
      return item;
    }).toList();

    emit(state.copyWith(cart: updatedCart));
  }

  Future<void> _onProceedToDelivery(
      ProceedToDelivery event,
      Emitter<OrderState> emit,
      ) async {
    if (state.cart.isEmpty) {
      emit(state.copyWith(error: 'Cart is empty. Please add items first.'));
      return;
    }

    emit(state.copyWith(
      currentStep: OrderStep.delivery,
      clearError: true,
    ));
    add(LoadDeliveryAddresses());
  }

  Future<void> _onLoadDeliveryAddresses(
      LoadDeliveryAddresses event,
      Emitter<OrderState> emit,
      ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final addresses = await repository.getDeliveryAddresses();
      final defaultAddress = addresses.firstWhere(
            (addr) => addr.isDefault,
        orElse: () => addresses.first,
      );
      emit(state.copyWith(
        addresses: addresses,
        selectedAddress: defaultAddress,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load addresses: ${e.toString()}',
      ));
    }
  }

  void _onSelectDeliveryAddress(
      SelectDeliveryAddress event,
      Emitter<OrderState> emit,
      ) {
    emit(state.copyWith(selectedAddress: event.address));
  }

  Future<void> _onProceedToPayment(
      ProceedToPayment event,
      Emitter<OrderState> emit,
      ) async {
    if (state.selectedAddress == null) {
      emit(state.copyWith(error: 'Please select a delivery address.'));
      return;
    }

    emit(state.copyWith(
      currentStep: OrderStep.payment,
      clearError: true,
    ));
    add(LoadPaymentMethods());
  }

  Future<void> _onLoadPaymentMethods(
      LoadPaymentMethods event,
      Emitter<OrderState> emit,
      ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final paymentMethods = await repository.getPaymentMethods();
      emit(state.copyWith(
        paymentMethods: paymentMethods,
        selectedPaymentMethod: paymentMethods.first,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load payment methods: ${e.toString()}',
      ));
    }
  }

  void _onSelectPaymentMethod(
      SelectPaymentMethod event,
      Emitter<OrderState> emit,
      ) {
    emit(state.copyWith(selectedPaymentMethod: event.paymentMethod));
  }

  Future<void> _onPlaceOrder(PlaceOrder event, Emitter<OrderState> emit) async {
    if (state.selectedRestaurant == null ||
        state.cart.isEmpty ||
        state.selectedAddress == null ||
        state.selectedPaymentMethod == null) {
      emit(state.copyWith(error: 'Missing required information to place order.'));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final order = await repository.placeOrder(
        restaurant: state.selectedRestaurant!,
        items: state.cart,
        address: state.selectedAddress!,
        paymentMethod: state.selectedPaymentMethod!,
      );

      emit(state.copyWith(
        placedOrder: order,
        currentStep: OrderStep.confirmation,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to place order: ${e.toString()}',
      ));
    }
  }

  void _onResetOrder(ResetOrder event, Emitter<OrderState> emit) {
    emit(const OrderState());
    add(LoadRestaurants());
  }
}