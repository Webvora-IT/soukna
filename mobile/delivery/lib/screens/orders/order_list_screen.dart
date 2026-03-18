import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<dynamic> _myDeliveries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final res = await DeliveryApiService.getMyDeliveries();
      setState(() {
        _myDeliveries = res['data'] as List;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  final _statusColors = {
    'READY': Colors.teal,
    'DELIVERING': Colors.orange,
    'DELIVERED': Colors.green,
    'CANCELLED': Colors.red,
  };

  final _statusLabels = {
    'PENDING': 'En attente',
    'CONFIRMED': 'Confirmée',
    'PREPARING': 'Préparation',
    'READY': 'Prête à livrer',
    'DELIVERING': 'En cours',
    'DELIVERED': 'Livrée',
    'CANCELLED': 'Annulée',
  };

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final readyOrders = _myDeliveries.where((o) => o['status'] == 'READY').toList();
    final activeOrders = _myDeliveries.where((o) => ['DELIVERING'].contains(o['status'])).toList();
    final doneOrders = _myDeliveries.where((o) => ['DELIVERED', 'CANCELLED'].contains(o['status'])).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.delivery_dining, color: Color(0xFFF59E0B)),
            const SizedBox(width: 8),
            Text('Livreur: ${auth.user?.name ?? ''}'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: const Color(0xFFF59E0B),
          unselectedLabelColor: Colors.white70,
          indicatorColor: const Color(0xFFF59E0B),
          tabs: [
            Tab(text: 'À livrer (${readyOrders.length + activeOrders.length})'),
            Tab(text: 'Historique (${doneOrders.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabCtrl,
              children: [
                RefreshIndicator(
                  onRefresh: _loadData,
                  child: _buildOrderList([...readyOrders, ...activeOrders]),
                ),
                _buildOrderList(doneOrders),
              ],
            ),
    );
  }

  Widget _buildOrderList(List<dynamic> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Color(0xFF9CA3AF)),
            SizedBox(height: 16),
            Text('Aucune commande', style: TextStyle(color: Color(0xFF6B7280), fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (ctx, i) {
        final order = orders[i];
        final status = order['status'] as String;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.pushNamed(ctx, '/order-detail', arguments: order['id']),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: (_statusColors[status] ?? Colors.grey).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.delivery_dining, color: _statusColors[status] ?? Colors.grey, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order['store']?['name'] ?? 'Boutique', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(order['customer']?['name'] ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                        if (order['address'] != null)
                          Text('${order['address']['district']}, ${order['address']['city']}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${order['total']} MRU',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (_statusColors[status] ?? Colors.grey).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _statusLabels[status] ?? status,
                          style: TextStyle(fontSize: 11, color: _statusColors[status] ?? Colors.grey, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
