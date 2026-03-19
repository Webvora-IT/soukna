import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../services/api_service.dart';
import '../../models/order.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Order? _order;
  bool _loading = true;
  bool _refreshing = false;

  final _steps = ['PENDING', 'CONFIRMED', 'PREPARING', 'READY', 'DELIVERING', 'DELIVERED'];
  final _stepLabels = ['Reçue', 'Confirmée', 'Préparation', 'Prête', 'En livraison', 'Livrée'];
  final _stepIcons = [
    Icons.receipt_long_outlined,
    Icons.check_circle_outline,
    Icons.restaurant_outlined,
    Icons.check_circle,
    Icons.delivery_dining,
    Icons.home_outlined,
  ];
  final _stepColors = [
    Color(0xFFF59E0B),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFFF97316),
    Color(0xFF10B981),
  ];

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder({bool showRefreshing = false}) async {
    if (showRefreshing) setState(() => _refreshing = true);
    try {
      final res = await ApiService.getOrder(widget.orderId);
      final order = Order.fromJson(res['data']);
      setState(() {
        _order = order;
        _loading = false;
        _refreshing = false;
      });
      // Sync with OrderProvider cache
      context.read<OrderProvider>().syncOrder(order.toJson());
    } catch (e) {
      setState(() { _loading = false; _refreshing = false; });
    }
  }

  Color _getStatusColor(String status) {
    final idx = _steps.indexOf(status);
    if (idx >= 0 && idx < _stepColors.length) return _stepColors[idx];
    if (status == 'CANCELLED') return const Color(0xFFEF4444);
    return Colors.grey;
  }

  String _getStatusLabel(String status) {
    final idx = _steps.indexOf(status);
    if (idx >= 0 && idx < _stepLabels.length) return _stepLabels[idx];
    if (status == 'CANCELLED') return 'Annulée';
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      appBar: AppBar(
        title: Text('Suivi de commande', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        actions: [
          _refreshing
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _loadOrder(showRefreshing: true),
                ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B)))
          : _order == null
              ? Center(child: Text('Commande introuvable', style: GoogleFonts.cairo()))
              : RefreshIndicator(
                  onRefresh: () => _loadOrder(showRefreshing: true),
                  color: const Color(0xFFF59E0B),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [

                        // Order header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _order!.storeName ?? 'Commande',
                                        style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '#${_order!.id.substring(_order!.id.length - 8).toUpperCase()}',
                                        style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF9CA3AF)),
                                      ),
                                    ],
                                  ),
                                  if (_order!.status != 'CANCELLED')
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(_order!.status).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _getStatusLabel(_order!.status),
                                        style: GoogleFonts.cairo(
                                          color: _getStatusColor(_order!.status),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Annulée',
                                        style: GoogleFonts.cairo(color: const Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                ],
                              ),

                              if (_order!.estimatedTime != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B).withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time, color: Color(0xFFF59E0B), size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Temps estimé : ${_order!.estimatedTime} min',
                                        style: GoogleFonts.cairo(color: const Color(0xFFF59E0B), fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // Stepper
                              if (_order!.status != 'CANCELLED') ...[
                                const SizedBox(height: 24),
                                ..._buildSteps(),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Order items
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                                child: Text('Articles commandés', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15)),
                              ),
                              const Divider(height: 20, indent: 16, endIndent: 16),
                              ..._order!.items.map((item) => Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32, height: 32,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${item.quantity}',
                                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B), fontSize: 13),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(item.productName, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w500)),
                                    ),
                                    Text(
                                      '${(item.price * item.quantity).toStringAsFixed(0)} MRU',
                                      style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF374151)),
                                    ),
                                  ],
                                ),
                              )),
                              const Divider(height: 1, indent: 16, endIndent: 16),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15)),
                                    Text(
                                      '${_order!.total.toStringAsFixed(0)} MRU',
                                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFFF59E0B)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Back to orders button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
                            icon: const Icon(Icons.home_outlined, color: Color(0xFFF59E0B)),
                            label: Text('Retour à l\'accueil', style: GoogleFonts.cairo(color: const Color(0xFFF59E0B))),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFF59E0B)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  List<Widget> _buildSteps() {
    final currentIdx = _steps.indexOf(_order!.status);
    return List.generate(_steps.length, (i) {
      final isDone = i < currentIdx;
      final isCurrent = i == currentIdx;
      final isPending = i > currentIdx;
      final color = isDone || isCurrent ? _stepColors[i] : const Color(0xFFE5E7EB);

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? _stepColors[i] : isCurrent ? _stepColors[i].withOpacity(0.15) : const Color(0xFFF3F4F6),
                  border: isCurrent ? Border.all(color: _stepColors[i], width: 2) : null,
                ),
                child: Icon(
                  _stepIcons[i],
                  color: isDone ? Colors.white : isCurrent ? _stepColors[i] : const Color(0xFFD1D5DB),
                  size: 20,
                ),
              ),
              if (i < _steps.length - 1)
                Container(
                  width: 2, height: 28,
                  color: isDone ? _stepColors[i] : const Color(0xFFE5E7EB),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 28, top: 8),
              child: Text(
                _stepLabels[i],
                style: GoogleFonts.cairo(
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isPending ? const Color(0xFFD1D5DB) : const Color(0xFF1F2937),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
