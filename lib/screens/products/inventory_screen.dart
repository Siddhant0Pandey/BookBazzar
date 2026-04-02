// lib/screens/products/inventory_screen.dart
import 'package:flutter/material.dart';
import 'package:bookbaazar/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common_widgets.dart';
import '../../models/product_model.dart';
import 'add_edit_product_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchQuery = '';
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.inventory),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // ── Search + filter bar ──────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              children: [
                AppSearchBar(
                  hint: l.searchProducts,
                  onChanged: (q) {
                    setState(() => _searchQuery = q);
                    provider.filterProducts(q, _filter);
                  },
                ),
                const SizedBox(height: 10),
                FilterChipRow(
                  labels: [l.all, l.lowStock, l.outOfStock],
                  values: ['all', 'low', 'out'],
                  selected: _filter,
                  onSelected: (f) {
                    setState(() => _filter = f);
                    provider.filterProducts(_searchQuery, f);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 1),

          // ── Product list ─────────────────────────────────────────
          Expanded(
            child: provider.filteredProducts.isEmpty
                ? EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'No Products Yet',
                    message: 'Tap the + button below\nto add your first product',
                    actionLabel: 'Add Product',
                    onAction: () => _openForm(null),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: provider.filteredProducts.length,
                    itemBuilder: (ctx, i) => _ProductCard(
                      product: provider.filteredProducts[i],
                      onEdit: () => _openForm(provider.filteredProducts[i]),
                      onDelete: () => _confirmDelete(provider.filteredProducts[i]),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(null),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _openForm(Product? product) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => AddEditProductScreen(product: product),
    ));
  }

  void _confirmDelete(Product product) {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Product', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Delete "${product.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<AppProvider>().deleteProduct(product.id!);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─── Product Card with emoji image ───────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({required this.product, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.border;
    if (product.isOutOfStock) borderColor = AppColors.danger;
    else if (product.isLowStock) borderColor = AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (product.isLowStock || product.isOutOfStock) ? borderColor : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // ── Product image (emoji in colored circle) ──────────────
            ProductEmoji(emoji: product.displayEmoji, size: 60),
            const SizedBox(width: 14),

            // ── Product info ─────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  )),
                  const SizedBox(height: 3),
                  Text(product.category, style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  )),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _InfoPill(
                        label: 'Qty: ${product.quantity}',
                        color: product.isOutOfStock
                            ? AppColors.danger
                            : product.isLowStock
                                ? AppColors.warning
                                : AppColors.primary,
                        bg: product.isOutOfStock
                            ? AppColors.dangerLight
                            : product.isLowStock
                                ? AppColors.warningLight
                                : AppColors.primaryLighter,
                      ),
                      const SizedBox(width: 6),
                      _InfoPill(
                        label: AppFormat.currency(product.sellingPrice),
                        color: AppColors.textSecondary,
                        bg: const Color(0xFFF3F4F6),
                      ),
                    ],
                  ),
                  if (product.isLowStock || product.isOutOfStock) ...[
                    const SizedBox(height: 6),
                    product.isOutOfStock
                        ? AppBadge(
                            label: 'Out of Stock',
                            color: AppColors.danger,
                            backgroundColor: AppColors.dangerLight,
                            icon: Icons.remove_circle_outline,
                          )
                        : AppBadge.lowStock('Low Stock'),
                  ],
                ],
              ),
            ),

            // ── Actions ──────────────────────────────────────────────
            Column(
              children: [
                _ActionBtn(icon: Icons.edit_outlined, color: AppColors.primary, onTap: onEdit),
                const SizedBox(height: 6),
                _ActionBtn(icon: Icons.delete_outline_rounded, color: AppColors.danger, onTap: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const _InfoPill({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(
        color: color, fontSize: 11.5, fontWeight: FontWeight.w600,
      )),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, color: color, size: 17),
      ),
    );
  }
}
