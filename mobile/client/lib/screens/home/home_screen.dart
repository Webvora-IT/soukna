import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/store_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/store.dart';
import '../order/orders_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreProvider>().resetFilters();
      context.read<StoreProvider>().loadData();
      context.read<NotificationProvider>().load();
    });
  }

  final _storeTypes = [
    {'value': null, 'label': 'Tout', 'icon': '🛍️'},
    {'value': 'RESTAURANT', 'label': 'Restaurants', 'icon': '🍽️'},
    {'value': 'GROCERY', 'label': 'Épiceries', 'icon': '🛒'},
    {'value': 'BOUTIQUE', 'label': 'Boutiques', 'icon': '👗'},
    {'value': 'SERVICE', 'label': 'Services', 'icon': '🔧'},
  ];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final storeProvider = context.watch<StoreProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final auth = context.watch<AuthProvider>();

    final screens = [
      _buildStoreList(storeProvider, cart, context),
      const OrdersScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: _navIndex == 0
          ? AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SOUKNA', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  Text(
                    'Nouakchott, Mauritanie',
                    style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF6B7280)),
                  ),
                ],
              ),
              actions: [
                // Notification bell with badge
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () => Navigator.pushNamed(context, '/notifications'),
                    ),
                    if (notifProvider.unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              notifProvider.unreadCount > 9 ? '9+' : '${notifProvider.unreadCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                // Cart button with badge
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined),
                      onPressed: () => Navigator.pushNamed(context, '/cart'),
                    ),
                    if (cart.itemCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${cart.itemCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            )
          : null,
      body: screens[_navIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        selectedItemColor: const Color(0xFFF59E0B),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Commandes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildStoreList(StoreProvider storeProvider, CartProvider cart, BuildContext context) {
    final filtered = storeProvider.filteredStores;

    return RefreshIndicator(
      onRefresh: storeProvider.refresh,
      color: const Color(0xFFF59E0B),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: storeProvider.setSearch,
                decoration: InputDecoration(
                  hintText: 'Rechercher une boutique...',
                  hintStyle: GoogleFonts.cairo(color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFF59E0B)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                style: GoogleFonts.cairo(),
              ),
            ),
          ),

          // Type filter chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _storeTypes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final t = _storeTypes[i];
                  final selected = storeProvider.selectedType == t['value'];
                  return FilterChip(
                    label: Text(
                      '${t['icon']} ${t['label']}',
                      style: GoogleFonts.cairo(fontSize: 13),
                    ),
                    selected: selected,
                    onSelected: (_) => storeProvider.setType(t['value'] as String?),
                    selectedColor: const Color(0xFFF59E0B).withOpacity(0.2),
                    checkmarkColor: const Color(0xFFF59E0B),
                    backgroundColor: Colors.white,
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Content
          if (storeProvider.loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B))),
            )
          else if (storeProvider.error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_outlined, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(storeProvider.error!, style: GoogleFonts.cairo(color: Colors.grey)),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: storeProvider.refresh,
                      icon: const Icon(Icons.refresh),
                      label: Text('Réessayer', style: GoogleFonts.cairo()),
                    ),
                  ],
                ),
              ),
            )
          else if (filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.storefront_outlined, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      storeProvider.search.isNotEmpty ? 'Aucun résultat' : 'Aucune boutique disponible',
                      style: GoogleFonts.cairo(color: Colors.grey.shade500, fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _StoreCard(store: filtered[i]),
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final Store store;
  const _StoreCard({required this.store});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, '/store', arguments: store.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 140,
                width: double.infinity,
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                child: store.coverImage != null
                    ? Image.network(
                        store.coverImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const _PlaceholderCover(),
                      )
                    : const _PlaceholderCover(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: store.logo != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(store.logo!, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.store, color: Color(0xFFF59E0B), size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.name,
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        if (store.nameAr != null)
                          Text(
                            store.nameAr!,
                            style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF6B7280)),
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFF59E0B), size: 14),
                            Text(
                              ' ${store.rating}',
                              style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              ' (${store.reviewCount})',
                              style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF9CA3AF)),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF9CA3AF)),
                            Text(
                              store.district ?? store.city,
                              style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF9CA3AF)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: store.isOpen
                              ? const Color(0xFF10B981).withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          store.isOpen ? 'Ouvert' : 'Fermé',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: store.isOpen ? const Color(0xFF10B981) : Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${store.deliveryFee.toInt()} MRU',
                        style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF6B7280)),
                      ),
                      Text(
                        'livraison',
                        style: GoogleFonts.cairo(fontSize: 10, color: const Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderCover extends StatelessWidget {
  const _PlaceholderCover();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF59E0B).withOpacity(0.08),
      child: const Center(
        child: Icon(Icons.storefront_outlined, size: 48, color: Color(0xFFF59E0B)),
      ),
    );
  }
}
