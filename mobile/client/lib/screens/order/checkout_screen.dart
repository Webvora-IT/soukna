import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/address_provider.dart';
import '../../models/address.dart';
import '../profile/addresses_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _notesCtrl = TextEditingController();
  Address? _selectedAddress;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final addressProvider = context.read<AddressProvider>();
      await addressProvider.load();
      if (!mounted) return;
      setState(() {
        _selectedAddress = addressProvider.defaultAddress ??
            (addressProvider.addresses.isNotEmpty ? addressProvider.addresses.first : null);
      });
    });
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectAddress() async {
    final result = await Navigator.push<Address>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddressesScreen(selectMode: true),
      ),
    );
    if (result != null) {
      setState(() => _selectedAddress = result);
    }
  }

  Future<void> _placeOrder() async {
    final cart = context.read<CartProvider>();
    if (cart.isEmpty) return;

    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner une adresse de livraison', style: GoogleFonts.cairo()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final orderProvider = context.read<OrderProvider>();
      final order = await orderProvider.placeOrder({
        'storeId': cart.storeId,
        'addressId': _selectedAddress!.id,
        'items': cart.toOrderItems(),
        if (_notesCtrl.text.isNotEmpty) 'notes': _notesCtrl.text,
      });

      if (!mounted) return;
      if (order == null) throw Exception('Échec de la commande');
      final orderId = order['id'] as String;
      cart.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Commande passée avec succès !', style: GoogleFonts.cairo()),
          backgroundColor: const Color(0xFF10B981),
        ),
      );

      Navigator.pushReplacementNamed(context, '/order-tracking', arguments: orderId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}', style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final addressProvider = context.watch<AddressProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      appBar: AppBar(
        title: Text('Finaliser la commande', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Delivery address section
            Text('Adresse de livraison', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            addressProvider.loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B)))
                : _selectedAddress != null
                    ? _AddressTile(
                        address: _selectedAddress!,
                        onTap: _selectAddress,
                      )
                    : _AddAddressButton(onTap: _selectAddress),

            const SizedBox(height: 20),

            // Order summary
            Text('Résumé de commande', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ...cart.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${item.quantity}',
                                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(item.product.name, style: GoogleFonts.cairo(fontWeight: FontWeight.w500)),
                          ),
                          Text(
                            '${item.total.toStringAsFixed(0)} MRU',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.w600, color: const Color(0xFF374151)),
                          ),
                        ],
                      ),
                    )),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sous-total', style: GoogleFonts.cairo(color: const Color(0xFF6B7280))),
                        Text('${cart.subtotal.toStringAsFixed(0)} MRU', style: GoogleFonts.cairo()),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          '${cart.subtotal.toStringAsFixed(0)} MRU',
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFFF59E0B)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Notes
            Text('Notes (optionnel)', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Instructions spéciales, allergies...',
                hintStyle: GoogleFonts.cairo(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: GoogleFonts.cairo(),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        'Confirmer — ${cart.subtotal.toStringAsFixed(0)} MRU',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
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

class _AddressTile extends StatelessWidget {
  final Address address;
  final VoidCallback onTap;

  const _AddressTile({required this.address, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.location_on_outlined, color: Color(0xFFF59E0B), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(address.label, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(
                    '${address.street}, ${address.district}',
                    style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            Text('Modifier', style: GoogleFonts.cairo(color: const Color(0xFFF59E0B), fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _AddAddressButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddAddressButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            Icon(Icons.add_location_outlined, size: 32, color: Colors.grey.shade400),
            const SizedBox(height: 6),
            Text('Ajouter une adresse de livraison', style: GoogleFonts.cairo(color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}
