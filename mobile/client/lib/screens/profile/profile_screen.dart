import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/order.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Order> _orders = [];
  bool _loadingOrders = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final res = await ApiService.getOrders();
      setState(() {
        _orders = (res['data'] as List).map((o) => Order.fromJson(o)).toList();
        _loadingOrders = false;
      });
    } catch (_) {
      setState(() => _loadingOrders = false);
    }
  }

  final _statusColors = {
    'PENDING': Colors.orange,
    'CONFIRMED': Colors.blue,
    'PREPARING': Colors.purple,
    'READY': Colors.teal,
    'DELIVERING': Colors.orange,
    'DELIVERED': Colors.green,
    'CANCELLED': Colors.red,
  };

  final _statusLabels = {
    'PENDING': 'En attente',
    'CONFIRMED': 'Confirmée',
    'PREPARING': 'Préparation',
    'READY': 'Prête',
    'DELIVERING': 'En livraison',
    'DELIVERED': 'Livrée',
    'CANCELLED': 'Annulée',
  };

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: const Color(0xFFF59E0B).withOpacity(0.2),
                    child: Text(
                      auth.user?.name.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(auth.user?.name ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(auth.user?.email ?? '', style: const TextStyle(color: Color(0xFF6B7280))),
                  if (auth.user?.phone != null)
                    Text(auth.user!.phone!, style: const TextStyle(color: Color(0xFF9CA3AF))),
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Modifier'),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Déconnexion'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
                      onPressed: () async {
                        await auth.logout();
                        if (!mounted) return;
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(height: 1),

            // Orders
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mes commandes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (_loadingOrders)
                    const Center(child: CircularProgressIndicator())
                  else if (_orders.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Aucune commande', style: TextStyle(color: Color(0xFF9CA3AF))),
                      ),
                    )
                  else
                    ..._orders.map((order) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: (_statusColors[order.status] ?? Colors.grey).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.receipt_long, color: _statusColors[order.status] ?? Colors.grey, size: 20),
                        ),
                        title: Text(order.storeName ?? 'Commande', style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          _statusLabels[order.status] ?? order.status,
                          style: TextStyle(color: _statusColors[order.status], fontSize: 12),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${order.total.toStringAsFixed(0)} MRU', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                          ],
                        ),
                        onTap: () => Navigator.pushNamed(context, '/order-tracking', arguments: order.id),
                      ),
                    )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
