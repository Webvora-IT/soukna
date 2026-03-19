import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryOrderProvider>().load();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  final _statusColors = {
    'READY': const Color(0xFF06B6D4),
    'DELIVERING': const Color(0xFFF97316),
    'DELIVERED': const Color(0xFF10B981),
    'CANCELLED': const Color(0xFFEF4444),
  };

  final _statusLabels = {
    'READY': 'Prête à livrer',
    'DELIVERING': 'En cours',
    'DELIVERED': 'Livrée',
    'CANCELLED': 'Annulée',
  };

  Future<void> _acceptOrder(BuildContext context, Map<String, dynamic> order) async {
    final provider = context.read<DeliveryOrderProvider>();
    final ok = await provider.acceptDelivery(order['id'] as String);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Commande acceptée !' : 'Erreur, réessayez', style: GoogleFonts.cairo()),
        backgroundColor: ok ? const Color(0xFF10B981) : const Color(0xFFEF4444),
      ),
    );
    if (ok) {
      _tabCtrl.animateTo(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderProvider = context.watch<DeliveryOrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.delivery_dining, color: Color(0xFFF59E0B)),
            const SizedBox(width: 8),
            Flexible(child: Text('Livreur: ${auth.user?.name ?? ''}', overflow: TextOverflow.ellipsis)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DeliveryOrderProvider>().load(),
          ),
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
            Tab(text: 'Disponibles (${orderProvider.availableCount})'),
            Tab(text: 'Mes livraisons (${orderProvider.activeCount})'),
          ],
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
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => context.read<DeliveryOrderProvider>().load(),
                        icon: const Icon(Icons.refresh),
                        label: Text('Réessayer', style: GoogleFonts.cairo()),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabCtrl,
                  children: [
                    RefreshIndicator(
                      onRefresh: () => context.read<DeliveryOrderProvider>().load(),
                      color: const Color(0xFFF59E0B),
                      child: _buildAvailableList(orderProvider.availableOrders),
                    ),
                    RefreshIndicator(
                      onRefresh: () => context.read<DeliveryOrderProvider>().load(),
                      color: const Color(0xFFF59E0B),
                      child: _buildMyDeliveriesList(orderProvider.myDeliveries),
                    ),
                  ],
                ),
    );
  }

  Widget _buildAvailableList(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Aucune commande disponible', style: GoogleFonts.cairo(color: const Color(0xFF6B7280), fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (ctx, i) {
        final order = orders[i];
        return _OrderCard(
          order: order,
          statusColors: _statusColors,
          statusLabels: _statusLabels,
          action: ElevatedButton(
            onPressed: () => _acceptOrder(context, order),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Accepter', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
          onTap: () => Navigator.pushNamed(ctx, '/order-detail', arguments: order['id']),
        );
      },
    );
  }

  Widget _buildMyDeliveriesList(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Aucune livraison en cours', style: GoogleFonts.cairo(color: const Color(0xFF6B7280), fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (ctx, i) {
        final order = orders[i];
        final status = order['status'] as String? ?? '';
        return _OrderCard(
          order: order,
          statusColors: _statusColors,
          statusLabels: _statusLabels,
          action: status == 'DELIVERING'
              ? ElevatedButton(
                  onPressed: () async {
                    final ok = await context.read<DeliveryOrderProvider>().markDelivered(order['id'] as String);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok ? 'Livrée avec succès !' : 'Erreur, réessayez', style: GoogleFonts.cairo()),
                        backgroundColor: ok ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Livrée', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                )
              : null,
          onTap: () => Navigator.pushNamed(ctx, '/order-detail', arguments: order['id']),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final Map<String, Color> statusColors;
  final Map<String, String> statusLabels;
  final Widget? action;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.statusColors,
    required this.statusLabels,
    this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = order['status'] as String? ?? '';
    final color = statusColors[status] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.delivery_dining, color: color, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['store']?['name'] as String? ?? 'Boutique',
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          order['customer']?['name'] as String? ?? '',
                          style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(order['total'] as num?)?.toStringAsFixed(0) ?? 0} MRU',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B), fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (order['address'] != null) ...[
                    const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${order['address']['district'] ?? ''}, ${order['address']['city'] ?? ''}',
                        style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF9CA3AF)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else
                    const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusLabels[status] ?? status,
                      style: GoogleFonts.cairo(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              if (action != null) ...[
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [action!],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
