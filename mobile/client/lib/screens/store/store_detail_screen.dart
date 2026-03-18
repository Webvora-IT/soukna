import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
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
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _store == null
              ? const Center(child: Text('Boutique introuvable'))
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 200,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(_store!.name, style: const TextStyle(shadows: [Shadow(color: Colors.black54, blurRadius: 4)])),
                        background: _store!.coverImage != null
                            ? Image.network(_store!.coverImage!, fit: BoxFit.cover)
                            : Container(color: const Color(0xFFF59E0B).withOpacity(0.2),
                                child: const Icon(Icons.storefront_outlined, size: 80, color: Color(0xFFF59E0B))),
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
                                right: 8, top: 8,
                                child: Container(
                                  width: 16, height: 16,
                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  child: Center(child: Text('${cart.itemCount}', style: const TextStyle(color: Colors.white, fontSize: 10))),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_store!.nameAr != null)
                              Text(_store!.nameAr!, style: const TextStyle(fontSize: 16, fontFamily: 'Cairo', color: Color(0xFFF59E0B))),
                            if (_store!.description != null) ...[
                              const SizedBox(height: 8),
                              Text(_store!.description!, style: const TextStyle(color: Color(0xFF6B7280))),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Color(0xFFF59E0B), size: 16),
                                Text(' ${_store!.rating} (${_store!.reviewCount} avis)', style: const TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(width: 16),
                                const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF9CA3AF)),
                                Text(_store!.district ?? _store!.city, style: const TextStyle(color: Color(0xFF9CA3AF))),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (_store!.isOpen ? const Color(0xFF10B981) : Colors.grey).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _store!.isOpen ? 'Ouvert' : 'Fermé',
                                    style: TextStyle(
                                      color: _store!.isOpen ? const Color(0xFF10B981) : Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.delivery_dining, size: 16, color: Color(0xFF9CA3AF)),
                                Text(' Livraison: ${_store!.deliveryFee.toInt()} MRU', style: const TextStyle(color: Color(0xFF6B7280))),
                                const SizedBox(width: 16),
                                const Icon(Icons.receipt_outlined, size: 16, color: Color(0xFF9CA3AF)),
                                Text(' Min: ${_store!.minOrder.toInt()} MRU', style: const TextStyle(color: Color(0xFF6B7280))),
                              ],
                            ),
                            const Divider(height: 24),
                            const Text('Menu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _ProductCard(product: _products[i], storeName: _store!.name),
                          childCount: _products.length,
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: cart.itemCount > 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/cart'),
              backgroundColor: const Color(0xFFF59E0B),
              label: Text('Panier (${cart.itemCount}) - ${cart.subtotal.toStringAsFixed(0)} MRU', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
            )
          : null,
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final String storeName;

  const _ProductCard({required this.product, required this.storeName});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: product.images.isNotEmpty
                ? Image.network(product.images[0], width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: const Color(0xFFF3F4F6), child: const Icon(Icons.fastfood_outlined, color: Color(0xFFF59E0B), size: 40)))
                : Container(color: const Color(0xFFF3F4F6), child: const Icon(Icons.fastfood_outlined, color: Color(0xFFF59E0B), size: 40)),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                if (product.nameAr != null)
                  Text(product.nameAr!, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), fontFamily: 'Cairo')),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${product.price.toStringAsFixed(0)} MRU', style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 13)),
                        if (product.originalPrice != null)
                          Text('${product.originalPrice!.toStringAsFixed(0)} MRU', style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10, decoration: TextDecoration.lineThrough)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        cart.addItem(product, storeNameParam: storeName);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${product.name} ajouté'), duration: const Duration(seconds: 1), backgroundColor: const Color(0xFF10B981)),
                        );
                      },
                      child: Container(
                        width: 32, height: 32,
                        decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle),
                        child: const Icon(Icons.add, color: Colors.white, size: 20),
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
}
