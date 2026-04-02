// lib/screens/customers/customers_screen.dart
// Shows all customers with their credit status

import 'package:flutter/material.dart';
import 'package:bookbaazar/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common_widgets.dart';
import 'customer_detail_screen.dart';
import 'add_customer_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  String _searchQuery = '';
  String _filter = 'all'; // 'all', 'pending', 'cleared'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadCustomers();
    });
  }

  List<CustomerSummary> _filtered(List<CustomerSummary> all) {
    var list = all;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      list = list.where((s) =>
        s.customer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        s.customer.phone.contains(_searchQuery)
      ).toList();
    }

    // Status filter
    switch (_filter) {
      case 'pending':
        list = list.where((s) => s.outstanding > 0).toList();
        break;
      case 'cleared':
        list = list.where((s) => s.isCleared).toList();
        break;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final provider = context.watch<AppProvider>();
    final summaries = _filtered(provider.customerSummaries);

    // Aggregate totals for header
    final totalPending = provider.customerSummaries
        .fold<double>(0, (sum, s) => sum + (s.outstanding > 0 ? s.outstanding : 0));
    final totalCollected = provider.customerSummaries
        .fold<double>(0, (sum, s) => sum + s.totalPaid);
    final pendingCount = provider.customerSummaries.where((s) => s.outstanding > 0).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.customersAndCredit),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Header summary cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _SummaryChip(
                      label: l.customers(provider.customerSummaries.length),
                      sublabel: l.registered,
                      color: AppColors.primary,
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _SummaryChip(
                      label: AppFormat.currency(totalPending),
                      sublabel: l.fromCustomers(pendingCount),
                      color: AppColors.danger,
                      isHighlight: true,
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _SummaryChip(
                      label: AppFormat.currency(totalCollected),
                      sublabel: l.thisMonth,
                      color: AppColors.primary,
                    )),
                  ],
                ),
                const SizedBox(height: 12),
                AppSearchBar(
                  hint: l.searchCustomers,
                  onChanged: (q) => setState(() => _searchQuery = q),
                ),
                const SizedBox(height: 10),
                FilterChipRow(
                  labels: [
                    '${l.all} (${provider.customerSummaries.length})',
                    '${l.pending} ($pendingCount)',
                    '${l.cleared} (${provider.customerSummaries.length - pendingCount})',
                  ],
                  values: ['all', 'pending', 'cleared'],
                  selected: _filter,
                  onSelected: (f) => setState(() => _filter = f),
                ),
              ],
            ),
          ),

          // Customer list
          Expanded(
            child: summaries.isEmpty
                ? EmptyState(
                    icon: Icons.people_alt_rounded,
                    title: "No Customers Yet",
                    message: "Add your first customer to start tracking credit and payments",
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: summaries.length,
                    itemBuilder: (ctx, i) => _CustomerCard(
                      summary: summaries[i],
                      onTap: () => Navigator.push(ctx, MaterialPageRoute(
                        builder: (_) => CustomerDetailScreen(customer: summaries[i].customer),
                      )),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const AddCustomerScreen(),
        )),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ─── Customer Card ────────────────────────────────────────────────────────────
class _CustomerCard extends StatelessWidget {
  final CustomerSummary summary;
  final VoidCallback onTap;

  const _CustomerCard({required this.summary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = summary.customer;
    final isPending = summary.outstanding > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // Name + balance row
            Row(
              children: [
                CustomerAvatar(avatarIndex: c.avatarIndex),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name, style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15,
                      )),
                      Row(children: [
                        const Icon(Icons.phone, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(c.phone, style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12,
                        )),
                      ]),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(AppFormat.currency(summary.outstanding), style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16,
                      color: isPending ? AppColors.danger : AppColors.primary,
                    )),
                    const SizedBox(height: 4),
                    isPending ? AppBadge.pending(l.pending) : AppBadge.cleared(l.cleared),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Stats row
            Row(
              children: [
                _StatItem(label: l.totalCredit, value: AppFormat.currency(summary.totalCredit)),
                _StatItem(label: l.paidSoFar, value: AppFormat.currency(summary.totalPaid)),
                if (isPending)
                  _StatItem(
                    label: l.daysPending,
                    value: summary.lastActivityDate != null
                        ? AppFormat.relativeDate(summary.lastActivityDate!)
                        : '-',
                  )
                else
                  _StatItem(label: 'Last', value: summary.lastActivityDate != null
                    ? AppFormat.relativeDate(summary.lastActivityDate!) : '-'),
              ],
            ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                if (isPending) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.currency_rupee, size: 16),
                      label: Text(l.collectPayment),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.remove_red_eye_outlined, size: 16,
                        color: AppColors.textSecondary),
                    label: Text(isPending ? l.viewHistory : l.viewFullHistory,
                      style: const TextStyle(color: AppColors.textSecondary)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color color;
  final bool isHighlight;

  const _SummaryChip({
    required this.label,
    required this.sublabel,
    required this.color,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isHighlight ? AppColors.dangerLight : AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(
            color: color, fontWeight: FontWeight.bold, fontSize: 13,
          )),
          const SizedBox(height: 2),
          Text(sublabel, style: const TextStyle(
            color: AppColors.textSecondary, fontSize: 10,
          )),
        ],
      ),
    );
  }
}
