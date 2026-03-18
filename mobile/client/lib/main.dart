import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/phone_auth_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/order/checkout_screen.dart';
import 'screens/order/order_tracking_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/store/store_detail_screen.dart';
import 'screens/home/store_list_screen.dart';
import 'screens/order/orders_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr', null);
  await Firebase.initializeApp();
  await NotificationService.initialize();
  runApp(const SouknaApp());
}

class SouknaApp extends StatelessWidget {
  const SouknaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'SOUKNA - سوقنا',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr'),
          Locale('ar'),
          Locale('en'),
        ],
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/phone-auth': (context) => const PhoneAuthScreen(),
          '/home': (context) => const HomeScreen(),
          '/cart': (context) => const CartScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/orders': (context) => const OrdersScreen(),
          '/store-list': (context) => const StoreListScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/store') {
            final storeId = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => StoreDetailScreen(storeId: storeId ?? ''),
            );
          }
          if (settings.name == '/order-tracking') {
            final orderId = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => OrderTrackingScreen(orderId: orderId ?? ''),
            );
          }
          return null;
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    const primaryAmber = Color(0xFFF59E0B);
    const accentEmerald = Color(0xFF10B981);
    const background = Color(0xFFFFFBF0);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryAmber,
        primary: primaryAmber,
        secondary: accentEmerald,
        surface: Colors.white,
        background: background,
      ),
      textTheme: GoogleFonts.cairoTextTheme().copyWith(
        headlineLarge: GoogleFonts.cairo(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1F2937),
        ),
        headlineMedium: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1F2937),
        ),
        titleLarge: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF374151),
        ),
        bodyLarge: GoogleFonts.cairo(fontSize: 16, color: const Color(0xFF374151)),
        bodyMedium: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF6B7280)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1F2937),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAmber,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryAmber, width: 2),
        ),
        labelStyle: GoogleFonts.cairo(color: const Color(0xFF6B7280)),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
    );
  }
}
