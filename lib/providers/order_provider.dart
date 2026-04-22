import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMyOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await ApiService.getMyOrders();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createOrder(
      List<CartItem> items,
      String address,
      String notes,
      ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.createOrder(items, address, notes);
      await loadMyOrders();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Order?> getOrderById(String id) async {
    try {
      return await ApiService.getOrderById(id);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }
}
