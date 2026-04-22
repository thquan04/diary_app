import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/index.dart';
import '../providers/index.dart';
import '../utils/index.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<OrderProvider>().loadMyOrders());
  }

  String _getStatusLabel(String status) {
    final statusMap = {
      'pending': 'Chờ xử lý',
      'confirmed': 'Đã xác nhận',
      'preparing': 'Đang chuẩn bị',
      'ready': 'Sẵn sàng',
      'delivering': 'Đang giao',
      'delivered': 'Đã giao',
      'cancelled': 'Đã hủy',
    };
    return statusMap[status] ?? status;
  }

  Color _getStatusColor(String status) {
    final colorMap = {
      'pending': AppColors.warning,
      'confirmed': AppColors.info,
      'preparing': AppColors.info,
      'ready': AppColors.success,
      'delivering': AppColors.success,
      'delivered': AppColors.success,
      'cancelled': AppColors.error,
    };
    return colorMap[status] ?? AppColors.gray600;
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.orders)),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderProvider.orders.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag, size: 64, color: AppColors.gray300),
            const SizedBox(height: 16),
            Text(
              'Chưa có đơn hàng nào',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy đặt một đơn hàng để bắt đầu',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tiếp tục mua sắm'),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orderProvider.orders.length,
        itemBuilder: (context, index) {
          final order = orderProvider.orders[index];
          return _OrderCard(
            order: order,
            getStatusLabel: _getStatusLabel,
            getStatusColor: _getStatusColor,
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final String Function(String) getStatusLabel;
  final Color Function(String) getStatusColor;

  const _OrderCard({
    required this.order,
    required this.getStatusLabel,
    required this.getStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đơn #${order.id.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormatter.format(order.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  getStatusLabel(order.status),
                  style: TextStyle(
                    color: getStatusColor(order.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Items
          ...order.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.foodName} x${item.quantity}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${item.price.toStringAsFixed(0)}đ',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tổng cộng:', style: Theme.of(context).textTheme.titleLarge),
              Text(
                '${order.totalPrice.toStringAsFixed(0)}đ',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Address
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: AppColors.gray600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.address,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
