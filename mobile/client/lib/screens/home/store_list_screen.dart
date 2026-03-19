import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/store_provider.dart';

class StoreListScreen extends StatefulWidget {
  final String? storeType;
  final String? title;

  const StoreListScreen({super.key, this.storeType, this.title});

  @override
  State<StoreListScreen> createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StoreProvider>();
      provider.setType(widget.storeType);
      if (!provider.loaded) provider.loadData();
    });
  }

  @override
  void dispose() {
    // Reset type filter on exit so home screen isn't affected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) return;
      // reset happens in provider when home screen reinits
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();
    final filtered = storeProvider.filteredStores;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title ?? 'Boutiques',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => storeProvider.refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
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
          Expanded(
            child: storeProvider.loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B)))
                : storeProvider.error != null
                    ? Center(
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
                      )
                    : filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.storefront_outlined, size: 64, color: Colors.grey.shade300),
                                const SizedBox(height: 12),
                                Text(
                                  storeProvider.search.isNotEmpty
                                      ? 'Aucun résultat pour "${storeProvider.search}"'
                                      : 'Aucune boutique disponible',
                                  style: GoogleFonts.cairo(color: Colors.grey.shade500, fontSize: 15),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: storeProvider.refresh,
                            color: const Color(0xFFF59E0B),
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              itemCount: filtered.length,
                              itemBuilder: (ctx, i) {
                                final store = filtered[i];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () => Navigator.pushNamed(ctx, '/store', arguments: store.id),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Row(
                                        children: [
                                          // Logo
                                          Container(
                                            width: 52, height: 52,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF59E0B).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: store.logo != null
                                                ? ClipRRect(
                                                    borderRadius: BorderRadius.circular(12),
                                                    child: Image.network(store.logo!, fit: BoxFit.cover),
                                                  )
                                                : const Icon(Icons.store, color: Color(0xFFF59E0B), size: 28),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  store.name,
                                                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
                                                ),
                                                if (store.nameAr != null)
                                                  Text(
                                                    store.nameAr!,
                                                    style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF9CA3AF)),
                                                  ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.star, color: Color(0xFFF59E0B), size: 13),
                                                    Text(
                                                      ' ${store.rating} (${store.reviewCount})',
                                                      style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF6B7280)),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF9CA3AF)),
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
                                                  color: (store.isOpen ? const Color(0xFF10B981) : Colors.grey).withOpacity(0.1),
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
                                                style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFFF59E0B), fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
