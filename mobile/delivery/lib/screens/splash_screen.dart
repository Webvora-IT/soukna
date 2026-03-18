import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    while (auth.loading && mounted) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, auth.isAuthenticated ? '/orders' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2937),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.4), blurRadius: 24)],
              ),
              child: const Icon(Icons.delivery_dining, color: Colors.white, size: 52),
            ),
            const SizedBox(height: 24),
            const Text('SOUKNA', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 3)),
            const SizedBox(height: 8),
            const Text('Application Livreur', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16)),
            const SizedBox(height: 4),
            const Text('تطبيق التوصيل', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 14, fontFamily: 'Cairo')),
          ],
        ),
      ),
    );
  }
}
