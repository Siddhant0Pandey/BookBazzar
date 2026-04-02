// lib/screens/main_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_constants.dart';
import 'dashboard/dashboard_screen.dart';
import 'products/inventory_screen.dart';
import 'customers/customers_screen.dart';
import 'summary/summary_screen.dart';
import 'sales/sale_screen.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _tab; // 0=Home 1=Inventory 2=Customers 3=Reports

  static const _pages = [
    DashboardScreen(),
    InventoryScreen(),
    CustomersScreen(),
    SummaryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tab = widget.initialIndex;
  }

  void _openSale() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SaleScreen()),
    ).then((_) => context.read<AppProvider>().loadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: IndexedStack(index: _tab, children: _pages),

        // ── Centre FAB (Add Sale) ────────────────────────────────────
        floatingActionButton: FloatingActionButton(
          onPressed: _openSale,
          backgroundColor: AppColors.primary,
          elevation: 6,
          shape: const CircleBorder(),
          tooltip: 'Add Sale',
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked,

        // ── Bottom App Bar ───────────────────────────────────────────
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          elevation: 16,
          shadowColor: Colors.black26,
          color: Colors.white,
          child: SizedBox(
            height: 62,
            child: Row(
              children: [
                _NavBtn(icon: Icons.home_rounded,       label: 'Home',      tab: 0, current: _tab, onTap: (t) => setState(() => _tab = t)),
                _NavBtn(icon: Icons.layers_rounded,     label: 'Inventory', tab: 1, current: _tab, onTap: (t) => setState(() => _tab = t)),
                const Expanded(child: SizedBox()), // FAB space
                _NavBtn(icon: Icons.people_alt_rounded, label: 'Customers', tab: 2, current: _tab, onTap: (t) => setState(() => _tab = t)),
                _NavBtn(icon: Icons.bar_chart_rounded,  label: 'Reports',   tab: 3, current: _tab, onTap: (t) => setState(() => _tab = t)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final int tab;
  final int current;
  final ValueChanged<int> onTap;

  const _NavBtn({
    required this.icon, required this.label,
    required this.tab, required this.current, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = tab == current;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(tab),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                color: selected ? AppColors.primary : const Color(0xFFADB5BD),
                size: 22),
            ),
            const SizedBox(height: 2),
            Text(label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? AppColors.primary : const Color(0xFFADB5BD),
              )),
          ],
        ),
      ),
    );
  }
}
