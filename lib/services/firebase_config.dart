import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Firebase configuration
// TODO: Replace placeholder values with actual values from google-services.json or Firebase Console
// To get these values:
// 1. Go to https://console.firebase.google.com
// 2. Select your project → Project Settings
// 3. Find the values in "google-services.json" or SDK setup section:
//    - projectId: from client[0].project_id or project_info.project_id
//    - apiKey: from client[0].api_key[0].current_key
//    - appId: from client[0].client_info.mobilesdk_app_id
//    - messagingSenderId: from project_info.project_number
//    - storageBucket: from project_info.storage_bucket

class FirebaseConfig {
  static const String projectId = 'apdatdoan'; // Replace with your project ID
  static const String apiKey =
      'AIzaSyC_test_key_replace_with_real_key'; // Replace with your API key
  static const String appId =
      '1:123456789:android:abc123def456'; // Replace with your app ID
  static const String messagingSenderId =
      '123456789'; // Replace with your messaging sender ID

  static bool _initialized = false;

  // Initialize Firebase with error handling
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: apiKey,
          appId: appId,
          messagingSenderId: messagingSenderId,
          projectId: projectId,
          storageBucket: '$projectId.appspot.com',
        ),
      );
      _initialized = true;
      print('✅ Firebase initialized successfully');
    } on FirebaseException catch (e) {
      print('❌ Firebase initialization error: ${e.code} - ${e.message}');
      print(
          'ℹ️ Make sure to configure Firebase credentials in firebase_config.dart');
      _initialized = false;
    } catch (e) {
      print('❌ Firebase initialization error: $e');
      print(
          'ℹ️ Make sure to configure Firebase credentials in firebase_config.dart');
      _initialized = false;
    }
  }

  // Get Firebase instances with null-safety
  static FirebaseAuth get firebaseAuth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      print('Error accessing FirebaseAuth: $e');
      rethrow;
    }
  }

  static FirebaseFirestore get firebaseFirestore {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      print('Error accessing FirebaseFirestore: $e');
      rethrow;
    }
  }

  static FirebaseStorage get firebaseStorage {
    try {
      return FirebaseStorage.instance;
    } catch (e) {
      print('Error accessing FirebaseStorage: $e');
      rethrow;
    }
  }

  // Check if user is authenticated
  static bool get isAuthenticated => firebaseAuth.currentUser != null;

  static User? get currentUser => firebaseAuth.currentUser;

  static String? get currentUserId => firebaseAuth.currentUser?.uid;
}
