import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/index.dart';
import '../models/app_user.dart';
import 'firebase_config.dart';

class FirebaseAuthService {
  final _firebaseAuth = FirebaseConfig.firebaseAuth;
  final _firestore = FirebaseConfig.firebaseFirestore;

  /// Register new user
  Future<AppUser> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create user with email and password
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        throw Exception('Tạo tài khoản thất bại');
      }

      // Create user document in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'id': user.uid,
        'email': email,
        'name': name,
        'phone': null,
        'address': null,
        'avatar': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return AppUser(
        id: user.uid,
        email: user.email ?? email,
        name: name,
        phone: null,
        address: null,
        avatar: null,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Lỗi đăng ký: $e');
    }
  }

  /// Login user
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        throw Exception('Đăng nhập thất bại');
      }

      // Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      final userData = userDoc.data() ?? {};

      return AppUser(
        id: user.uid,
        email: userData['email'] ?? user.email ?? email,
        name: userData['name'] ?? 'User',
        phone: userData['phone'],
        address: userData['address'],
        avatar: userData['avatar'],
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Lỗi đăng nhập: $e');
    }
  }

  /// Get current user
  Future<firebase_auth.User?> getCurrentUser() async {
    try {
      return _firebaseAuth.currentUser;
    } catch (e) {
      throw Exception('Lỗi lấy thông tin người dùng: $e');
    }
  }

  /// Get user data from Firestore
  Future<AppUser> getUserData() async {
    try {
      final currentUser = _firebaseAuth.currentUser;

      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      final userDoc =
      await _firestore.collection('users').doc(currentUser.uid).get();

      final data = userDoc.data();

      if (data == null) {
        throw Exception('Không tìm thấy dữ liệu người dùng');
      }

      return AppUser.fromJson(data);
    } catch (e) {
      throw Exception('Lỗi lấy dữ liệu người dùng: $e');
    }
  }

  /// Update user profile
  Future<AppUser> updateUserProfile({
    required String name,
    required String? phone,
    required String? address,
  }) async {
    try {
      final currentUser = _firebaseAuth.currentUser;

      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      await _firestore.collection('users').doc(currentUser.uid).update({
        'name': name,
        'phone': phone,
        'address': address,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final userDoc =
      await _firestore.collection('users').doc(currentUser.uid).get();

      return AppUser.fromJson(userDoc.data()!);
    } catch (e) {
      throw Exception('Lỗi cập nhật hồ sơ: $e');
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final currentUser = _firebaseAuth.currentUser;

      if (currentUser == null || currentUser.email == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      // Re-authenticate
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: currentUser.email!,
        password: currentPassword,
      );

      await currentUser.reauthenticateWithCredential(credential);

      // Update password
      await currentUser.updatePassword(newPassword);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Lỗi thay đổi mật khẩu: $e');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Lỗi gửi email: $e');
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Lỗi đăng xuất: $e');
    }
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Người dùng không tồn tại';
      case 'wrong-password':
        return 'Mật khẩu không đúng';
      case 'email-already-in-use':
        return 'Email đã được sử dụng';
      case 'weak-password':
        return 'Mật khẩu quá yếu';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'operation-not-allowed':
        return 'Không thể thực hiện phép toán này';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau';
      default:
        return 'Lỗi xác thực: ${e.message}';
    }
  }
}
