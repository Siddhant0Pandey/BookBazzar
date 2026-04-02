// lib/screens/sales/sale_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bookbaazar/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/product_model.dart';
import '../../models/models.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common_widgets.dart';
import '../products/add_edit_product_screen.dart';
import '../customers/add_customer_screen.dart';

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});
  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  Product? _product;
  int _qty = 1;
  bool _isCredit = false;
  Customer? _customer;
  bool _processing = false;

  double get _total => (_product?.sellingPrice ?? 0) * _qty;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final canConfirm = _product != null && (!_isCredit || _customer != null);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Sale'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Step 1: Product ──────────────────────────────────
                  _StepHeader(number: '1', title: 'Select Product'),
                  const SizedBox(height: 10),
                  _product == null
                      ? _ProductPickerTile(
                          products: provider.products,
                          onSelected: (p) =>
                              setState(() { _product = p; _qty = 1; }),
                          onAddProduct: () async {
                            await Navigator.push(context,
                              MaterialPageRoute(
                                builder: (_) => const AddEditProductScreen()));
                            await provider.loadProducts();
                          },
                        )
                      : _SelectedProduct(
                          product: _product!,
                          onClear: () => setState(() => _product = null),
                        ),

                  const SizedBox(height: 20),

                  // ── Step 2: Quantity ─────────────────────────────────
                  _StepHeader(number: '2', title: 'Quantity'),
                  const SizedBox(height: 10),
                  _QtyCard(
                    qty: _qty,
                    maxQty: _product?.quantity ?? 0,
                    unitPrice: _product?.sellingPrice ?? 0,
                    total: _total,
                    onDecrement: () {
                      if (_qty > 1) setState(() => _qty--);
                    },
                    onIncrement: () {
                      final max = _product?.quantity ?? 0;
                      if (_qty < max) setState(() => _qty++);
                    },
                    onType: (v) {
                      final n = int.tryParse(v) ?? 1;
                      final max = _product?.quantity ?? 0;
                      setState(() => _qty = n.clamp(1, max));
                    },
                  ),

                  const SizedBox(height: 20),

                  // ── Step 3: Payment ───────────────────────────────────
                  _StepHeader(number: '3', title: 'Payment Method'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _PayCard(
                          icon: Icons.currency_rupee_rounded,
                          label: 'Cash',
                          selected: !_isCredit,
                          onTap: () => setState(() {
                            _isCredit = false;
                            _customer = null;
                          }),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PayCard(
                          icon: Icons.receipt_long_rounded,
                          label: 'Credit',
                          selected: _isCredit,
                          onTap: () => _pickCustomer(provider),
                        ),
                      ),
                    ],
                  ),

                  // Customer chip when credit selected
                  if (_isCredit && _customer != null) ...[
                    const SizedBox(height: 12),
                    _CustomerChip(
                      customer: _customer!,
                      onRemove: () => setState(() {
                        _isCredit = false;
                        _customer = null;
                      }),
                    ),
                  ],

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),

          // ── Sticky bottom confirm bar ─────────────────────────────
          _ConfirmBar(
            total: _total,
            enabled: canConfirm,
            processing: _processing,
            onConfirm: () => _confirm(provider),
          ),
        ],
      ),
    );
  }

  // ─── Customer picker ────────────────────────────────────────────
  Future<void> _pickCustomer(AppProvider provider) async {
    if (_product == null) {
      _snack('Please select a product first', isError: true);
      return;
    }
    final customer = await showModalBottomSheet<Customer>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CustomerSheet(
        summaries: provider.customerSummaries,
        onAddNew: () async {
          Navigator.pop(context);
          await Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddCustomerScreen()));
          await provider.loadCustomers();
        },
      ),
    );
    if (customer != null) {
      setState(() { _isCredit = true; _customer = customer; });
    }
  }

  // ─── Confirm sale ───────────────────────────────────────────────
  Future<void> _confirm(AppProvider provider) async {
    if (_product == null) return;
    setState(() => _processing = true);
    try {
      await provider.recordSale(
        product: _product!,
        quantity: _qty,
        isCredit: _isCredit,
        customerId: _customer?.id,
      );
      if (mounted) {
        _snack('Sale recorded! ✓');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _snack(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.danger : AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
    ));
  }
}

// ─── Step header ─────────────────────────────────────────────────────────────
class _StepHeader extends StatelessWidget {
  final String number;
  final String title;
  const _StepHeader({required this.number, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24, height: 24,
          decoration: const BoxDecoration(
            color: AppColors.primary, shape: BoxShape.circle),
          child: Center(
            child: Text(number, style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary)),
      ],
    );
  }
}

// ─── Product picker tile ─────────────────────────────────────────────────────
class _ProductPickerTile extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product> onSelected;
  final VoidCallback onAddProduct;

  const _ProductPickerTile({
    required this.products,
    required this.onSelected,
    required this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSheet(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04),
                blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.search_rounded,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text('Search or select a product',
                style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 14.5)),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductSheet(
        products: products,
        onSelected: (p) { onSelected(p); Navigator.pop(context); },
        onAddNew: () { Navigator.pop(context); onAddProduct(); },
      ),
    );
  }
}

// ─── Product bottom sheet ─────────────────────────────────────────────────────
class _ProductSheet extends StatefulWidget {
  final List<Product> products;
  final ValueChanged<Product> onSelected;
  final VoidCallback onAddNew;

  const _ProductSheet({
    required this.products,
    required this.onSelected,
    required this.onAddNew,
  });

  @override
  State<_ProductSheet> createState() => _ProductSheetState();
}

class _ProductSheetState extends State<_ProductSheet> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.products
        .where((p) => p.name.toLowerCase().contains(_q.toLowerCase()))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      expand: false,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  const Text('Select Product',
                    style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  // ++ ADD NEW PRODUCT button right in the sheet header
                  GestureDetector(
                    onTap: widget.onAddNew,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLighter,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded,
                              color: AppColors.primary, size: 16),
                          SizedBox(width: 4),
                          Text('New Product',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _q = v),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search_rounded,
                      size: 20, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
              ),
            ),
            // Products
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inventory_2_outlined,
                              size: 40, color: AppColors.border),
                          const SizedBox(height: 12),
                          const Text('No products found',
                            style: TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: widget.onAddNew,
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Add Product'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: ctrl,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final p = filtered[i];
                        final disabled = p.isOutOfStock;
                        return GestureDetector(
                          onTap: disabled ? null
                              : () => widget.onSelected(p),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: disabled
                                  ? AppColors.background
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                ProductEmoji(
                                    emoji: p.displayEmoji, size: 44),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(p.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: disabled
                                              ? AppColors.textSecondary
                                              : AppColors.textPrimary,
                                        )),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${AppFormat.currency(p.sellingPrice)} / unit',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12.5)),
                                    ],
                                  ),
                                ),
                                disabled
                                    ? const _Pill(
                                        label: 'Out of stock',
                                        color: AppColors.danger,
                                        bg: AppColors.dangerLight)
                                    : _Pill(
                                        label: '${p.quantity} left',
                                        color: p.isLowStock
                                            ? AppColors.warning
                                            : AppColors.primary,
                                        bg: p.isLowStock
                                            ? AppColors.warningLight
                                            : AppColors.primaryLighter),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const _Pill({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label,
        style: TextStyle(color: color, fontSize: 11,
            fontWeight: FontWeight.w600)),
    );
  }
}

// ─── Selected product display ─────────────────────────────────────────────────
class _SelectedProduct extends StatelessWidget {
  final Product product;
  final VoidCallback onClear;
  const _SelectedProduct({required this.product, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          ProductEmoji(emoji: product.displayEmoji, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15,
                  color: AppColors.textPrimary)),
                Text('${AppFormat.currency(product.sellingPrice)} / unit  •  ${product.quantity} in stock',
                  style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12.5)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: Colors.white, shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.close_rounded,
                  size: 14, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quantity card ────────────────────────────────────────────────────────────
class _QtyCard extends StatelessWidget {
  final int qty;
  final int maxQty;
  final double unitPrice;
  final double total;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final ValueChanged<String> onType;

  const _QtyCard({
    required this.qty, required this.maxQty, required this.unitPrice,
    required this.total, required this.onDecrement,
    required this.onIncrement, required this.onType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _QtyBtn(icon: Icons.remove_rounded, onTap: onDecrement,
                  enabled: qty > 1),
              const SizedBox(width: 16),
              SizedBox(
                width: 72,
                child: TextField(
                  controller: TextEditingController(text: '$qty')
                    ..selection = TextSelection.collapsed(offset: '$qty'.length),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: onType,
                ),
              ),
              const SizedBox(width: 16),
              _QtyBtn(icon: Icons.add_rounded, onTap: onIncrement,
                  enabled: qty < maxQty),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${AppFormat.currency(unitPrice)} × $qty',
                  style: const TextStyle(
                    color: Colors.white70, fontSize: 14)),
                Text(AppFormat.currency(total),
                  style: const TextStyle(
                    color: Colors.white, fontSize: 22,
                    fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  const _QtyBtn({required this.icon, required this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

// ─── Payment method card ──────────────────────────────────────────────────────
class _PayCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PayCard({
    required this.icon, required this.label,
    required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 2,
          ),
          boxShadow: selected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.25),
              blurRadius: 12, offset: const Offset(0, 4)),
          ] : [],
        ),
        child: Column(
          children: [
            Icon(icon,
              color: selected ? Colors.white : AppColors.textSecondary,
              size: 30),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w700, fontSize: 15,
            )),
          ],
        ),
      ),
    );
  }
}

// ─── Customer chip ────────────────────────────────────────────────────────────
class _CustomerChip extends StatelessWidget {
  final Customer customer;
  final VoidCallback onRemove;
  const _CustomerChip({required this.customer, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CustomerAvatar(avatarIndex: customer.avatarIndex, size: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.name, style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14)),
                Text('Credit sale assigned', style: const TextStyle(
                  color: AppColors.warning, fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded,
                size: 18, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─── Confirm bottom bar ───────────────────────────────────────────────────────
class _ConfirmBar extends StatelessWidget {
  final double total;
  final bool enabled;
  final bool processing;
  final VoidCallback onConfirm;

  const _ConfirmBar({
    required this.total, required this.enabled,
    required this.processing, required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          if (total > 0) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Total',
                  style: TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
                Text(AppFormat.currency(total),
                  style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: enabled && !processing ? onConfirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.border,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                ),
                child: processing
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_circle_rounded,
                              size: 18, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Confirm Sale',
                            style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700,
                              color: Colors.white)),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Customer picker sheet ────────────────────────────────────────────────────
class _CustomerSheet extends StatelessWidget {
  final List<CustomerSummary> summaries;
  final VoidCallback onAddNew;

  const _CustomerSheet({required this.summaries, required this.onAddNew});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 4),
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Row(
              children: [
                const Text('Assign to Customer',
                  style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700)),
                const Spacer(),
                GestureDetector(
                  onTap: onAddNew,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLighter,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_add_rounded,
                            color: AppColors.primary, size: 15),
                        SizedBox(width: 4),
                        Text('New Customer',
                          style: TextStyle(
                            color: AppColors.primary, fontSize: 13,
                            fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (summaries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.people_outline,
                      size: 36, color: AppColors.border),
                  const SizedBox(height: 8),
                  const Text('No customers yet',
                    style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: onAddNew,
                    icon: const Icon(Icons.person_add_rounded, size: 16),
                    label: const Text('Add Customer'),
                  ),
                ],
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: summaries.length,
                itemBuilder: (_, i) {
                  final s = summaries[i];
                  return ListTile(
                    leading: CustomerAvatar(
                        avatarIndex: s.customer.avatarIndex),
                    title: Text(s.customer.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(s.customer.phone),
                    trailing: s.outstanding > 0
                        ? Text(AppFormat.currency(s.outstanding),
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w700))
                        : null,
                    onTap: () => Navigator.pop(context, s.customer),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
