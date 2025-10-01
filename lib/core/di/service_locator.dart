import '../../data/repositories/mock_food_repository.dart';
import '../../domain/repositories/food_repository.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, dynamic> _services = {};

  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T not registered');
    }
    return service as T;
  }

  void register<T>(T service) {
    _services[T] = service;
  }
}

void setupServiceLocator() {
  final locator = ServiceLocator();
  locator.register<FoodRepository>(MockFoodRepository());
}

FoodRepository get foodRepository => ServiceLocator().get<FoodRepository>();