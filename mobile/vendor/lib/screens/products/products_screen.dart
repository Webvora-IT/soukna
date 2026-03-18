import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';
import 'add_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> _products = [];
  bool _loading = true;
  String? _error;
  String _filterStatus = 'ALL';

  final List<Map<String, String>> _filters = [
    {'key': 'ALL', 'label': 'Tous'},
    {'key': 'PENDING_REVIEW', 'label': 'En attente'},
    {'key': 'AVAILABLE', 'label': 'Disponibles'},
    {'key': 'REJECTED', 'label': 'Refusés'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final status = _filterStatus == 'ALL' ? null : _filterStatus;
      final data = await ApiService.getProducts(status: status);
      if (data['success'] == true) {
        final list = (data['data'] as List? ?? [])
            .map((p) => Product.fromJson(p))
            .toList();
        setState(() {
          _products = list;
          _loading = false;
        });
      } else {
        setState(() {
          _error = data['message'] ?? 'Erreur';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur réseau';
        _loading = false;
      });
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Confirmer la suppression',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Supprimer "${product.name}" ?',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ApiService.deleteProduct(product.id);
      _loadProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produit supprimé'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la suppression'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: Text(l10n.t('products')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filters[i];
                final isSelected = _filterStatus == f['key'];
                return GestureDetector(
                  onTap: () {
                    setState(() => _filterStatus = f['key']!);
                    _loadProducts();
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      f['label']!,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.grey[400],
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFF59E0B)))
                : _error != null
                    ? _buildError(l10n)
                    : _products.isEmpty
                        ? EmptyState(
                            icon: Icons.inventory_2_outlined,
                            title: l10n.t('no_products'),
                            subtitle:
                                'Ajoutez votre premier produit avec le bouton +',
                          )
                        : RefreshIndicator(
                            color: const Color(0xFFF59E0B),
                            backgroundColor: const Color(0xFF1A1A2E),
                            onRefresh: _loadProducts,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _products.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, i) =>
                                  _buildProductCard(_products[i]),
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
          if (result == true) _loadProducts();
        },
        backgroundColor: const Color(0xFFF59E0B),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: Text(l10n.t('add_product')),
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey[600]),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: _loadProducts, child: Text(l10n.t('retry'))),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final hasImage = product.images.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: product.status == 'REJECTED'
            ? Border.all(color: const Color(0xFFEF4444).withOpacity(0.4))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: hasImage
                      ? CachedNetworkImage(
                          imageUrl: product.images.first,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              _productPlaceholder(),
                        )
                      : _productPlaceholder(),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          StatusBadge(status: product.status, fontSize: 10),
                        ],
                      ),
                      if (product.nameAr != null &&
                          product.nameAr!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          product.nameAr!,
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 12),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '${product.price.toStringAsFixed(0)} MRU',
                            style: const TextStyle(
                              color: Color(0xFFF59E0B),
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          if (product.originalPrice != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              '${product.originalPrice!.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                          const Spacer(),
                          // Delete button
                          GestureDetector(
                            onTap: () => _deleteProduct(product),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Color(0xFFEF4444),
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (product.unit != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Unité: ${product.unit}',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Rejection reason box
          if (product.status == 'REJECTED' &&
              product.rejectionReason != null) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Color(0xFFEF4444), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      product.rejectionReason!,
                      style: const TextStyle(
                          color: Color(0xFFEF4444), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Pending info box
          if (product.status == 'PENDING_REVIEW') ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hourglass_empty,
                      color: Color(0xFFF59E0B), size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'En attente de validation par l\'équipe SOUKNA',
                      style: TextStyle(
                          color: Color(0xFFF59E0B), fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _productPlaceholder() {
    return Container(
      color: const Color(0xFF0F0F1A),
      child: const Center(
        child: Text('🛒', style: TextStyle(fontSize: 32)),
      ),
    );
  }
}
