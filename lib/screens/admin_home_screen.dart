import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/index.dart';
import '../models/index.dart';
import '../services/api_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  bool _isSeeding = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodProvider>().loadFoods();
    });
  }

  void _handleSeedData() async {
    setState(() => _isSeeding = true);
    try {
      await ApiService.seedFoods();
      if (mounted) {
        context.read<FoodProvider>().loadFoods();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã tạo món ăn mẫu thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  void _showAddFoodDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    final imgController = TextEditingController();
    String selectedCategory = 'Thức Ăn';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm Món Ăn Mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên món')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Giá'), keyboardType: TextInputType.number),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Mô tả')),
              TextField(controller: imgController, decoration: const InputDecoration(labelText: 'Link ảnh (URL)')),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: ['Thức Ăn', 'Đồ Uống', 'Combo'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => selectedCategory = val!,
                decoration: const InputDecoration(labelText: 'Danh mục'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final newFood = FoodItem(
                id: '', 
                name: nameController.text,
                price: double.tryParse(priceController.text) ?? 0,
                description: descController.text,
                image: imgController.text,
                category: selectedCategory,
              );
              await ApiService.addFood(newFood);
              if (mounted) {
                context.read<FoodProvider>().loadFoods();
                Navigator.pop(context);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Món Ăn'),
        actions: [
          _isSeeding 
            ? const Center(child: Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
            : IconButton(
                icon: const Icon(Icons.cloud_download, color: Colors.orange),
                onPressed: _handleSeedData,
              ),
          IconButton(
            icon: const Icon(Icons.logout), 
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: Consumer<FoodProvider>(
        builder: (context, foodProvider, _) {
          if (foodProvider.isLoading) return const Center(child: CircularProgressIndicator());
          if (foodProvider.foods.isEmpty) return const Center(child: Text('Chưa có món ăn nào. Nhấn nút ☁️ để tải mẫu.'));
          
          return ListView.builder(
            itemCount: foodProvider.foods.length,
            itemBuilder: (context, index) {
              final food = foodProvider.foods[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(food.image, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.fastfood)),
                ),
                title: Text(food.name),
                subtitle: Text('${food.price}đ - ${food.category}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFoodDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
