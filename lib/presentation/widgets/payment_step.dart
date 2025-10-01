import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/models.dart';
import '../bloc/order_bloc.dart';

class PaymentStep extends StatelessWidget {
  final List<PaymentMethod> paymentMethods;
  final PaymentMethod? selectedPaymentMethod;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double total;

  const PaymentStep({
    super.key,
    required this.paymentMethods,
    this.selectedPaymentMethod,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ...paymentMethods.map((method) => _PaymentMethodCard(
                paymentMethod: method,
                isSelected: selectedPaymentMethod?.id == method.id,
              )),
              const SizedBox(height: 24),
              _OrderSummary(
                subtotal: subtotal,
                deliveryFee: deliveryFee,
                tax: tax,
                total: total,
              ),
            ],
          ),
        ),
        _PlaceOrderButton(isEnabled: selectedPaymentMethod != null),
      ],
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final bool isSelected;

  const _PaymentMethodCard({
    required this.paymentMethod,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFFFF6B35) : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          context.read<OrderBloc>().add(SelectPaymentMethod(paymentMethod));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isSelected ? const Color(0xFFFF6B35) : Colors.grey[300]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForPaymentType(paymentMethod.type),
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paymentMethod.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (paymentMethod.last4Digits != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '•••• ${paymentMethod.last4Digits}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFFFF6B35),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForPaymentType(String type) {
    switch (type.toLowerCase()) {
      case 'card':
        return Icons.credit_card;
      case 'cash':
        return Icons.money;
      case 'wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }
}

class _OrderSummary extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double total;

  const _OrderSummary({
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _SummaryRow(
              label: 'Subtotal',
              value: '₹${subtotal.toStringAsFixed(0)}',
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Delivery Fee',
              value: '₹${deliveryFee.toStringAsFixed(0)}',
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Tax (8%)',
              value: '₹${tax.toStringAsFixed(0)}',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            _SummaryRow(
              label: 'Total',
              value: '₹${total.toStringAsFixed(0)}',
              isBold: true,
              valueColor: const Color(0xFFFF6B35),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Colors.black : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 20 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? (isBold ? Colors.black : Colors.grey[800]),
          ),
        ),
      ],
    );
  }
}

class _PlaceOrderButton extends StatelessWidget {
  final bool isEnabled;

  const _PlaceOrderButton({required this.isEnabled});

  @override
  Widget build(BuildContext context) {
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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isEnabled
                ? () {
              context.read<OrderBloc>().add(PlaceOrder());
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Place Order',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}