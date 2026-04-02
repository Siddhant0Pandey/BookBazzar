// lib/screens/customers/customer_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common_widgets.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;
  const CustomerDetailScreen({super.key, required this.customer});
  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  List<Credit> _credits = [];
  double _outstanding = 0;
  double _totalCredit = 0;
  double _totalPaid = 0;
  bool _loading = true;
  bool _processing = false;
  final _payCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _payCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final credits = await context.read<AppProvider>()
        .getCustomerCredits(widget.customer.id!);
    double cr = 0, pd = 0;
    for (final c in credits) {
      if (c.amount > 0) cr += c.amount; else pd += c.amount.abs();
    }
    setState(() {
      _credits = credits;
      _totalCredit = cr;
      _totalPaid = pd;
      _outstanding = cr - pd;
      _loading = false;
    });
  }

  Future<void> _collect() async {
    final amt = double.tryParse(_payCtrl.text.trim());
    if (amt == null || amt <= 0) {
      _snack('Enter a valid amount', isError: true); return;
    }
    if (amt > _outstanding) {
      _snack('Amount exceeds outstanding balance', isError: true); return;
    }
    setState(() => _processing = true);
    await context.read<AppProvider>()
        .collectPayment(widget.customer.id!, amt);
    _payCtrl.clear();
    await _load();
    if (mounted) _snack('Payment of ${AppFormat.currency(amt)} collected!');
    setState(() => _processing = false);
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

  void _showPaymentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentSheet(
        outstanding: _outstanding,
        controller: _payCtrl,
        processing: _processing,
        onCollect: () { Navigator.pop(context); _collect(); },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.customer;
    final isPending = _outstanding > 0.01;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : CustomScrollView(
              slivers: [

                // ── Collapsing header ──────────────────────────────────
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: isPending ? const Color(0xFFB71C1C) : AppColors.primary,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: _CustomerHero(
                      customer: c,
                      outstanding: _outstanding,
                      totalCredit: _totalCredit,
                      totalPaid: _totalPaid,
                      isPending: isPending,
                    ),
                  ),
                ),

                // ── Content ────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([

                      // Collect payment button (prominent if pending)
                      if (isPending) ...[
                        _CollectButton(onTap: _showPaymentSheet),
                        const SizedBox(height: 20),
                      ],

                      // ── Transaction history ───────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Transaction History',
                            style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                          Text('${_credits.length} entries',
                            style: const TextStyle(
                              fontSize: 12.5, color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_credits.isEmpty)
                        _emptyHistory()
                      else
                        ..._credits.reversed.map((cr) => _TxRow(credit: cr)),

                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),

      // Floating collect payment FAB (only when pending)
      floatingActionButton: (!_loading && isPending)
          ? FloatingActionButton.extended(
              onPressed: _showPaymentSheet,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.currency_rupee_rounded, color: Colors.white),
              label: const Text('Collect Payment',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            )
          : null,
    );
  }

  Widget _emptyHistory() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 36, color: AppColors.border),
          SizedBox(height: 12),
          Text('No transactions yet',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}

// ─── Customer hero header ─────────────────────────────────────────────────────
class _CustomerHero extends StatelessWidget {
  final Customer customer;
  final double outstanding, totalCredit, totalPaid;
  final bool isPending;

  const _CustomerHero({
    required this.customer, required this.outstanding,
    required this.totalCredit, required this.totalPaid, required this.isPending,
  });

  @override
  Widget build(BuildContext context) {
    final headerColor = isPending ? const Color(0xFFB71C1C) : AppColors.primary;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [headerColor, isPending ? const Color(0xFFE53935) : AppColors.primaryLight],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 90, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomerAvatar(avatarIndex: customer.avatarIndex, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.name, style: const TextStyle(
                      color: Colors.white, fontSize: 20,
                      fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                    if (customer.phone.isNotEmpty)
                      Row(children: [
                        const Icon(Icons.phone_rounded, color: Colors.white60, size: 13),
                        const SizedBox(width: 4),
                        Text(customer.phone, style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                      ]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(children: [
            _HeroStat(
              label: 'Outstanding',
              value: AppFormat.currency(outstanding),
              highlight: isPending,
            ),
            const SizedBox(width: 1),
            _HeroStat(label: 'Total Credit', value: AppFormat.currency(totalCredit)),
            _HeroStat(label: 'Total Paid', value: AppFormat.currency(totalPaid)),
          ]),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label, value;
  final bool highlight;
  const _HeroStat({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(
            color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 3),
          Text(value, style: TextStyle(
            color: Colors.white,
            fontSize: highlight ? 20 : 15,
            fontWeight: FontWeight.w800,
          )),
        ],
      ),
    );
  }
}

// ─── Collect button card ──────────────────────────────────────────────────────
class _CollectButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CollectButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A6B3C), Color(0xFF2E9B5A)],
            begin: Alignment.centerLeft, end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: const Row(
          children: [
            Icon(Icons.currency_rupee_rounded, color: Colors.white, size: 28),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Collect Payment',
                    style: TextStyle(
                      color: Colors.white, fontSize: 16,
                      fontWeight: FontWeight.w700)),
                  Text('Tap to record payment received',
                    style: TextStyle(color: Colors.white70, fontSize: 12.5)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Transaction row ──────────────────────────────────────────────────────────
class _TxRow extends StatelessWidget {
  final Credit credit;
  const _TxRow({required this.credit});

  @override
  Widget build(BuildContext context) {
    final isDebit = credit.amount > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 6, offset: const Offset(0, 1))],
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: isDebit ? AppColors.dangerLight : AppColors.primaryLighter,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDebit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: isDebit ? AppColors.danger : AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isDebit ? 'Credit Given' : 'Payment Received',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14,
                    color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(AppFormat.dateTime(credit.date),
                  style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
                if (credit.note.isNotEmpty && credit.note != 'Credit Given'
                    && credit.note != 'Payment Received')
                  Text(credit.note, style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11,
                    fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          Text(
            isDebit
                ? '-${AppFormat.currency(credit.amount)}'
                : '+${AppFormat.currency(credit.amount.abs())}',
            style: TextStyle(
              color: isDebit ? AppColors.danger : AppColors.primary,
              fontWeight: FontWeight.w800, fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Payment bottom sheet ─────────────────────────────────────────────────────
class _PaymentSheet extends StatelessWidget {
  final double outstanding;
  final TextEditingController controller;
  final bool processing;
  final VoidCallback onCollect;

  const _PaymentSheet({
    required this.outstanding, required this.controller,
    required this.processing, required this.onCollect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Collect Payment',
                  style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('Outstanding: ${AppFormat.currency(outstanding)}',
                  style: const TextStyle(
                    color: AppColors.danger, fontWeight: FontWeight.w600,
                    fontSize: 14)),
                const SizedBox(height: 20),

                // Amount input
                TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary),
                    hintText: '0',
                    hintStyle: const TextStyle(
                      fontSize: 32, color: AppColors.border),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 14),

                // Quick amount chips
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [100, 200, 500, 1000]
                      .where((a) => a <= outstanding.ceil())
                      .map((a) => _QuickChip(
                          label: '₹$a',
                          onTap: () => controller.text = a.toString()))
                      .toList()
                    ..add(_QuickChip(
                        label: 'Full ${AppFormat.currency(outstanding)}',
                        onTap: () => controller.text =
                            outstanding.toStringAsFixed(0),
                        primary: true)),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: processing ? null : onCollect,
                    icon: processing
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check_circle_rounded, size: 20),
                    label: Text(processing ? 'Processing…' : 'Confirm Payment',
                      style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
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

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool primary;
  const _QuickChip({required this.label, required this.onTap, this.primary = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: primary ? AppColors.primaryLighter : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primary ? AppColors.primary : AppColors.border),
        ),
        child: Text(label, style: TextStyle(
          color: primary ? AppColors.primary : AppColors.textSecondary,
          fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }
}
