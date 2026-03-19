import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/store.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';

class StoreDetailScreen extends StatefulWidget {
  final String storeId;
  const StoreDetailScreen({super.key, required this.storeId});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  Store? _store;
  List<Product> _products = [];
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = false; });
    try {
      final res = await ApiService.getStore(widget.storeId);
      final data = res['data'] as Map<String, dynamic>;
      setState(() {
        _store = Store.fromJson(data);
        _products = (data['products'] as List<dynamic>? ?? [])
            .map((p) => Product.fromJson(p))
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() { _loading = false; _error = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFFBF0),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B))),
      );
    }

    if (_error || _store == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFFBF0),
        appBar: AppBar(title: Text('Boutique', style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.store_mall_directory_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 12),
              Text('Boutique introuvable', style: GoogleFonts.cairo(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: Text('Réessayer', style: GoogleFonts.cairo()),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      body: RefreshIndicator(
        onRefresh: _load,
        color: const Color(0xFFF59E0B),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: const Color(0xFFF59E0B),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  _store!.name,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
                  ),
                ),
                background: _store!.coverImage != null
                    ? Image.network(_store!.coverImage!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _storePlaceholder())
                    : _storePlaceholder(),
              ),
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined),
                      onPressed: cart.isEmpty ? null : () => Navigator.pushNamed(context, '/cart'),
                    ),
                    if (cart.itemCount > 0)
                      Positioned(
                        right: 6, top: 6,
                        child: Container(
                          width: 18, height: 18,
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: Center(child: Text('${cart.itemCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // Store info
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_store!.name, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
                              if (_store!.nameAr != null)
                                Text(_store!.nameAr!, style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFFF59E0B))),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: (_store!.isOpen ? const Color(0xFF10B981) : Colors.grey).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _store!.isOpen ? 'Ouvert' : 'Fermé',
                            style: GoogleFonts.cairo(
                              color: _store!.isOpen ? const Color(0xFF10B981) : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_store!.description != null) ...[
                      const SizedBox(height: 8),
                      Text(_store!.description!, style: GoogleFonts.cairo(color: const Color(0xFF6B7280), fontSize: 13)),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFF59E0B), size: 15),
                        Text(
                          ' ${_store!.rating} (${_store!.reviewCount} avis)',
                          style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(width: 14),
                        const Icon(Icons.location_on_outlined, size: 15, color: Color(0xFF9CA3AF)),
                        Text(
                          _store!.district ?? _store!.city,
                          style: GoogleFonts.cairo(color: const Color(0xFF9CA3AF), fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _infoChip(Icons.delivery_dining, '${_store!.deliveryFee.toInt()} MRU livraison'),
                        const SizedBox(width: 10),
                        _infoChip(Icons.receipt_outlined, 'Min: ${_store!.minOrder.toInt()} MRU'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Menu header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text('Menu', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),

            // Products grid
            _products.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.restaurant_menu_outlined, size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text('Aucun produit disponible', style: GoogleFonts.cairo(color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _ProductCard(product: _products[i], storeName: _store!.name),
                        childCount: _products.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: cart.itemCount > 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/cart'),
              backgroundColor: const Color(0xFFF59E0B),
              label: Text(
                'Panier (${cart.itemCount}) · ${cart.subtotal.toStringAsFixed(0)} MRU',
                style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
            )
          : null,
    );
  }

  Widget _storePlaceholder() => Container(
        color: const Color(0xFFF59E0B).withOpacity(0.15),
        child: const Center(child: Icon(Icons.storefront_outlined, size: 80, color: Color(0xFFF59E0B))),
      );

  Widget _infoChip(IconData icon, String label) => Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF6B7280))),
        ],
      );
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final String storeName;

  const _ProductCard({required this.product, required this.storeName});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final inCart = context.watch<CartProvider>().items.any((i) => i.productId == product.id);
    final isAvailable = product.status == 'AVAILABLE';

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                SizedBox.expand(
                  child: product.images.isNotEmpty
                      ? Image.network(product.images[0], fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imagePlaceholder())
                      : _imagePlaceholder(),
                ),
                if (!isAvailable)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.45),
                      child: Center(
                        child: Text('Indisponible', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                if (product.nameAr != null)
                  Text(product.nameAr!,
                      style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF9CA3AF)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(0)} MRU',
                          style: GoogleFonts.cairo(color: const Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        if (product.originalPrice != null)
                          Text(
                            '${product.originalPrice!.toStringAsFixed(0)} MRU',
                            style: GoogleFonts.cairo(color: const Color(0xFF9CA3AF), fontSize: 10, decoration: TextDecoration.lineThrough),
                          ),
                      ],
                    ),
                    GestureDetector(
                      onTap: isAvailable
                          ? () {
                              cart.addItem(product, storeNameParam: storeName);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.name} ajouté', style: GoogleFonts.cairo()),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: const Color(0xFF10B981),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            }
                          : null,
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? (inCart ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
                              : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          inCart ? Icons.check : Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
        color: const Color(0xFFF3F4F6),
        child: const Center(child: Icon(Icons.fastfood_outlined, color: Color(0xFFF59E0B), size: 40)),
      );
}
