import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
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
    if (confirm != true) return;

    context.read<DeliveryOrderProvider>().clear();
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderProvider = context.watch<DeliveryOrderProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('Mon Profil', style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Avatar
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF59E0B), width: 2),
              ),
              child: Center(
                child: Text(
                  auth.user?.name.substring(0, 1).toUpperCase() ?? '?',
                  style: GoogleFonts.cairo(fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(auth.user?.name ?? '', style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(auth.user?.email ?? '', style: GoogleFonts.cairo(color: const Color(0xFF6B7280))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Livreur SOUKNA', style: GoogleFonts.cairo(color: const Color(0xFFF59E0B), fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 24),

            // Stats
            Row(
              children: [
                _StatCard(
                  icon: Icons.local_shipping_outlined,
                  label: 'En cours',
                  value: '${orderProvider.activeCount}',
                  color: const Color(0xFFF97316),
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.check_circle_outline,
                  label: 'Disponibles',
                  value: '${orderProvider.availableCount}',
                  color: const Color(0xFF10B981),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Go to orders
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushReplacementNamed(context, '/orders'),
                icon: const Icon(Icons.delivery_dining, color: Color(0xFFF59E0B)),
                label: Text('Voir les commandes', style: GoogleFonts.cairo(color: const Color(0xFFF59E0B), fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFF59E0B)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: Text('Déconnexion', style: GoogleFonts.cairo(color: Colors.red, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: GoogleFonts.cairo(fontSize: 12, color: color.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}
