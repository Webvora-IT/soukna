import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;
  List<dynamic> _orders = [];
  String? _error;

  final List<Map<String, dynamic>> _tabs = [
    {'label': 'Toutes', 'status': null},
    {'label': 'En cours', 'status': 'PENDING'},
    {'label': 'Livrées', 'status': 'DELIVERED'},
    {'label': 'Annulées', 'status': 'CANCELLED'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) _fetchOrders();
    });
    _fetchOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    setState(() { _loading = true; _error = null; });
    try {
      final status = _tabs[_tabController.index]['status'] as String?;
      final path = status != null ? '/orders?status=$status' : '/orders';
      final res = await ApiService.get(path);
      setState(() {
        _orders = res['data'] as List<dynamic>? ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING': return const Color(0xFFF59E0B);
      case 'CONFIRMED': return const Color(0xFF3B82F6);
      case 'PREPARING': return const Color(0xFF8B5CF6);
      case 'READY': return const Color(0xFF06B6D4);
      case 'DELIVERING': return const Color(0xFFF97316);
      case 'DELIVERED': return const Color(0xFF10B981);
      case 'CANCELLED': return const Color(0xFFEF4444);
      default: return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'PENDING': return 'En attente';
      case 'CONFIRMED': return 'Confirmée';
      case 'PREPARING': return 'En préparation';
      case 'READY': return 'Prête';
      case 'DELIVERING': return 'En livraison';
      case 'DELIVERED': return 'Livrée';
      case 'CANCELLED': return 'Annulée';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      appBar: AppBar(
        title: Text('Mes commandes', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.cairo(fontSize: 13),
          labelColor: const Color(0xFFF59E0B),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFF59E0B),
          isScrollable: true,
          tabs: _tabs.map((t) => Tab(text: t['label'] as String)).toList(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B)))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text('Erreur de chargement', style: GoogleFonts.cairo(color: Colors.red)),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: _fetchOrders, child: Text('Réessayer', style: GoogleFonts.cairo())),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchOrders,
                  color: const Color(0xFFF59E0B),
                  child: _orders.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                            Column(
                              children: [
                                const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text('Aucune commande', style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey)),
                                const SizedBox(height: 8),
                                Text('Vos commandes apparaîtront ici', style: GoogleFonts.cairo(color: Colors.grey)),
                              ],
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _orders.length,
                          itemBuilder: (context, index) {
                            final order = _orders[index] as Map<String, dynamic>;
                            final items = order['items'] as List<dynamic>? ?? [];
                            final statusColor = _statusColor(order['status'] as String? ?? '');
                            final createdAt = order['createdAt'] != null
                                ? DateFormat('dd MMM yyyy', 'fr').format(DateTime.parse(order['createdAt'] as String))
                                : '';

                            return GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/order-tracking',
                                arguments: order['id'],
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '#${(order['id'] as String).substring((order['id'] as String).length - 8).toUpperCase()}',
                                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: statusColor.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              _statusLabel(order['status'] as String? ?? ''),
                                              style: GoogleFonts.cairo(
                                                color: statusColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        order['store']?['name'] as String? ?? '',
                                        style: GoogleFonts.cairo(color: Colors.grey[600], fontSize: 13),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${items.length} article${items.length > 1 ? 's' : ''}  •  $createdAt',
                                        style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${(order['total'] as num?)?.toStringAsFixed(0) ?? '0'} MRU',
                                            style: GoogleFonts.cairo(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: const Color(0xFFF59E0B),
                                            ),
                                          ),
                                          if (order['status'] == 'PENDING' || order['status'] == 'DELIVERING')
                                            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
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
    );
  }
}
