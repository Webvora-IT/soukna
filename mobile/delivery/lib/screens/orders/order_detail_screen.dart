import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<String, dynamic>? _order;
  bool _loading = true;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await DeliveryApiService.getOrder(widget.orderId);
      setState(() { _order = res['data']; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _updating = true);
    try {
      await DeliveryApiService.updateOrderStatus(widget.orderId, status);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Statut mis à jour'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Commande #${widget.orderId.substring(0, 8)}'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? const Center(child: Text('Commande introuvable'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status
                      Card(
                        color: const Color(0xFF1F2937),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Statut', style: TextStyle(color: Colors.white70)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _order!['status'],
                                  style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Customer & address
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Client', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 8),
                              _infoRow(Icons.person_outline, _order!['customer']?['name'] ?? '-'),
                              if (_order!['customer']?['phone'] != null)
                                _infoRow(Icons.phone_outlined, _order!['customer']['phone']),
                              if (_order!['address'] != null) ...[
                                const Divider(height: 16),
                                const Text('Adresse de livraison', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                const SizedBox(height: 8),
                                _infoRow(Icons.location_on_outlined,
                                  '${_order!['address']['street']}, ${_order!['address']['district']}'),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Store
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Boutique', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 8),
                              _infoRow(Icons.store_outlined, _order!['store']?['name'] ?? '-'),
                              if (_order!['store']?['phone'] != null)
                                _infoRow(Icons.phone_outlined, _order!['store']['phone']),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Items
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Articles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const Divider(),
                              ...(_order!['items'] as List? ?? []).map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text('${item['product']?['name'] ?? item['productId']} ×${item['quantity']}')),
                                    Text('${item['price'] * item['quantity']} MRU', style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              )),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('${_order!['total']} MRU', style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Action buttons
                      if (_order!['status'] == 'READY')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.delivery_dining),
                            label: const Text('Prendre en charge la livraison'),
                            onPressed: _updating ? null : () => _updateStatus('DELIVERING'),
                          ),
                        ),
                      if (_order!['status'] == 'DELIVERING')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Marquer comme livré'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            onPressed: _updating ? null : () => _updateStatus('DELIVERED'),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF374151)))),
        ],
      ),
    );
  }
}
