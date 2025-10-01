import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/models.dart';
import '../bloc/order_bloc.dart';

class DeliveryStep extends StatelessWidget {
  final List<DeliveryAddress> addresses;
  final DeliveryAddress? selectedAddress;

  const DeliveryStep({
    super.key,
    required this.addresses,
    this.selectedAddress,
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
                'Select Delivery Address',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ...addresses.map((address) => _AddressCard(
                address: address,
                isSelected: selectedAddress?.id == address.id,
              )),
            ],
          ),
        ),
        _ContinueButton(isEnabled: selectedAddress != null),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  final DeliveryAddress address;
  final bool isSelected;

  const _AddressCard({
    required this.address,
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
          context.read<OrderBloc>().add(SelectDeliveryAddress(address));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isSelected ? const Color(0xFFFF6B35) : Colors.grey[300]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForLabel(address.label),
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.label,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Default',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFFFF6B35),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      address.address,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.details,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
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

  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      default:
        return Icons.location_on;
    }
  }
}

class _ContinueButton extends StatelessWidget {
  final bool isEnabled;

  const _ContinueButton({required this.isEnabled});

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
              context.read<OrderBloc>().add(ProceedToPayment());
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
              'Continue to Payment',
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