import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/api_service.dart';

class FoodProvider extends ChangeNotifier {
  List<FoodItem> _foods = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'Tất Cả';

  List<FoodItem> get foods => _foods;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;

  List<String> get categories => [
    'Tất Cả',
    'Tất Cả',
    'Thức Ăn',
    'Đồ Uống',
    'Tăng Năng Lực',
  ];

  Future<void> loadFoods() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _foods = await ApiService.getAllFoods();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFoodsByCategory(String category) async {
    _selectedCategory = category;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (category == 'Tất Cả') {
        _foods = await ApiService.getAllFoods();
      } else {
        _foods = await ApiService.getFoodsByCategory(category);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  List<FoodItem> searchFoods(String query) {
    if (query.isEmpty) {
      return _foods;
    }
    return _foods
        .where(
          (food) =>
      food.name.toLowerCase().contains(query.toLowerCase()) ||
          food.description.toLowerCase().contains(query.toLowerCase()),
    )
        .toList();
  }
}
