import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/index.dart';
import 'firebase_config.dart';

class FirebaseFirestoreService {
  final _firestore = FirebaseConfig.firebaseFirestore;

  // ==================== Food Operations ====================

  /// Get all foods
  Future<List<FoodItem>> getAllFoods({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection('foods')
          .orderBy('name')
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => FoodItem.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      }))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách thực đơn: $e');
    }
  }

  /// Get foods by category
  Future<List<FoodItem>> getFoodsByCategory(
      String category, {
        int limit = 20,
        DocumentSnapshot? startAfter,
      }) async {
    try {
      Query query = _firestore
          .collection('foods')
          .where('category', isEqualTo: category)
          .orderBy('name')
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => FoodItem.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      }))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy thực đơn theo loại: $e');
    }
  }

  /// Search foods
  Future<List<FoodItem>> searchFoods(String query) async {
    try {
      final snapshot = await _firestore
          .collection('foods')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => FoodItem.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      }))
          .toList();
    } catch (e) {
      throw Exception('Lỗi tìm kiếm: $e');
    }
  }

  /// Get food by ID
  Future<FoodItem> getFoodById(String id) async {
    try {
      final doc = await _firestore.collection('foods').doc(id).get();

      if (!doc.exists) {
        throw Exception('Không tìm thấy thực đơn');
      }

      return FoodItem.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      });
    } catch (e) {
      throw Exception('Lỗi lấy chi tiết thực đơn: $e');
    }
  }

  /// Get all categories
  Future<List<String>> getCategories() async {
    try {
      final snapshot = await _firestore
          .collection('foods')
          .select('category')
          .get();

      final categories = <String>{};
      for (var doc in snapshot.docs) {
        final category = doc['category'];
        if (category != null) {
          categories.add(category);
        }
      }

      return categories.toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh mục: $e');
    }
  }

  // ==================== Order Operations ====================

  /// Create order
  Future<Order> createOrder({
    required String userId,
    required List<CartItem> items,
    required String address,
    required String notes,
  }) async {
    try {
      final ordersRef = _firestore.collection('orders').doc();

      final orderData = {
        'id': ordersRef.id,
        'userId': userId,
        'items': items
            .map((item) => {
          'foodId': item.food.id,
          'foodName': item.food.name,
          'quantity': item.quantity,
          'price': item.totalPrice,
        })
            .toList(),
        'totalPrice': items.fold<double>(
          0,
              (sum, item) => sum + item.totalPrice,
        ),
        'status': 'pending',
        'address': address,
        'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
        'estimatedDelivery':
        DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
      };

      await ordersRef.set(orderData);

      return Order.fromJson(orderData);
    } catch (e) {
      throw Exception('Lỗi tạo đơn hàng: $e');
    }
  }

  /// Get user orders
  Future<List<Order>> getUserOrders(String userId, {int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Order.fromJson({
        ...doc.data() as Map<String, dynamic>,
      }))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy đơn hàng: $e');
    }
  }

  /// Get order by ID
  Future<Order> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();

      if (!doc.exists) {
        throw Exception('Không tìm thấy đơn hàng');
      }

      return Order.fromJson({
        ...doc.data() as Map<String, dynamic>,
      });
    } catch (e) {
      throw Exception('Lỗi lấy chi tiết đơn hàng: $e');
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi cập nhật trạng thái đơn: $e');
    }
  }

  /// Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi hủy đơn hàng: $e');
    }
  }

  // ==================== Reviews Operations ====================

  /// Add review for food
  Future<void> addReview({
    required String foodId,
    required String userId,
    required double rating,
    required String comment,
  }) async {
    try {
      await _firestore
          .collection('foods')
          .doc(foodId)
          .collection('reviews')
          .add({
        'userId': userId,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi thêm đánh giá: $e');
    }
  }

  /// Get reviews for food
  Future<List<Map<String, dynamic>>> getReviews(String foodId) async {
    try {
      final snapshot = await _firestore
          .collection('foods')
          .doc(foodId)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Lỗi lấy đánh giá: $e');
    }
  }

  // ==================== Favorites Operations ====================

  /// Add to favorites
  Future<void> addToFavorites(String userId, String foodId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(foodId)
          .set({
        'foodId': foodId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi thêm yêu thích: $e');
    }
  }

  /// Remove from favorites
  Future<void> removeFromFavorites(String userId, String foodId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(foodId)
          .delete();
    } catch (e) {
      throw Exception('Lỗi xóa yêu thích: $e');
    }
  }

  /// Get user favorites
  Future<List<String>> getUserFavorites(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw Exception('Lỗi lấy yêu thích: $e');
    }
  }

  /// Check if food is favorite
  Future<bool> isFavorite(String userId, String foodId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(foodId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // ==================== Address Operations ====================

  /// Add delivery address
  Future<void> addDeliveryAddress({
    required String userId,
    required String address,
    required String phone,
    required bool isDefault,
  }) async {
    try {
      if (isDefault) {
        // Set other addresses to non-default
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .where('isDefault', isEqualTo: true)
            .get()
            .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.update({'isDefault': false});
          }
        });
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .add({
        'address': address,
        'phone': phone,
        'isDefault': isDefault,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi thêm địa chỉ: $e');
    }
  }

  /// Get user addresses
  Future<List<Map<String, dynamic>>> getUserAddresses(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Lỗi lấy địa chỉ: $e');
    }
  }
}

extension on CollectionReference<Map<String, dynamic>> {
  select(String s) {}
}
