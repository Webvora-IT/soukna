import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/store_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
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

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Déconnexion', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text('Voulez-vous vraiment vous déconnecter ?', style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Annuler', style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Déconnexion', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    // Clear all providers
    context.read<OrderProvider>().clear();
    context.read<NotificationProvider>().clearOnLogout();
    context.read<AddressProvider>().clearOnLogout();
    context.read<CartProvider>().clear();
    context.read<StoreProvider>().clear();

    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final notifProvider = context.watch<NotificationProvider>();

    final recentOrders = orderProvider.orders.take(3).toList();
    final activeOrders = orderProvider.activeOrderCount;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      appBar: AppBar(
        title: Text('Mon Profil', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
              ),
              if (notifProvider.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        '${notifProvider.unreadCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<OrderProvider>().loadOrders(force: true);
          await context.read<NotificationProvider>().load();
        },
        color: const Color(0xFFF59E0B),
        child: ListView(
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFFBF0), Color(0xFFFFF8E7)],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF59E0B), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        auth.user?.name.substring(0, 1).toUpperCase() ?? '?',
                        style: GoogleFonts.cairo(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    auth.user?.name ?? '',
                    style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    auth.user?.email ?? '',
                    style: GoogleFonts.cairo(color: const Color(0xFF6B7280), fontSize: 14),
                  ),
                  if (auth.user?.phone != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      auth.user!.phone!,
                      style: GoogleFonts.cairo(color: const Color(0xFF9CA3AF), fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),

            // Stats row
            if (activeOrders > 0)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 12),
                    Text(
                      '$activeOrders commande${activeOrders > 1 ? 's' : ''} en cours',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/orders'),
                      child: Text('Voir', style: GoogleFonts.cairo(color: const Color(0xFFF59E0B))),
                    ),
                  ],
                ),
              ),

            // Menu items
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
              ),
              child: Column(
                children: [
                  _MenuItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'Mes commandes',
                    trailing: activeOrders > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('$activeOrders', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          )
                        : null,
                    onTap: () => Navigator.pushNamed(context, '/orders'),
                  ),
                  const Divider(height: 1, indent: 16),
                  _MenuItem(
                    icon: Icons.location_on_outlined,
                    label: 'Mes adresses',
                    onTap: () => Navigator.pushNamed(context, '/addresses'),
                  ),
                  const Divider(height: 1, indent: 16),
                  _MenuItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    trailing: notifProvider.unreadCount > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${notifProvider.unreadCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          )
                        : null,
                    onTap: () => Navigator.pushNamed(context, '/notifications'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Recent orders
            if (recentOrders.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Commandes récentes', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/orders'),
                      child: Text('Voir tout', style: GoogleFonts.cairo(color: const Color(0xFFF59E0B))),
                    ),
                  ],
                ),
              ),
              ...recentOrders.map((order) {
                final statusColor = _statusColor(order['status'] as String? ?? '');
                return Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.receipt_long_outlined, color: statusColor, size: 20),
                    ),
                    title: Text(
                      order['store']?['name'] as String? ?? 'Commande',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: Text(
                      _statusLabel(order['status'] as String? ?? ''),
                      style: GoogleFonts.cairo(color: statusColor, fontSize: 12),
                    ),
                    trailing: Text(
                      '${(order['total'] as num?)?.toStringAsFixed(0) ?? 0} MRU',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B)),
                    ),
                    onTap: () => Navigator.pushNamed(context, '/order-tracking', arguments: order['id']),
                  ),
                );
              }),
            ],

            const SizedBox(height: 16),

            // Logout
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: Text('Déconnexion', style: GoogleFonts.cairo(color: Colors.red, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFFF59E0B), size: 20),
      ),
      title: Text(label, style: GoogleFonts.cairo(fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
