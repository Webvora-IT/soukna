import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../models/store.dart';
import '../../models/order.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _dashboardData;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getDashboard();
      if (data['success'] == true) {
        setState(() {
          _dashboardData = data['data'];
          _loading = false;
        });
      } else {
        setState(() {
          _error = data['message'] ?? 'Erreur';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur réseau';
        _loading = false;
      });
    }
  }

  String _timeAgo(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
      return 'Il y a ${diff.inDays}j';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFF59E0B),
          backgroundColor: const Color(0xFF1A1A2E),
          onRefresh: _loadDashboard,
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFF59E0B)))
              : _error != null
                  ? _buildError(l10n)
                  : _buildContent(l10n),
        ),
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey[600]),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDashboard,
            child: Text(l10n.t('retry')),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    final data = _dashboardData!;
    final store = data['store'] != null ? Store.fromJson(data['store']) : null;
    final stats = data['stats'] as Map<String, dynamic>? ?? {};
    final recentOrders = (data['recentOrders'] as List? ?? [])
        .map((o) => VendorOrder.fromJson(o))
        .toList();

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n.t('hello')},',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 14),
                          ),
                          Text(
                            store?.name ?? 'Votre boutique',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (store != null)
                      StatusBadge(status: store.status, fontSize: 11),
                  ],
                ),

                // PENDING warning banner
                if (store?.status == 'PENDING') ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFF59E0B).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.hourglass_empty,
                            color: Color(0xFFF59E0B), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.t('store_pending'),
                            style: const TextStyle(
                              color: Color(0xFFF59E0B),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Stat cards 2x2 grid
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
            ),
            delegate: SliverChildListDelegate([
              StatCard(
                label: l10n.t('total_products'),
                value: '${stats['totalProducts'] ?? 0}',
                icon: Icons.inventory_2_outlined,
                color: const Color(0xFFF59E0B),
              ),
              StatCard(
                label: l10n.t('pending_products'),
                value: '${stats['pendingProducts'] ?? 0}',
                icon: Icons.pending_outlined,
                color: const Color(0xFFEAB308),
              ),
              StatCard(
                label: l10n.t('total_orders'),
                value: '${stats['monthlyOrders'] ?? 0}',
                icon: Icons.shopping_bag_outlined,
                color: const Color(0xFF3B82F6),
                subtitle: 'ce mois',
              ),
              StatCard(
                label: l10n.t('revenue'),
                value: '${(stats['monthlyRevenue'] ?? 0).toStringAsFixed(0)}',
                icon: Icons.payments_outlined,
                color: const Color(0xFF10B981),
                subtitle: 'MRU',
              ),
            ]),
          ),
        ),

        // Recent orders section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Text(
                  l10n.t('recent_orders'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (recentOrders.isNotEmpty)
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      l10n.t('see_all'),
                      style: const TextStyle(
                        color: Color(0xFFF59E0B),
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        if (recentOrders.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  l10n.t('no_orders'),
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _buildOrderCard(recentOrders[i]),
              childCount: recentOrders.length,
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildOrderCard(VendorOrder order) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F1A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt_long_outlined,
                color: Color(0xFFF59E0B), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.customerName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  '${order.items.length} article(s) • ${order.total.toStringAsFixed(0)} MRU',
                  style: TextStyle(color: Colors.grey[400], fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(status: order.status, fontSize: 10),
              const SizedBox(height: 4),
              Text(
                _timeAgo(order.createdAt),
                style: TextStyle(color: Colors.grey[600], fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
