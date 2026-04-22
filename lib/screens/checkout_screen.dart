import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/index.dart';
import '../providers/index.dart';
import '../utils/index.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isProcessing = true);

      final cartProvider = context.read<CartProvider>();
      final orderProvider = context.read<OrderProvider>();

      final success = await orderProvider.createOrder(
        cartProvider.items,
        _addressController.text,
        _notesController.text,
      );

      setState(() => _isProcessing = false);

      if (success) {
        cartProvider.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đơn hàng đã được tạo thành công')),
        );
        Navigator.of(context).pushReplacementNamed('/orders');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(orderProvider.error ?? 'Lỗi khi tạo đơn')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh Toán')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivery Address
                Text(
                  'Địa chỉ giao hàng',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Nhập địa chỉ giao hàng',
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Vui lòng nhập địa chỉ giao hàng';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Order Items
                Text(
                  'Các món ăn',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.gray300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: cartProvider.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.food.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'x${item.quantity}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${item.totalPrice.toStringAsFixed(0)}đ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                // Notes
                Text(
                  'Ghi chú (tùy chọn)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Nhập ghi chú cho đơn hàng',
                    prefixIcon: const Icon(Icons.note),
                  ),
                ),
                const SizedBox(height: 24),
                // Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tạm tính:'),
                          Text(
                            '${cartProvider.totalPrice.toStringAsFixed(0)}đ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Phí giao hàng:'),
                          Text(
                            '30,000đ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tổng cộng:',
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${(cartProvider.totalPrice + 30000).toStringAsFixed(0)}đ',
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Place Order Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _placeOrder,
                    child: _isProcessing
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                        strokeWidth: 2,
                      ),
                    )
                        : const Text('XÁC NHẬN ĐẶT HÀNG'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
