import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _nameArCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _originalPriceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedUnit;
  List<String> _imageUrls = [];
  List<Map<String, dynamic>> _categories = [];
  bool _loading = false;
  bool _loadingCategories = true;

  final List<String> _units = [
    'Pièce', 'Kg', 'g', 'L', 'mL', 'Boîte', 'Sachet', 'Paquet'
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameArCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _originalPriceCtrl.dispose();
    _stockCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final data = await ApiService.getCategories();
      if (data['success'] == true) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(data['data'] ?? []);
          _loadingCategories = false;
        });
      } else {
        setState(() => _loadingCategories = false);
      }
    } catch (_) {
      setState(() => _loadingCategories = false);
    }
  }

  void _addImageUrl() {
    final url = _imageUrlCtrl.text.trim();
    if (url.isNotEmpty && !_imageUrls.contains(url)) {
      setState(() {
        _imageUrls.add(url);
        _imageUrlCtrl.clear();
      });
    }
  }

  void _removeImage(int index) {
    setState(() => _imageUrls.removeAt(index));
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final data = {
      'name': _nameCtrl.text.trim(),
      if (_nameArCtrl.text.trim().isNotEmpty)
        'nameAr': _nameArCtrl.text.trim(),
      if (_descCtrl.text.trim().isNotEmpty)
        'description': _descCtrl.text.trim(),
      'price': double.tryParse(_priceCtrl.text.trim()) ?? 0,
      if (_originalPriceCtrl.text.trim().isNotEmpty)
        'originalPrice':
            double.tryParse(_originalPriceCtrl.text.trim()),
      if (_stockCtrl.text.trim().isNotEmpty)
        'stock': int.tryParse(_stockCtrl.text.trim()),
      if (_selectedUnit != null) 'unit': _selectedUnit,
      if (_selectedCategoryId != null) 'categoryId': _selectedCategoryId,
      'images': _imageUrls,
    };

    try {
      final result = await ApiService.createProduct(data);
      if (!mounted) return;
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produit soumis en attente de validation'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 3),
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
          content: Text('Erreur réseau. Réessayez.'),
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
      appBar: AppBar(title: Text(l10n.t('add_product'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _sectionTitle('Informations du produit'),
            const SizedBox(height: 14),

            // Name FR
            _buildField(
              controller: _nameCtrl,
              label: '${l10n.t('product_name')} *',
              icon: Icons.label_outline,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Nom requis' : null,
            ),
            const SizedBox(height: 12),

            // Name AR
            _buildField(
              controller: _nameArCtrl,
              label: l10n.t('product_name_ar'),
              icon: Icons.translate,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 12),

            // Description
            _buildField(
              controller: _descCtrl,
              label: l10n.t('description'),
              icon: Icons.description_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            _sectionTitle('Prix & Stock'),
            const SizedBox(height: 14),

            // Price
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    controller: _priceCtrl,
                    label: '${l10n.t('price')} *',
                    icon: Icons.price_change_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Prix requis';
                      if (double.tryParse(v) == null) return 'Prix invalide';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    controller: _originalPriceCtrl,
                    label: l10n.t('original_price'),
                    icon: Icons.sell_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Stock & Unit
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    controller: _stockCtrl,
                    label: l10n.t('stock'),
                    icon: Icons.numbers,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    label: l10n.t('unit'),
                    value: _selectedUnit,
                    items: _units
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedUnit = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _sectionTitle('Catégorie'),
            const SizedBox(height: 14),

            if (_loadingCategories)
              const Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFFF59E0B)),
                ),
              )
            else
              _buildDropdown(
                label: l10n.t('category'),
                value: _selectedCategoryId,
                items: _categories
                    .map((c) => DropdownMenuItem(
                          value: c['id'] as String,
                          child: Text(c['name'] ?? '', overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
              ),

            const SizedBox(height: 20),

            _sectionTitle('Images'),
            const SizedBox(height: 14),

            // Image URL input
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _imageUrlCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'URL de l\'image',
                      hintText: 'https://...',
                      prefixIcon: const Icon(Icons.link,
                          color: Colors.grey, size: 18),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addImageUrl,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                  child: const Icon(Icons.add, size: 18),
                ),
              ],
            ),

            if (_imageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  _imageUrls.length,
                  (i) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFFF59E0B).withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.image_outlined,
                            color: Color(0xFFF59E0B), size: 14),
                        const SizedBox(width: 4),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: Text(
                            'Image ${i + 1}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _removeImage(i),
                          child: const Icon(Icons.close,
                              color: Colors.grey, size: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submitProduct,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black),
                      )
                    : Text(l10n.t('submit_for_review')),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                l10n.t('product_pending_msg'),
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFF59E0B),
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    TextDirection? textDirection,
  }) {
    return TextFormField(
      controller: controller,
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
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          items: items,
          onChanged: onChanged,
          dropdownColor: const Color(0xFF1A1A2E),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          isExpanded: true,
          icon: const Icon(Icons.expand_more, color: Colors.grey),
        ),
      ),
    );
  }
}
