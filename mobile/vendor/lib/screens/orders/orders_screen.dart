import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../models/order.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';

class OrdersScreen extends StatefulWidget {
  final void Function(int count)? onPendingCountChanged;

  const OrdersScreen({super.key, this.onPendingCountChanged});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<VendorOrder> _orders = [];
  bool _loading = true;
  String? _error;
  String _filterStatus = 'ALL';

  final List<Map<String, String>> _filters = [
    {'key': 'ALL', 'label': 'Toutes'},
    {'key': 'PENDING', 'label': 'Nouvelles'},
    {'key': 'PREPARING', 'label': 'En préparation'},
    {'key': 'READY', 'label': 'Prêtes'},
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final status = _filterStatus == 'ALL' ? null : _filterStatus;
      final data = await ApiService.getOrders(status: status);
      if (data['success'] == true) {
        final list = (data['data'] as List? ?? [])
            .map((o) => VendorOrder.fromJson(o))
            .toList();
        setState(() {
          _orders = list;
          _loading = false;
        });
        // Count pending orders
        final pendingCount =
            list.where((o) => o.status == 'PENDING').length;
        widget.onPendingCountChanged?.call(pendingCount);
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

  Future<void> _updateStatus(String orderId, String status) async {
    try {
      final result = await ApiService.updateOrderStatus(orderId, status);
      if (result['success'] == true) {
        _loadOrders();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Erreur'),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur réseau'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  String _timeAgo(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'À l\'instant';
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
      appBar: AppBar(
        title: Text(l10n.t('orders')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filters[i];
                final isSelected = _filterStatus == f['key'];
                return GestureDetector(
                  onTap: () {
                    setState(() => _filterStatus = f['key']!);
                    _loadOrders();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      f['label']!,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.grey[400],
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFF59E0B)))
                : _error != null
                    ? _buildError(l10n)
                    : _orders.isEmpty
                        ? EmptyState(
                            icon: Icons.shopping_bag_outlined,
                            title: l10n.t('no_orders'),
                            subtitle: 'Les commandes apparaîtront ici',
                          )
                        : RefreshIndicator(
                            color: const Color(0xFFF59E0B),
                            backgroundColor: const Color(0xFF1A1A2E),
                            onRefresh: _loadOrders,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _orders.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, i) =>
                                  _buildOrderCard(_orders[i]),
                            ),
                          ),
          ),
        ],
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
              onPressed: _loadOrders, child: Text(l10n.t('retry'))),
        ],
      ),
    );
  }

  Widget _buildOrderCard(VendorOrder order) {
    final isNew = order.status == 'PENDING';
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: isNew
            ? Border.all(
                color: const Color(0xFFF59E0B).withOpacity(0.4), width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                if (isNew)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                    margin: const EdgeInsets.only(right: 8),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.id.length > 8 ? order.id.substring(order.id.length - 8) : order.id}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _timeAgo(order.createdAt),
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
                const Spacer(),
                StatusBadge(status: order.status),
              ],
            ),
          ),

          // Customer info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Icon(Icons.person_outline,
                    color: Colors.grey, size: 14),
                const SizedBox(width: 6),
                Text(
                  order.customerName,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                if (order.customerPhone != null) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.phone_outlined,
                      color: Colors.grey, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    order.customerPhone!,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Divider
          Divider(height: 1, color: Colors.white.withOpacity(0.06)),

          // Items list
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: order.items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F0F1A),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                    color: Color(0xFFF59E0B),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.productName,
                              style: TextStyle(
                                  color: Colors.grey[300], fontSize: 12),
                            ),
                          ),
                          Text(
                            '${(item.price * item.quantity).toStringAsFixed(0)} MRU',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          // Notes
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Row(
                children: [
                  const Icon(Icons.note_outlined,
                      color: Colors.grey, size: 13),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.notes!,
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 11,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Total
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(
              children: [
                Text(
                  '${order.items.length} article(s)',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
                const Spacer(),
                Text(
                  'Total: ',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
                Text(
                  '${order.total.toStringAsFixed(0)} MRU',
                  style: const TextStyle(
                    color: Color(0xFFF59E0B),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          if (_getActions(order.status).isNotEmpty) ...[
            Divider(height: 1, color: Colors.white.withOpacity(0.06)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: _buildActionButtons(order),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getActions(String status) {
    switch (status) {
      case 'PENDING':
        return [
          {'label': 'Confirmer', 'status': 'CONFIRMED', 'color': const Color(0xFF10B981), 'outlined': false},
          {'label': 'Annuler', 'status': 'CANCELLED', 'color': const Color(0xFFEF4444), 'outlined': true},
        ];
      case 'CONFIRMED':
        return [
          {'label': 'Démarrer préparation', 'status': 'PREPARING', 'color': const Color(0xFFF59E0B), 'outlined': false},
        ];
      case 'PREPARING':
        return [
          {'label': 'Marquer comme prêt', 'status': 'READY', 'color': const Color(0xFFF59E0B), 'outlined': false},
        ];
      default:
        return [];
    }
  }

  List<Widget> _buildActionButtons(VendorOrder order) {
    final actions = _getActions(order.status);
    return actions.map((action) {
      final isFirst = actions.first == action;
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(left: isFirst ? 0 : 8),
          child: action['outlined'] as bool
              ? OutlinedButton(
                  onPressed: () =>
                      _updateStatus(order.id, action['status'] as String),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: action['color'] as Color,
                    side: BorderSide(color: action['color'] as Color),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(action['label'] as String,
                      style: const TextStyle(fontSize: 12)),
                )
              : ElevatedButton(
                  onPressed: () =>
                      _updateStatus(order.id, action['status'] as String),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: action['color'] as Color,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(action['label'] as String,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                ),
        ),
      );
    }).toList();
  }
}
