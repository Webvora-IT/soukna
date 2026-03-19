import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _tabs = [
    {'label': 'Toutes', 'statuses': null},
    {'label': 'En cours', 'statuses': ['PENDING', 'CONFIRMED', 'PREPARING', 'READY', 'DELIVERING']},
    {'label': 'Livrées', 'statuses': ['DELIVERED']},
    {'label': 'Annulées', 'statuses': ['CANCELLED']},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  List<Map<String, dynamic>> _filterOrders(List<Map<String, dynamic>> orders, List<String>? statuses) {
    if (statuses == null) return orders;
    return orders.where((o) => statuses.contains(o['status'])).toList();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

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
      body: orderProvider.loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B)))
          : orderProvider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_outlined, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(orderProvider.error!, style: GoogleFonts.cairo(color: Colors.grey)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => context.read<OrderProvider>().loadOrders(force: true),
                        icon: const Icon(Icons.refresh),
                        label: Text('Réessayer', style: GoogleFonts.cairo()),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: _tabs.map((tab) {
                    final filtered = _filterOrders(
                      orderProvider.orders,
                      tab['statuses'] as List<String>?,
                    );
                    return RefreshIndicator(
                      onRefresh: () => context.read<OrderProvider>().loadOrders(force: true),
                      color: const Color(0xFFF59E0B),
                      child: filtered.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                                Column(
                                  children: [
                                    const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                                    const SizedBox(height: 16),
                                    Text('Aucune commande', style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final order = filtered[index];
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
                                                  style: GoogleFonts.cairo(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
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
                                                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFFF59E0B)),
                                              ),
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
                    );
                  }).toList(),
                ),
    );
  }
}
