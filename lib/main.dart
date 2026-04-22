import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/index.dart';
import 'providers/index.dart';
import 'screens/index.dart';
import 'services/firebase_config.dart';
import 'utils/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FoodProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme(),
        debugShowCheckedModeBanner: false,
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            // Kiểm tra người dùng đã đăng nhập hay chưa
            if (authProvider.isLoggedIn) {
              return const MainShellScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const MainShellScreen(),
          '/cart': (context) => const CartScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/orders': (context) => const OrdersScreen(),
          '/food-detail': (context) {
            final food = ModalRoute.of(context)!.settings.arguments;
            return FoodDetailScreen(food: food as FoodItem);
          },
        },
      ),
    );
  }
}
