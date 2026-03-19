import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/order_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/orders/order_list_screen.dart';
import 'screens/orders/order_detail_screen.dart';
import 'screens/profile/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SouknaDeliveryApp());
}

class SouknaDeliveryApp extends StatelessWidget {
  const SouknaDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DeliveryOrderProvider()),
      ],
      child: MaterialApp(
        title: 'SOUKNA Livraison',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFF59E0B),
            primary: const Color(0xFFF59E0B),
            secondary: const Color(0xFF10B981),
          ),
          textTheme: GoogleFonts.cairoTextTheme(),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF1F2937),
            foregroundColor: Colors.white,
            titleTextStyle: GoogleFonts.cairo(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white,
            ),
          ),
          scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/orders': (context) => const OrderListScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/order-detail') {
            final orderId = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => OrderDetailScreen(orderId: orderId ?? ''),
            );
          }
          return null;
        },
      ),
    );
  }
}
