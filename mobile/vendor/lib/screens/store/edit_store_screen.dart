import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../models/store.dart';

class EditStoreScreen extends StatefulWidget {
  final Store store;

  const EditStoreScreen({super.key, required this.store});

  @override
  State<EditStoreScreen> createState() => _EditStoreScreenState();
}

class _EditStoreScreenState extends State<EditStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _nameArCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _districtCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _openTimeCtrl;
  late TextEditingController _closeTimeCtrl;
  late TextEditingController _deliveryFeeCtrl;
  late TextEditingController _minOrderCtrl;
  late TextEditingController _logoCtrl;
  late bool _isOpen;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final s = widget.store;
    _nameCtrl = TextEditingController(text: s.name);
    _nameArCtrl = TextEditingController(text: s.nameAr ?? '');
    _descCtrl = TextEditingController(text: s.description ?? '');
    _phoneCtrl = TextEditingController(text: s.phone ?? '');
    _addressCtrl = TextEditingController(text: s.address ?? '');
    _districtCtrl = TextEditingController(text: s.district ?? '');
    _cityCtrl = TextEditingController(text: s.city);
    _openTimeCtrl = TextEditingController(text: s.openTime ?? '');
    _closeTimeCtrl = TextEditingController(text: s.closeTime ?? '');
    _deliveryFeeCtrl =
        TextEditingController(text: s.deliveryFee.toStringAsFixed(0));
    _minOrderCtrl =
        TextEditingController(text: s.minOrder.toStringAsFixed(0));
    _logoCtrl = TextEditingController(text: s.logo ?? '');
    _isOpen = s.isOpen;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameArCtrl.dispose();
    _descCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _districtCtrl.dispose();
    _cityCtrl.dispose();
    _openTimeCtrl.dispose();
    _closeTimeCtrl.dispose();
    _deliveryFeeCtrl.dispose();
    _minOrderCtrl.dispose();
    _logoCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
    };

    if (_nameArCtrl.text.trim().isNotEmpty)
      data['nameAr'] = _nameArCtrl.text.trim();
    if (_descCtrl.text.trim().isNotEmpty)
      data['description'] = _descCtrl.text.trim();
    if (_phoneCtrl.text.trim().isNotEmpty)
      data['phone'] = _phoneCtrl.text.trim();
    if (_addressCtrl.text.trim().isNotEmpty)
      data['address'] = _addressCtrl.text.trim();
    if (_districtCtrl.text.trim().isNotEmpty)
      data['district'] = _districtCtrl.text.trim();
    if (_cityCtrl.text.trim().isNotEmpty)
      data['city'] = _cityCtrl.text.trim();
    if (_openTimeCtrl.text.trim().isNotEmpty)
      data['openTime'] = _openTimeCtrl.text.trim();
    if (_closeTimeCtrl.text.trim().isNotEmpty)
      data['closeTime'] = _closeTimeCtrl.text.trim();
    if (_logoCtrl.text.trim().isNotEmpty)
      data['logo'] = _logoCtrl.text.trim();
    data['isOpen'] = _isOpen;
    if (_deliveryFeeCtrl.text.trim().isNotEmpty)
      data['deliveryFee'] = double.tryParse(_deliveryFeeCtrl.text.trim()) ?? 0;
    if (_minOrderCtrl.text.trim().isNotEmpty)
      data['minOrder'] = double.tryParse(_minOrderCtrl.text.trim()) ?? 0;

    try {
      final result = await ApiService.updateStore(data);
      if (!mounted) return;
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Boutique mise à jour'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        Navigator.pop(context, true);
      } else {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erreur'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur réseau'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: Text(l10n.t('edit_store')),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFFF59E0B)),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: Text(l10n.t('save'),
                  style: const TextStyle(
                      color: Color(0xFFF59E0B),
                      fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _section('Informations générales'),
            _field(_nameCtrl, l10n.t('store_name'), Icons.store_outlined,
                required: true),
            _field(_nameArCtrl, l10n.t('store_name_ar'), Icons.translate,
                textDirection: TextDirection.rtl),
            _field(_descCtrl, l10n.t('description'),
                Icons.description_outlined,
                maxLines: 3),
            _field(_phoneCtrl, l10n.t('phone'), Icons.phone_outlined,
                keyboardType: TextInputType.phone),

            _section('Localisation'),
            _field(_addressCtrl, l10n.t('address'),
                Icons.location_on_outlined),
            _field(
                _districtCtrl, l10n.t('district'), Icons.map_outlined),
            _field(_cityCtrl, l10n.t('city'),
                Icons.location_city_outlined),

            _section('Horaires'),
            Row(
              children: [
                Expanded(
                    child: _field(_openTimeCtrl, l10n.t('open_time'),
                        Icons.wb_sunny_outlined)),
                const SizedBox(width: 12),
                Expanded(
                    child: _field(_closeTimeCtrl, l10n.t('close_time'),
                        Icons.nights_stay_outlined)),
              ],
            ),

            _section('Livraison'),
            Row(
              children: [
                Expanded(
                    child: _field(
                        _deliveryFeeCtrl, l10n.t('delivery_fee'),
                        Icons.delivery_dining_outlined,
                        keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(
                    child: _field(
                        _minOrderCtrl, l10n.t('min_order'),
                        Icons.shopping_cart_outlined,
                        keyboardType: TextInputType.number)),
              ],
            ),

            _section('Médias'),
            _field(_logoCtrl, 'URL du logo', Icons.image_outlined),

            _section('Statut'),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _isOpen ? Icons.store : Icons.store_outlined,
                    color: _isOpen
                        ? const Color(0xFF10B981)
                        : Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.t('is_open'),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  Switch(
                    value: _isOpen,
                    onChanged: (v) => setState(() => _isOpen = v),
                    activeColor: const Color(0xFF10B981),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black),
                      )
                    : Text(l10n.t('save')),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFF59E0B),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
    bool required = false,
    TextDirection? textDirection,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textDirection: textDirection,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey, size: 18),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        validator: required
            ? (v) => v == null || v.isEmpty ? 'Champ requis' : null
            : null,
      ),
    );
  }
}
