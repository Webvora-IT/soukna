import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_screen.dart';
import '../products/products_screen.dart';
import '../orders/orders_screen.dart';
import '../store/store_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _pendingOrdersCount = 0;

  void updatePendingCount(int count) {
    if (mounted) setState(() => _pendingOrdersCount = count);
  }

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(),
      const ProductsScreen(),
      OrdersScreen(onPendingCountChanged: updatePendingCount),
      const StoreScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFFF59E0B),
            unselectedItemColor: Colors.grey[600],
            selectedLabelStyle: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 10),
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard_outlined, size: 22),
                activeIcon: const Icon(Icons.dashboard, size: 22),
                label: l10n.t('dashboard'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.inventory_2_outlined, size: 22),
                activeIcon: const Icon(Icons.inventory_2, size: 22),
                label: l10n.t('products'),
              ),
              BottomNavigationBarItem(
                icon: _pendingOrdersCount > 0
                    ? Badge(
                        label: Text('$_pendingOrdersCount',
                            style: const TextStyle(fontSize: 10)),
                        backgroundColor: const Color(0xFFEF4444),
                        child: const Icon(Icons.shopping_bag_outlined, size: 22),
                      )
                    : const Icon(Icons.shopping_bag_outlined, size: 22),
                activeIcon: _pendingOrdersCount > 0
                    ? Badge(
                        label: Text('$_pendingOrdersCount',
                            style: const TextStyle(fontSize: 10)),
                        backgroundColor: const Color(0xFFEF4444),
                        child: const Icon(Icons.shopping_bag, size: 22),
                      )
                    : const Icon(Icons.shopping_bag, size: 22),
                label: l10n.t('orders'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.storefront_outlined, size: 22),
                activeIcon: const Icon(Icons.storefront, size: 22),
                label: l10n.t('store'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_outlined, size: 22),
                activeIcon: const Icon(Icons.settings, size: 22),
                label: l10n.t('settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
