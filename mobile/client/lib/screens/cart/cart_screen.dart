import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Panier'),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Vider le panier'),
                    content: const Text('Supprimer tous les articles?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                      ElevatedButton(
                        onPressed: () { cart.clear(); Navigator.pop(context); },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Vider'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Vider', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: cart.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Color(0xFFD1D5DB)),
                  SizedBox(height: 16),
                  Text('Votre panier est vide', style: TextStyle(fontSize: 18, color: Color(0xFF9CA3AF))),
                  SizedBox(height: 8),
                  Text('Ajoutez des produits depuis les boutiques', style: TextStyle(color: Color(0xFF9CA3AF))),
                ],
              ),
            )
          : Column(
              children: [
                if (cart.storeName != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                    child: Row(
                      children: [
                        const Icon(Icons.store, color: Color(0xFFF59E0B), size: 16),
                        const SizedBox(width: 8),
                        Text(cart.storeName!, style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final item = cart.items[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              if (item.product.images.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(item.product.images[0], width: 60, height: 60, fit: BoxFit.cover),
                                )
                              else
                                Container(width: 60, height: 60, decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.fastfood_outlined, color: Color(0xFFF59E0B))),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text('${item.product.price.toStringAsFixed(0)} MRU / unité', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    color: const Color(0xFFF59E0B),
                                    onPressed: () => cart.updateQuantity(item.product.id, item.quantity - 1),
                                  ),
                                  Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: const Color(0xFFF59E0B),
                                    onPressed: () => cart.updateQuantity(item.product.id, item.quantity + 1),
                                  ),
                                ],
                              ),
                              Text('${item.total.toStringAsFixed(0)} MRU', style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -4))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Sous-total', style: TextStyle(color: Color(0xFF6B7280))),
                          Text('${cart.subtotal.toStringAsFixed(0)} MRU', style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/checkout'),
                          child: Text('Commander - ${cart.subtotal.toStringAsFixed(0)} MRU'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
