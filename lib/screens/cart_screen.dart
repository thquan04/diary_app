import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/index.dart';
import '../providers/index.dart';
import '../utils/index.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.cart)),
      body: cartProvider.items.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart, size: 64, color: AppColors.gray300),
            const SizedBox(height: 16),
            Text(
              AppStrings.emptyCart,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy thêm một số món ăn vào giỏ',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Tiếp tục mua sắm'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Items
          Expanded(
            child: ListView.builder(
              itemCount: cartProvider.items.length,
              itemBuilder: (context, index) {
                final cartItem = cartProvider.items[index];
                return _CartItemWidget(cartItem: cartItem);
              },
            ),
          ),
          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tạm tính',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${cartProvider.totalPrice.toStringAsFixed(0)}đ',
                      style: Theme.of(context).textTheme.titleLarge!
                          .copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Phí giao hàng',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
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
                      'Tổng cộng',
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
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/checkout');
                    },
                    child: const Text('Tiến hành thanh toán'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemWidget extends StatelessWidget {
  final CartItem cartItem;

  const _CartItemWidget({required this.cartItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.gray100,
            ),
            child: cartItem.food.image.isNotEmpty
                ? Image.network(
              cartItem.food.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.fastfood);
              },
            )
                : const Icon(Icons.fastfood),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.food.name,
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${cartItem.food.price.toStringAsFixed(0)}đ',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                // Quantity Controls
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.read<CartProvider>().updateQuantity(
                          cartItem.id,
                          cartItem.quantity - 1,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.remove,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${cartItem.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.read<CartProvider>().updateQuantity(
                          cartItem.id,
                          cartItem.quantity + 1,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Remove Button
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.error),
            onPressed: () {
              context.read<CartProvider>().removeItem(cartItem.id);
            },
          ),
        ],
      ),
    );
  }
}
