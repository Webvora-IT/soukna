import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../models/store.dart';
import '../../widgets/status_badge.dart';
import 'edit_store_screen.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  Store? _store;
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  Future<void> _loadStore() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getStore();
      if (data['success'] == true) {
        setState(() {
          _store = Store.fromJson(data['data']['store'] ?? data['data']);
          _stats = data['data']['stats'];
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

  Future<void> _toggleOpen(bool value) async {
    try {
      await ApiService.updateStore({'isOpen': value});
      setState(() => _store = _store?.copyWith(isOpen: value));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: Text(l10n.t('store')),
        actions: [
          if (_store != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final updated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditStoreScreen(store: _store!)),
                );
                if (updated == true) _loadStore();
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStore,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF59E0B)))
          : _error != null
              ? _buildError(l10n)
              : _store == null
                  ? const Center(child: Text('Boutique introuvable', style: TextStyle(color: Colors.white)))
                  : RefreshIndicator(
                      color: const Color(0xFFF59E0B),
                      backgroundColor: const Color(0xFF1A1A2E),
                      onRefresh: _loadStore,
                      child: _buildContent(l10n),
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
              onPressed: _loadStore, child: Text(l10n.t('retry'))),
        ],
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    final store = _store!;
    return ListView(
      children: [
        // Cover image header
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Cover
            Container(
              height: 160,
              width: double.infinity,
              child: store.coverImage != null
                  ? CachedNetworkImage(
                      imageUrl: store.coverImage!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _coverPlaceholder(),
                    )
                  : _coverPlaceholder(),
            ),
            // Dark overlay
            Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Logo
            Positioned(
              bottom: -40,
              left: 20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0F0F1A), width: 3),
                ),
                child: ClipOval(
                  child: store.logo != null
                      ? CachedNetworkImage(
                          imageUrl: store.logo!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _logoPlaceholder(store),
                        )
                      : _logoPlaceholder(store),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 50),

        // Store name + type + status
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (store.nameAr != null && store.nameAr!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        store.nameAr!,
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _typeBadge(store.type),
                        const SizedBox(width: 8),
                        StatusBadge(status: store.status),
                      ],
                    ),
                  ],
                ),
              ),
              // Edit button
              OutlinedButton.icon(
                onPressed: () async {
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EditStoreScreen(store: store)),
                  );
                  if (updated == true) _loadStore();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF59E0B),
                  side: const BorderSide(color: Color(0xFFF59E0B)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: const Icon(Icons.edit, size: 14),
                label: Text(l10n.t('edit_store'),
                    style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Rating
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              ...List.generate(5, (i) {
                return Icon(
                  i < store.rating.floor() ? Icons.star : Icons.star_border,
                  color: const Color(0xFFF59E0B),
                  size: 16,
                );
              }),
              const SizedBox(width: 6),
              Text(
                store.rating.toStringAsFixed(1),
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              const SizedBox(width: 4),
              Text(
                '(${store.reviewCount} ${l10n.t('reviews')})',
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Stats row
        if (_stats != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _miniStat(
                  '${_stats!['productsCount'] ?? 0}',
                  l10n.t('products_count'),
                  Icons.inventory_2_outlined,
                  const Color(0xFFF59E0B),
                ),
                const SizedBox(width: 12),
                _miniStat(
                  '${_stats!['ordersCount'] ?? 0}',
                  l10n.t('orders_count'),
                  Icons.shopping_bag_outlined,
                  const Color(0xFF10B981),
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),

        // Open/Closed toggle
        _buildInfoCard(
          child: Row(
            children: [
              Icon(
                store.isOpen ? Icons.store : Icons.store_outlined,
                color: store.isOpen
                    ? const Color(0xFF10B981)
                    : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.isOpen ? l10n.t('open') : l10n.t('closed'),
                      style: TextStyle(
                        color: store.isOpen
                            ? const Color(0xFF10B981)
                            : Colors.grey[400],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      l10n.t('is_open'),
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch(
                value: store.isOpen,
                onChanged: _toggleOpen,
                activeColor: const Color(0xFF10B981),
                inactiveThumbColor: Colors.grey[600],
              ),
            ],
          ),
        ),

        // Phone
        if (store.phone != null)
          _buildInfoCard(
            child: _infoRow(Icons.phone_outlined, l10n.t('phone'), store.phone!),
          ),

        // Address
        if (store.address != null)
          _buildInfoCard(
            child: _infoRow(
                Icons.location_on_outlined, l10n.t('address'), store.address!),
          ),

        // District
        if (store.district != null)
          _buildInfoCard(
            child:
                _infoRow(Icons.map_outlined, l10n.t('district'), store.district!),
          ),

        // City
        _buildInfoCard(
          child: _infoRow(Icons.location_city_outlined, l10n.t('city'), store.city),
        ),

        // Schedule
        if (store.openTime != null || store.closeTime != null)
          _buildInfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_outlined,
                        color: Color(0xFFF59E0B), size: 18),
                    const SizedBox(width: 10),
                    Text(
                      'Horaires',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (store.openTime != null) ...[
                      Icon(Icons.wb_sunny_outlined,
                          color: Colors.grey[600], size: 14),
                      const SizedBox(width: 4),
                      Text(
                        store.openTime!,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                    if (store.openTime != null && store.closeTime != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('→',
                            style: TextStyle(color: Colors.grey[600])),
                      ),
                    if (store.closeTime != null) ...[
                      Icon(Icons.nights_stay_outlined,
                          color: Colors.grey[600], size: 14),
                      const SizedBox(width: 4),
                      Text(
                        store.closeTime!,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

        // Delivery info
        _buildInfoCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.t('delivery_fee'),
                        style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                    Text(
                      '${store.deliveryFee.toStringAsFixed(0)} MRU',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 36, color: Colors.white.withOpacity(0.08)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.t('min_order'),
                        style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                    Text(
                      '${store.minOrder.toStringAsFixed(0)} MRU',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInfoCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFF59E0B), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(color: Colors.grey[400], fontSize: 11)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniStat(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16)),
                Text(label,
                    style: TextStyle(color: Colors.grey[500], fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        type,
        style: const TextStyle(
            color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: Center(
        child: Icon(Icons.storefront_outlined,
            color: Colors.grey[700], size: 48),
      ),
    );
  }

  Widget _logoPlaceholder(Store store) {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: Center(
        child: Text(
          store.name.isNotEmpty ? store.name[0].toUpperCase() : 'S',
          style: const TextStyle(
              color: Color(0xFFF59E0B),
              fontSize: 28,
              fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
