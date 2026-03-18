import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    try {
      final res = await ApiService.getOrder(widget.orderId);
      setState(() {
        _order = Order.fromJson(res['data']);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi de commande'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadOrder),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? const Center(child: Text('Commande introuvable'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Status stepper
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                _order!.storeName ?? 'Commande',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ID: ${_order!.id.substring(0, 12)}...',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                              ),
                              const SizedBox(height: 24),
                              ..._buildSteps(),
                            ],
                          ),
                        ),
                      ),

                      if (_order!.estimatedTime != null)
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 12),
                              Text(
                                'Temps estimé: ${_order!.estimatedTime} min',
                                style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Détails', style: TextStyle(fontWeight: FontWeight.bold)),
                              const Divider(),
                              ..._order!.items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${item.productName} ×${item.quantity}'),
                                    Text('${(item.price * item.quantity).toStringAsFixed(0)} MRU'),
                                  ],
                                ),
                              )),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(
                                    '${_order!.total.toStringAsFixed(0)} MRU',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

      return Row(
        children: [
          Column(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? const Color(0xFF10B981) : isCurrent ? const Color(0xFFF59E0B) : const Color(0xFFF3F4F6),
                ),
                child: Icon(
                  _stepIcons[i],
                  color: isDone || isCurrent ? Colors.white : const Color(0xFFD1D5DB),
                  size: 20,
                ),
              ),
              if (i < _steps.length - 1)
                Container(
                  width: 2, height: 24,
                  color: isDone ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                _stepLabels[i],
                style: TextStyle(
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isPending ? const Color(0xFFD1D5DB) : const Color(0xFF1F2937),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
