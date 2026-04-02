// lib/providers/app_provider.dart
// Single Provider that holds app-wide state.
// Uses ChangeNotifier to rebuild widgets when data changes.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../models/models.dart';
import '../services/product_service.dart';
import '../services/sale_service.dart';
import '../services/credit_service.dart';
import '../services/customer_service.dart';

class AppProvider extends ChangeNotifier {
  // Services
  final ProductService _productService = ProductService();
  final SaleService _saleService = SaleService();
  final CreditService _creditService = CreditService();
  final CustomerService _customerService = CustomerService();

  // ─── State ──────────────────────────────────────────────────────

  // User profile (saved in SharedPreferences)
  String ownerName = '';
  String shopName = '';
  bool isRegistered = false;

  // Language: 'en' or 'ne'
  String language = 'en';

  // Dashboard stats
  int totalProducts = 0;
  int lowStockCount = 0;
  double todaysSales = 0;
  int todaysTransactions = 0;
  double cashReceived = 0;
  double creditGiven = 0;
  int creditCustomerCount = 0;

  // Products
  List<Product> products = [];
  List<Product> filteredProducts = [];

  // Customers
  List<CustomerSummary> customerSummaries = [];

  // Loading state
  bool isLoading = false;

  // ─── Initialization ─────────────────────────────────────────────

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    ownerName = prefs.getString('ownerName') ?? '';
    shopName = prefs.getString('shopName') ?? '';
    isRegistered = ownerName.isNotEmpty && shopName.isNotEmpty;
    language = prefs.getString('language') ?? 'en';
    notifyListeners();

    if (isRegistered) {
      await loadDashboard();
    }
  }

  // ─── Registration ────────────────────────────────────────────────

  Future<void> register(String name, String shop, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ownerName', name);
    await prefs.setString('shopName', shop);
    ownerName = name;
    shopName = shop;
    isRegistered = true;
    notifyListeners();
    await loadDashboard();
  }

  // ─── Language ────────────────────────────────────────────────────

  Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    language = lang;
    notifyListeners();
  }

  Locale get locale => Locale(language);

  // ─── Dashboard ───────────────────────────────────────────────────

  Future<void> loadDashboard() async {
    isLoading = true;
    notifyListeners();

    try {
      // Load products
      products = await _productService.getAllProducts();
      filteredProducts = List.from(products);
      totalProducts = products.length;
      lowStockCount = products.where((p) => p.isLowStock).length;

      // Load today's sales summary
      final summary = await _saleService.getDailySummary(DateTime.now());
      todaysSales = summary['totalSales'] as double;
      todaysTransactions = summary['transactionCount'] as int;
      cashReceived = summary['cashReceived'] as double;
      creditGiven = summary['creditGiven'] as double;
      creditCustomerCount = summary['creditCustomerCount'] as int;

      // Load customer summaries
      customerSummaries = await _creditService.getAllCustomerSummaries();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── Product Operations ──────────────────────────────────────────

  Future<void> loadProducts() async {
    products = await _productService.getAllProducts();
    filteredProducts = List.from(products);
    totalProducts = products.length;
    lowStockCount = products.where((p) => p.isLowStock).length;
    notifyListeners();
  }

  void filterProducts(String query, String filter) {
    List<Product> base = List.from(products);

    // Apply search query
    if (query.isNotEmpty) {
      base = base.where((p) =>
        p.name.toLowerCase().contains(query.toLowerCase()) ||
        p.category.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }

    // Apply stock filter
    switch (filter) {
      case 'low':
        base = base.where((p) => p.isLowStock).toList();
        break;
      case 'out':
        base = base.where((p) => p.isOutOfStock).toList();
        break;
    }

    filteredProducts = base;
    notifyListeners();
  }

  Future<void> saveProduct(Product product) async {
    if (product.id == null) {
      await _productService.addProduct(product);
    } else {
      await _productService.updateProduct(product);
    }
    await loadProducts();
  }

  Future<void> deleteProduct(int id) async {
    await _productService.deleteProduct(id);
    await loadProducts();
  }

  // ─── Sale Operations ─────────────────────────────────────────────

  Future<void> recordSale({
    required Product product,
    required int quantity,
    required bool isCredit,
    int? customerId,
  }) async {
    final totalPrice = product.sellingPrice * quantity;

    final saleId = await _saleService.recordSale(
      productId: product.id!,
      productName: product.name,
      quantity: quantity,
      totalPrice: totalPrice,
      isCredit: isCredit,
    );

    // If credit sale, record in credits table
    if (isCredit && customerId != null) {
      await _creditService.addCredit(
        customerId: customerId,
        saleId: saleId,
        amount: totalPrice,
        note: 'Credit Given',
      );
    }

    // Refresh all data
    await loadDashboard();
  }

  // ─── Customer Operations ─────────────────────────────────────────

  Future<void> loadCustomers() async {
    customerSummaries = await _creditService.getAllCustomerSummaries();
    notifyListeners();
  }

  Future<void> addCustomer(Customer customer) async {
    await _customerService.addCustomer(customer);
    await loadCustomers();
  }

  Future<List<Credit>> getCustomerCredits(int customerId) async {
    return await _creditService.getCustomerCredits(customerId);
  }

  Future<void> collectPayment(int customerId, double amount) async {
    await _creditService.recordPayment(customerId, amount);
    await loadCustomers();
  }

  // ─── Daily Summary ────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDailySummary(DateTime date) async {
    return await _saleService.getDailySummary(date);
  }

  // ─── Reset ────────────────────────────────────────────────────────


  // ─── Logout (keep data, just clear registration) ──────────────────

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ownerName');
    await prefs.remove('shopName');
    ownerName = '';
    shopName = '';
    isRegistered = false;
    products = [];
    filteredProducts = [];
    customerSummaries = [];
    notifyListeners();
  }

  Future<void> resetAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Reset in-memory state
    ownerName = '';
    shopName = '';
    isRegistered = false;
    products = [];
    filteredProducts = [];
    customerSummaries = [];
    notifyListeners();
  }
}
