import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/index.dart';
import '../providers/index.dart';
import '../utils/index.dart';
import '../widgets/index.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<FoodProvider>().loadFoods());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(FoodItem food) {
    context.read<CartProvider>().addItem(food);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${food.name} đã được thêm vào giỏ'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = context.watch<FoodProvider>();
    final cartProvider = context.watch<CartProvider>();

    List<FoodItem> displayedFoods = foodProvider.foods;
    final searchQuery = _searchController.text;
    if (searchQuery.isNotEmpty) {
      displayedFoods = foodProvider.searchFoods(searchQuery);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.home),
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).pushNamed('/cart');
                },
              ),
              if (cartProvider.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '${cartProvider.itemCount}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (_) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: AppStrings.search,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    child: const Icon(Icons.close),
                  )
                      : null,
                ),
              ),
            ),
            // Categories
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: foodProvider.categories.length,
                itemBuilder: (context, index) {
                  final category = foodProvider.categories[index];
                  final isSelected = _selectedCategoryIndex == index;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                        foodProvider.loadFoodsByCategory(category);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.gray100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.gray700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Foods Grid
            if (foodProvider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (displayedFoods.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    searchQuery.isNotEmpty
                        ? 'Không tìm thấy kết quả cho "$searchQuery"'
                        : 'Không có món ăn nào',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: displayedFoods.length,
                  itemBuilder: (context, index) {
                    final food = displayedFoods[index];
                    return FoodCard(
                      food: food,
                      onTap: () {
                        Navigator.of(
                          context,
                        ).pushNamed('/food-detail', arguments: food);
                      },
                      onAddToCart: () => _addToCart(food),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
