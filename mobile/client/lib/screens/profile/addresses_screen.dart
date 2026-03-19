import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';
import '../../models/address.dart';

class AddressesScreen extends StatefulWidget {
  final bool selectMode; // If true, pop with selected address
  const AddressesScreen({super.key, this.selectMode = false});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().load();
    });
  }

  void _showAddDialog() {
    final formKey = GlobalKey<FormState>();
    final label = TextEditingController(text: 'Domicile');
    final street = TextEditingController();
    final district = TextEditingController();
    final city = TextEditingController(text: 'Nouakchott');
    bool isDefault = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Nouvelle adresse', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: label,
                  decoration: InputDecoration(
                    labelText: 'Libellé (ex: Domicile, Bureau)',
                    labelStyle: GoogleFonts.cairo(),
                  ),
                  style: GoogleFonts.cairo(),
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: street,
                  decoration: InputDecoration(labelText: 'Rue / Adresse *', labelStyle: GoogleFonts.cairo()),
                  style: GoogleFonts.cairo(),
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: district,
                  decoration: InputDecoration(labelText: 'Quartier', labelStyle: GoogleFonts.cairo()),
                  style: GoogleFonts.cairo(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: city,
                  decoration: InputDecoration(labelText: 'Ville *', labelStyle: GoogleFonts.cairo()),
                  style: GoogleFonts.cairo(),
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Switch(
                      value: isDefault,
                      onChanged: (v) => setModalState(() => isDefault = v),
                      activeColor: const Color(0xFFF59E0B),
                    ),
                    Text('Adresse par défaut', style: GoogleFonts.cairo()),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      try {
                        await context.read<AddressProvider>().addAddress({
                          'label': label.text,
                          'street': street.text,
                          'district': district.text.isNotEmpty ? district.text : null,
                          'city': city.text,
                          'isDefault': isDefault,
                        });
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Adresse ajoutée', style: GoogleFonts.cairo()), backgroundColor: Colors.green),
                          );
                        }
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur', style: GoogleFonts.cairo()), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                    child: Text('Ajouter', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddressProvider>();
    final addresses = provider.addresses;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      appBar: AppBar(
        title: Text(
          widget.selectMode ? 'Choisir une adresse' : 'Mes adresses',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFFF59E0B),
        label: Text('Ajouter', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
        icon: const Icon(Icons.add),
      ),
      body: provider.loading && addresses.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B)))
          : addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('Aucune adresse', style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey.shade500)),
                      const SizedBox(height: 8),
                      Text('Ajoutez une adresse de livraison', style: GoogleFonts.cairo(color: Colors.grey.shade400)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: addresses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final addr = addresses[index];
                    return Card(
                      elevation: addr.isDefault ? 3 : 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: addr.isDefault
                            ? const BorderSide(color: Color(0xFFF59E0B), width: 2)
                            : BorderSide.none,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: widget.selectMode ? () => Navigator.pop(context, addr) : null,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: addr.isDefault
                                      ? const Color(0xFFF59E0B).withOpacity(0.15)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  addr.label.toLowerCase().contains('maison') ||
                                          addr.label.toLowerCase().contains('domicile')
                                      ? Icons.home_outlined
                                      : addr.label.toLowerCase().contains('bureau') ||
                                              addr.label.toLowerCase().contains('work')
                                          ? Icons.business_outlined
                                          : Icons.location_on_outlined,
                                  color: addr.isDefault ? const Color(0xFFF59E0B) : Colors.grey.shade500,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          addr.label,
                                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        if (addr.isDefault) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF59E0B).withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'Défaut',
                                              style: GoogleFonts.cairo(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFFF59E0B),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${addr.street}${addr.district != null ? ', ${addr.district}' : ''}',
                                      style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey.shade600),
                                    ),
                                    Text(
                                      addr.city,
                                      style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (v) async {
                                  if (v == 'default') {
                                    await context.read<AddressProvider>().setDefault(addr.id);
                                  } else if (v == 'delete') {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text('Supprimer ?', style: GoogleFonts.cairo()),
                                        content: Text('Voulez-vous supprimer cette adresse ?', style: GoogleFonts.cairo()),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Annuler', style: GoogleFonts.cairo())),
                                          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Supprimer', style: GoogleFonts.cairo())),
                                        ],
                                      ),
                                    );
                                    if (confirm == true && mounted) {
                                      await context.read<AddressProvider>().deleteAddress(addr.id);
                                    }
                                  }
                                },
                                itemBuilder: (_) => [
                                  if (!addr.isDefault)
                                    PopupMenuItem(
                                      value: 'default',
                                      child: Text('Définir par défaut', style: GoogleFonts.cairo()),
                                    ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Supprimer', style: GoogleFonts.cairo(color: Colors.red)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
