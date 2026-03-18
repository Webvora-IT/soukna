import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../models/store.dart';
import '../../models/category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Store> _stores = [];
  List<Category> _categories = [];
  String? _selectedType;
  String _search = '';
  bool _loading = true;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.getStores(type: _selectedType),
        ApiService.getCategories(),
      ]);
      setState(() {
        _stores = (results[0]['data'] as List).map((s) => Store.fromJson(s)).toList();
        _categories = (results[1]['data'] as List).map((c) => Category.fromJson(c)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
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
    final filteredStores = _stores.where((s) =>
      _search.isEmpty || s.name.toLowerCase().contains(_search.toLowerCase())
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SOUKNA', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Nouakchott, Mauritanie', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.pushNamed(context, '/cart'),
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 8, top: 8,
                  child: Container(
                    width: 18, height: 18,
                    decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle),
                    child: Center(
                      child: Text('${cart.itemCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'Rechercher une boutique...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
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
                    final selected = _selectedType == t['value'];
                    return FilterChip(
                      label: Text('${t['icon']} ${t['label']}'),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => _selectedType = t['value'] as String?);
                        _loadData();
                      },
                      selectedColor: const Color(0xFFF59E0B).withOpacity(0.2),
                      checkmarkColor: const Color(0xFFF59E0B),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Stores list
            _loading
                ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                : SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final store = filteredStores[i];
                          return _StoreCard(store: store);
                        },
                        childCount: filteredStores.length,
                      ),
                    ),
                  ),
          ],
        ),
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
                    ? Image.network(store.coverImage!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const _PlaceholderCover())
                    : const _PlaceholderCover(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Logo
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: store.logo != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(store.logo!, fit: BoxFit.cover))
                        : const Icon(Icons.store, color: Color(0xFFF59E0B), size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(store.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        if (store.nameAr != null)
                          Text(store.nameAr!, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontFamily: 'Cairo')),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFF59E0B), size: 14),
                            Text(' ${store.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            Text(' (${store.reviewCount})', style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                            const SizedBox(width: 8),
                            const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF9CA3AF)),
                            Text(store.district ?? store.city, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
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
                          color: store.isOpen ? const Color(0xFF10B981).withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          store.isOpen ? 'Ouvert' : 'Fermé',
                          style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: store.isOpen ? const Color(0xFF10B981) : Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${store.deliveryFee.toInt()} MRU', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                      const Text('livraison', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
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
