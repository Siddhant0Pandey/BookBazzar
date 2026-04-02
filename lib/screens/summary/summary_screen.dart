// lib/screens/dashboard/summary_screen.dart
// Shows daily sales summary with date navigation

import 'package:flutter/material.dart';
import 'package:bookbaazar/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common_widgets.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _summary;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() => _isLoading = true);
    final data = await context.read<AppProvider>().getDailySummary(_selectedDate);
    setState(() { _summary = data; _isLoading = false; });
  }

  void _changeDate(int days) {
    setState(() => _selectedDate = _selectedDate.add(Duration(days: days)));
    _loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final summary = _summary;

    final totalSales = summary?['totalSales'] as double? ?? 0;
    final cashReceived = summary?['cashReceived'] as double? ?? 0;
    final creditGiven = summary?['creditGiven'] as double? ?? 0;
    final txCount = summary?['transactionCount'] as int? ?? 0;
    final creditCount = summary?['creditCustomerCount'] as int? ?? 0;
    final sales = (summary?['sales'] as List<Sale>?) ?? [];

    final cashPct = totalSales > 0 ? (cashReceived / totalSales) : 0.0;
    final creditPct = totalSales > 0 ? (creditGiven / totalSales) : 0.0;

    final isToday = _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.dailySummary),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Date Navigator ────────────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => _changeDate(-1),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                isToday
                                    ? 'Today, ${AppFormat.date(_selectedDate)}'
                                    : AppFormat.date(_selectedDate),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: isToday ? null : () => _changeDate(1),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Stats Cards ───────────────────────────────────────
                StatCard(
                  icon: Icons.shopping_bag_outlined,
                  title: l.totalSales,
                  value: AppFormat.currency(totalSales),
                  subtitle: l.transactions(txCount),
                ),
                const SizedBox(height: 12),
                StatCard(
                  icon: Icons.currency_rupee,
                  title: l.cashReceived,
                  value: AppFormat.currency(cashReceived),
                  subtitle: totalSales > 0
                      ? '${(cashPct * 100).toStringAsFixed(0)}% of total sales'
                      : null,
                ),
                const SizedBox(height: 12),
                StatCard(
                  icon: Icons.receipt_long_outlined,
                  title: l.creditGiven,
                  value: AppFormat.currency(creditGiven),
                  subtitle: creditCount > 0 ? l.customers(creditCount) : null,
                  subtitleColor: AppColors.warning,
                ),
                const SizedBox(height: 16),

                // ── Sales Breakdown ───────────────────────────────────
                if (totalSales > 0) ...[
                  SectionHeader(title: l.salesBreakdown),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(l.paymentMethods, style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              )),
                              const Spacer(),
                              Container(width: 10, height: 10, decoration: const BoxDecoration(
                                color: AppColors.primary, shape: BoxShape.circle,
                              )),
                              const SizedBox(width: 4),
                              Text(l.cash, style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 12),
                              Container(width: 10, height: 10, decoration: const BoxDecoration(
                                color: AppColors.warning, shape: BoxShape.circle,
                              )),
                              const SizedBox(width: 4),
                              Text(l.credit, style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _BarRow(
                            label: l.cashPayments,
                            value: '${AppFormat.currency(cashReceived)} (${(cashPct * 100).toStringAsFixed(0)}%)',
                            progress: cashPct,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 12),
                          _BarRow(
                            label: l.creditPayments,
                            value: '${AppFormat.currency(creditGiven)} (${(creditPct * 100).toStringAsFixed(0)}%)',
                            progress: creditPct,
                            color: AppColors.warning,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Recent Transactions ────────────────────────────────
                SectionHeader(title: l.recentTransactions),
                if (sales.isEmpty)
                  EmptyState(icon: Icons.receipt_long_outlined, title: 'No Sales', message: l.noSalesFound)
                else
                  ...sales.map((sale) => _SaleTile(sale: sale)),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final String value;
  final double progress;
  final Color color;

  const _BarRow({required this.label, required this.value, required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}

class _SaleTile extends StatelessWidget {
  final Sale sale;

  const _SaleTile({required this.sale});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryLighter,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.shopping_cart_outlined, color: AppColors.primary, size: 20),
        ),
        title: Text('${sale.productName} × ${sale.quantity}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(
          '${sale.date.hour}:${sale.date.minute.toString().padLeft(2, '0')} ${sale.date.hour >= 12 ? 'PM' : 'AM'}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: Text(AppFormat.currency(sale.totalPrice), style: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 15,
        )),
      ),
    );
  }
}

