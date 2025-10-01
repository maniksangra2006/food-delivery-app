import 'package:flutter/material.dart';
import '../bloc/order_bloc.dart';

class OrderProgressIndicatorWidget extends StatelessWidget {
  final OrderStep currentStep;

  const OrderProgressIndicatorWidget({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      _StepInfo('Restaurant', Icons.restaurant, OrderStep.restaurantSelection),
      _StepInfo('Menu', Icons.menu_book, OrderStep.menuBrowsing),
      _StepInfo('Delivery', Icons.location_on, OrderStep.delivery),
      _StepInfo('Payment', Icons.payment, OrderStep.payment),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
          for (int i = 0; i < steps.length; i++) ...[
            Expanded(
              child: _StepIndicator(
                stepInfo: steps[i],
                isActive: _isStepActive(steps[i].step),
                isCompleted: _isStepCompleted(steps[i].step),
              ),
            ),
            if (i < steps.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color: _isStepCompleted(steps[i].step)
                      ? const Color(0xFFFF6B35)
                      : Colors.grey[300],
                ),
              ),
          ],
        ],
      ),
    );
  }

  bool _isStepActive(OrderStep step) {
    return currentStep == step ||
        (step == OrderStep.menuBrowsing && currentStep == OrderStep.cart);
  }

  bool _isStepCompleted(OrderStep step) {
    final stepOrder = [
      OrderStep.restaurantSelection,
      OrderStep.menuBrowsing,
      OrderStep.delivery,
      OrderStep.payment,
    ];
    final currentIndex = stepOrder.indexOf(currentStep);
    final stepIndex = stepOrder.indexOf(step);
    return stepIndex < currentIndex;
  }
}

class _StepInfo {
  final String label;
  final IconData icon;
  final OrderStep step;

  _StepInfo(this.label, this.icon, this.step);
}

class _StepIndicator extends StatelessWidget {
  final _StepInfo stepInfo;
  final bool isActive;
  final bool isCompleted;

  const _StepIndicator({
    required this.stepInfo,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompleted || isActive
        ? const Color(0xFFFF6B35)
        : Colors.grey[400]!;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isActive ? color : Colors.transparent,
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
          child: Icon(
            isCompleted ? Icons.check : stepInfo.icon,
            color: isCompleted || isActive ? Colors.white : color,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stepInfo.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? color : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}