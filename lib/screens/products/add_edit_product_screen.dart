// lib/screens/products/add_edit_product_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bookbaazar/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/product_model.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common_widgets.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;
  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _costCtrl;
  late final TextEditingController _sellCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _thresholdCtrl;

  String _category = 'Grocery';
  String _selectedEmoji = '📦';
  bool _isSaving = false;

  static const List<String> _categories = [
    'Grocery', 'Drinks', 'Snacks', 'Dairy',
    'Vegetables', 'Fruits', 'Medicine', 'Other'
  ];

  // Emoji options grouped by category
  static const List<String> _emojiOptions = [
    '📦','🥤','🍪','🛒','🥛','🥦','🍎','💊',
    '🍫','🍜','🥚','🧃','🍵','🧂','🫙','🍞',
    '🧴','🧹','🪥','🛁','📱','🔋','💡','🧲',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl      = TextEditingController(text: p?.name ?? '');
    _costCtrl      = TextEditingController(text: p != null ? p.costPrice.toStringAsFixed(0) : '');
    _sellCtrl      = TextEditingController(text: p != null ? p.sellingPrice.toStringAsFixed(0) : '');
    _qtyCtrl       = TextEditingController(text: p != null ? p.quantity.toString() : '');
    _thresholdCtrl = TextEditingController(text: (p?.lowStockThreshold ?? 10).toString());
    _category      = p?.category ?? 'Grocery';
    _selectedEmoji = p?.imageEmoji.isNotEmpty == true ? p!.imageEmoji : p?.displayEmoji ?? '📦';
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _costCtrl.dispose(); _sellCtrl.dispose();
    _qtyCtrl.dispose(); _thresholdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isEdit = widget.product != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? l.editProduct : l.addProduct),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            // ── Emoji picker card ────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Product Image', style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14,
                    color: AppColors.textSecondary,
                  )),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Preview
                      ProductEmoji(emoji: _selectedEmoji, size: 72),
                      const SizedBox(width: 16),
                      // Emoji grid
                      Expanded(
                        child: Wrap(
                          spacing: 8, runSpacing: 8,
                          children: _emojiOptions.map((e) {
                            final isSelected = e == _selectedEmoji;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedEmoji = e),
                              child: Container(
                                width: 38, height: 38,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primaryLighter : const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Center(child: Text(e, style: const TextStyle(fontSize: 18))),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Main fields card ─────────────────────────────────────
            _FormCard(children: [
              _field(
                label: l.productName,
                controller: _nameCtrl,
                hint: 'e.g. Coca Cola 500ml',
                validator: (v) => v!.trim().isEmpty ? 'Name required' : null,
              ),
              const SizedBox(height: 14),

              // Category dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.category, style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
                  )),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _category,
                    decoration: InputDecoration(
                      filled: true, fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    ),
                    items: _categories.map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c, style: const TextStyle(fontSize: 14)),
                    )).toList(),
                    onChanged: (v) {
                      setState(() {
                        _category = v!;
                        // Auto-suggest emoji based on category
                        final suggestion = _categoryEmoji(v);
                        if (!_emojiOptions.contains(_selectedEmoji) ||
                            _selectedEmoji == '📦') {
                          _selectedEmoji = suggestion;
                        }
                      });
                    },
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 12),

            // ── Price card ───────────────────────────────────────────
            _FormCard(children: [
              const Text('Pricing', style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary,
              )),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _field(
                  label: l.costPrice,
                  controller: _costCtrl,
                  hint: '0',
                  prefix: '₹',
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                )),
                const SizedBox(width: 12),
                Expanded(child: _field(
                  label: l.sellingPrice,
                  controller: _sellCtrl,
                  hint: '0',
                  prefix: '₹',
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                )),
              ]),
            ]),
            const SizedBox(height: 12),

            // ── Stock card ───────────────────────────────────────────
            _FormCard(children: [
              const Text('Stock', style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary,
              )),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _field(
                  label: l.quantity,
                  controller: _qtyCtrl,
                  hint: '0',
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                )),
                const SizedBox(width: 12),
                Expanded(child: _field(
                  label: l.lowStockAlert,
                  controller: _thresholdCtrl,
                  hint: '10',
                  keyboardType: TextInputType.number,
                )),
              ]),
            ]),
            const SizedBox(height: 24),

            PrimaryButton(
              label: isEdit ? l.saveChanges : l.addProduct,
              icon: isEdit ? Icons.check_rounded : Icons.add_rounded,
              isLoading: _isSaving,
              onPressed: _save,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _categoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'drinks': return '🥤';
      case 'snacks': return '🍪';
      case 'grocery': return '🛒';
      case 'dairy': return '🥛';
      case 'vegetables': return '🥦';
      case 'fruits': return '🍎';
      case 'medicine': return '💊';
      default: return '📦';
    }
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? hint,
    String? prefix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
        )),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: keyboardType == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly] : null,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final product = Product(
      id:               widget.product?.id,
      name:             _nameCtrl.text.trim(),
      category:         _category,
      costPrice:        double.tryParse(_costCtrl.text) ?? 0,
      sellingPrice:     double.tryParse(_sellCtrl.text) ?? 0,
      quantity:         int.tryParse(_qtyCtrl.text) ?? 0,
      lowStockThreshold:int.tryParse(_thresholdCtrl.text) ?? 10,
      imageEmoji:       _selectedEmoji,
    );

    await context.read<AppProvider>().saveProduct(product);
    if (mounted) Navigator.pop(context);
  }
}

// ─── Helper: white rounded card wrapper ─────────────────────────────────────
class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
