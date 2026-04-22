import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/index.dart';
import 'firebase_auth_service.dart';
import 'firebase_firestore_service.dart';

class ApiService {
  static const String baseUrl =
      'http://localhost:3000/api'; // Thay đổi URL nếu cần
  static String? _token;

  static final FirebaseAuthService _authService = FirebaseAuthService();
  static final FirebaseFirestoreService _firestoreService =
  FirebaseFirestoreService();

  static void setToken(String token) {
    _token = token;
  }

  static Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Auth APIs - Now using Firebase
  static Future<AppUser> register(
      String email,
      String password,
      String name,
      ) async {
    try {
      return await _authService.register(
        email: email,
        password: password,
        name: name,
      );
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  static Future<AppUser> login(
      String email,
      String password,
      ) async {
    try {
      return await _authService.login(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  static Future<AppUser> getCurrentUser() async {
    try {
      return await _authService.getUserData();
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  // Food APIs - Now using Firebase
  static Future<List<FoodItem>> getAllFoods() async {
    try {
      return await _firestoreService.getAllFoods();
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  static Future<List<FoodItem>> getFoodsByCategory(String category) async {
    try {
      return await _firestoreService.getFoodsByCategory(category);
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  static Future<FoodItem> getFoodById(String id) async {
    try {
      return await _firestoreService.getFoodById(id);
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  // Order APIs - Now using Firebase
  static Future<Map<String, dynamic>> createOrder(
      List<CartItem> items,
      String address,
      String notes,
      ) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      final order = await _firestoreService.createOrder(
        userId: currentUser.uid,
        items: items,
        address: address,
        notes: notes,
      );

      return {
        'success': true,
        'order': order.toJson(),
      };
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  static Future<List<Order>> getMyOrders() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      return await _firestoreService.getUserOrders(currentUser.uid);
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  static Future<Order> getOrderById(String id) async {
    try {
      return await _firestoreService.getOrderById(id);
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  // User APIs - Now using Firebase
  static Future<AppUser> updateUser(AppUser user) async {
    try {
      return await _authService.updateUserProfile(
        name: user.name,
        phone: user.phone,
        address: user.address,
      );
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  // Legacy HTTP methods (if needed for fallback or other services)
  static Future<Map<String, dynamic>> _httpRegister(
      String email,
      String password,
      String name,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'name': name}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Đăng ký thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  static Future<Map<String, dynamic>> _httpLogin(
      String email,
      String password,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        return data;
      } else {
        throw Exception('Đăng nhập thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  static Future<AppUser> _httpGetCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return AppUser.fromJson(jsonDecode(response.body)['data']);
      } else {
        throw Exception('Lấy thông tin người dùng thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  static Future<List<FoodItem>> _httpGetAllFoods() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/foods'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        return data.map((item) => FoodItem.fromJson(item)).toList();
      } else {
        throw Exception('Lấy danh sách thực đơn thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  static Future<List<FoodItem>> _httpGetFoodsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/foods?category=$category'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        return data.map((item) => FoodItem.fromJson(item)).toList();
      } else {
        throw Exception('Lấy thực đơn theo loại thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  static Future<FoodItem> _httpGetFoodById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/foods/$id'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return FoodItem.fromJson(jsonDecode(response.body)['data']);
      } else {
        throw Exception('Lấy chi tiết thực đơn thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  static Future<Map<String, dynamic>> _httpCreateOrder(
      List<CartItem> items,
      String address,
      String notes,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: _getHeaders(),
        body: jsonEncode({
          'items': items
              .map(
                (item) => {'foodId': item.food.id, 'quantity': item.quantity},
          )
              .toList(),
          'address': address,
          'notes': notes,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Tạo đơn hàng thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  static Future<List<Order>> _httpGetMyOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/my-orders'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        return data.map((item) => Order.fromJson(item)).toList();
      } else {
        throw Exception('Lấy đơn hàng thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  static Future<Order> _httpGetOrderById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$id'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return Order.fromJson(jsonDecode(response.body)['data']);
      } else {
        throw Exception('Lấy chi tiết đơn hàng thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  static Future<AppUser> _httpUpdateUser(AppUser user) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/me'),
        headers: _getHeaders(),
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        return AppUser.fromJson(jsonDecode(response.body)['data']);
      } else {
        throw Exception('Cập nhật thông tin thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }
}
