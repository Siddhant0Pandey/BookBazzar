// lib/screens/dashboard/dashboard_screen.dart
// Home tab — Today's live report + quick insights
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common_widgets.dart';
import '../../models/models.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _todaySummary;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await context.read<AppProvider>().loadDashboard();
    if (mounted) {
      final data = await context
          .read<AppProvider>()
          .getDailySummary(DateTime.now());
      setState(() => _todaySummary = data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final sales = (_todaySummary?['sales'] as List<Sale>?) ?? [];
    final totalSales  = _todaySummary?['totalSales']  as double? ?? provider.todaysSales;
    final cashReceived= _todaySummary?['cashReceived'] as double? ?? provider.cashReceived;
    final creditGiven = _todaySummary?['creditGiven']  as double? ?? provider.creditGiven;
    final txCount     = _todaySummary?['transactionCount'] as int? ?? provider.todaysTransactions;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [

              // ── Green header ────────────────────────────────────────
              SliverToBoxAdapter(
                child: _DashHeader(provider: provider),
              ),

              // ── "Add Sale" hero CTA ─────────────────────────────────
              SliverToBoxAdapter(
                child: _HeroCTA(onTap: () {
                  Navigator.pushNamed(context, '/sale')
                      .then((_) => _load());
                }),
              ),

              // ── Alert banners ───────────────────────────────────────
              SliverToBoxAdapter(
                child: _PendingCreditsBanner(
                  provider: provider,
                  onTap: () {},
                ),
              ),
              SliverToBoxAdapter(
                child: _LowStockBanner(
                  provider: provider,
                  onTap: () {},
                ),
              ),

              // ── Today's stats 2×2 grid ──────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                sliver: SliverGrid(
                  delegate: SliverChildListDelegate([
                    _MiniStatCard(
                      label: "Today's Revenue",
                      value: AppFormat.currency(totalSales),
                      icon: Icons.trending_up_rounded,
                      iconColor: const Color(0xFF1A6B3C),
                      bgColor: const Color(0xFFE6F4EC),
                      sub: '$txCount sales',
                    ),
                    _MiniStatCard(
                      label: 'Cash In Hand',
                      value: AppFormat.currency(cashReceived),
                      icon: Icons.currency_rupee_rounded,
                      iconColor: const Color(0xFF1565C0),
                      bgColor: const Color(0xFFE3F2FD),
                      sub: 'Collected today',
                    ),
                    _MiniStatCard(
                      label: 'Credit Pending',
                      value: AppFormat.currency(creditGiven),
                      icon: Icons.receipt_long_rounded,
                      iconColor: const Color(0xFFE07B00),
                      bgColor: const Color(0xFFFFF7E6),
                      sub: provider.creditCustomerCount > 0
                          ? '${provider.creditCustomerCount} customers'
                          : 'None today',
                    ),
                    _MiniStatCard(
                      label: 'Low Stock Items',
                      value: '${provider.lowStockCount}',
                      icon: Icons.warning_amber_rounded,
                      iconColor: provider.lowStockCount > 0
                          ? const Color(0xFFE03E3E)
                          : const Color(0xFF1A6B3C),
                      bgColor: provider.lowStockCount > 0
                          ? const Color(0xFFFFF0F0)
                          : const Color(0xFFE6F4EC),
                      sub: provider.lowStockCount > 0
                          ? 'Needs restocking'
                          : 'All good!',
                    ),
                  ]),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── Today's sales list ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Today's Sales",
                        style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary, letterSpacing: -0.2,
                        )),
                      if (sales.isNotEmpty)
                        Text('${sales.length} transaction${sales.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 12.5, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              if (sales.isEmpty)
                SliverToBoxAdapter(
                  child: _EmptySalesCard(onAddSale: () =>
                    Navigator.pushNamed(context, '/sale').then((_) => _load())),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _SaleRow(sale: sales[i]),
                      childCount: sales.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Green header ─────────────────────────────────────────────────────────────
class _DashHeader extends StatelessWidget {
  final AppProvider provider;
  const _DashHeader({required this.provider});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: const TextStyle(
                    color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 3),
                Text(
                  provider.ownerName,
                  style: const TextStyle(
                    color: Colors.white, fontSize: 22,
                    fontWeight: FontWeight.w800, letterSpacing: -0.3),
                ),
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.storefront_rounded,
                      color: Colors.white54, size: 13),
                  const SizedBox(width: 4),
                  Text(provider.shopName,
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  const Spacer(),
                  const Icon(Icons.calendar_today_rounded,
                      color: Colors.white54, size: 12),
                  const SizedBox(width: 4),
                  Text(dateStr,
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SettingsScreen())),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.settings_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}

// ─── Hero CTA ─────────────────────────────────────────────────────────────────
class _HeroCTA extends StatelessWidget {
  final VoidCallback onTap;
  const _HeroCTA({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A6B3C), Color(0xFF2E9B5A)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A6B3C).withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.add_shopping_cart_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Record a Sale',
                      style: TextStyle(
                        color: Colors.white, fontSize: 17,
                        fontWeight: FontWeight.w700)),
                    SizedBox(height: 2),
                    Text('Tap to add a new transaction',
                      style: TextStyle(
                        color: Colors.white70, fontSize: 12.5)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white70, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Mini stat card ───────────────────────────────────────────────────────────
class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _MiniStatCard({
    required this.label, required this.value, required this.sub,
    required this.icon, required this.iconColor, required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.w800,
            color: AppColors.textPrimary, letterSpacing: -0.5,
          )),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(
            fontSize: 11, color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          )),
          Text(sub, style: TextStyle(
            fontSize: 10.5, color: iconColor,
            fontWeight: FontWeight.w600,
          )),
        ],
      ),
    );
  }
}

// ─── Empty sales card ─────────────────────────────────────────────────────────
class _EmptySalesCard extends StatelessWidget {
  final VoidCallback onAddSale;
  const _EmptySalesCard({required this.onAddSale});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(Icons.receipt_long_outlined,
                size: 40, color: AppColors.border),
            const SizedBox(height: 12),
            const Text('No sales recorded today',
              style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 15,
                color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text('Start by tapping "Record a Sale" above',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ─── Sale row ─────────────────────────────────────────────────────────────────
class _SaleRow extends StatelessWidget {
  final Sale sale;
  const _SaleRow({required this.sale});

  @override
  Widget build(BuildContext context) {
    final time = '${sale.date.hour % 12 == 0 ? 12 : sale.date.hour % 12}'
        ':${sale.date.minute.toString().padLeft(2, '0')}'
        ' ${sale.date.hour >= 12 ? 'PM' : 'AM'}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 6, offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: sale.isCredit
                  ? AppColors.warningLight
                  : AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              sale.isCredit
                  ? Icons.receipt_long_rounded
                  : Icons.shopping_cart_rounded,
              color: sale.isCredit ? AppColors.warning : AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sale.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14,
                    color: AppColors.textPrimary),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('Qty: ${sale.quantity}  •  $time',
                  style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(AppFormat.currency(sale.totalPrice),
                style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15,
                  color: AppColors.textPrimary)),
              Container(
                margin: const EdgeInsets.only(top: 3),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: sale.isCredit
                      ? AppColors.warningLight
                      : AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(sale.isCredit ? 'Credit' : 'Cash',
                  style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    color: sale.isCredit ? AppColors.warning : AppColors.primary,
                  )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Pending credits summary widget (added to dashboard) ─────────────────────
// Called from dashboard as a sliver child
class _PendingCreditsBanner extends StatelessWidget {
  final AppProvider provider;
  final VoidCallback onTap;
  const _PendingCreditsBanner({required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pending = provider.customerSummaries
        .where((s) => s.outstanding > 0.01).toList();
    if (pending.isEmpty) return const SizedBox.shrink();

    final totalPending = pending.fold(0.0, (s, c) => s + c.outstanding);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warningLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.warning.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: AppColors.warning, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${pending.length} customer${pending.length > 1 ? 's' : ''} owe you money',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13.5,
                      color: AppColors.warning)),
                  Text('Total pending: ${AppFormat.currency(totalPending)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12.5)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.warning, size: 20),
          ],
        ),
      ),
    );
  }
}

class _LowStockBanner extends StatelessWidget {
  final AppProvider provider;
  final VoidCallback onTap;
  const _LowStockBanner({required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (provider.lowStockCount == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.dangerLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.danger.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.inventory_2_outlined,
                  color: AppColors.danger, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('${provider.lowStockCount} item${provider.lowStockCount > 1 ? 's' : ''} running low on stock',
                style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13.5,
                  color: AppColors.danger)),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.danger, size: 20),
          ],
        ),
      ),
    );
  }
}
