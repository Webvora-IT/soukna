import 'package:flutter/material.dart';
import '../../models/store.dart';
import '../../services/api_service.dart';

class StoreListScreen extends StatefulWidget {
  final String? storeType;
  final String? title;

  const StoreListScreen({super.key, this.storeType, this.title});

  @override
  State<StoreListScreen> createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  List<Store> _stores = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getStores(type: widget.storeType);
      setState(() {
        _stores = (res['data'] as List).map((s) => Store.fromJson(s)).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _stores.where((s) =>
      _search.isEmpty || s.name.toLowerCase().contains(_search.toLowerCase())
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Boutiques'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(child: Text('Aucune boutique trouvée'))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) {
                            final store = filtered[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFFF59E0B).withOpacity(0.15),
                                  child: const Icon(Icons.store, color: Color(0xFFF59E0B)),
                                ),
                                title: Text(store.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${store.district ?? store.city} • ★ ${store.rating}'),
                                trailing: Text('${store.deliveryFee.toInt()} MRU', style: const TextStyle(color: Color(0xFFF59E0B))),
                                onTap: () => Navigator.pushNamed(ctx, '/store', arguments: store.id),
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
