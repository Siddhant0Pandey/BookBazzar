// lib/services/sale_service.dart
// All database operations for sales.
// Implements Daily Sales Aggregation Algorithm.

import '../database/database_helper.dart';
import '../models/models.dart';
import 'product_service.dart';

class SaleService {
  final DatabaseHelper _db = DatabaseHelper();
  final ProductService _productService = ProductService();

  // ─── Record a Sale ──────────────────────────────────────────────
  // This is the core sale recording flow:
  // 1. Check stock
  // 2. Deduct stock (Stock Update Algorithm)
  // 3. Save sale record
  // Returns sale ID or throws exception

  Future<int> recordSale({
    required int productId,
    required String productName,
    required int quantity,
    required double totalPrice,
    required bool isCredit,
  }) async {
    // Step 1 & 2: Deduct stock (also checks availability)
    final success = await _productService.deductStock(productId, quantity);
    if (!success) {
      throw Exception('Insufficient stock for $productName');
    }

    // Step 3: Save the sale record
    final db = await _db.database;
    final sale = Sale(
      productId: productId,
      productName: productName,
      quantity: quantity,
      totalPrice: totalPrice,
      date: DateTime.now(),
      isCredit: isCredit,
    );
    return await db.insert(DatabaseHelper.tableSales, sale.toMap());
  }

  // ─── Daily Sales Aggregation Algorithm ─────────────────────────
  // Sums up all sales for a given date from local database

  Future<Map<String, dynamic>> getDailySummary(DateTime date) async {
    final db = await _db.database;

    // Get start and end of the given day
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final rows = await db.query(
      DatabaseHelper.tableSales,
      where: 'date >= ? AND date < ?',
      whereArgs: [
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
      ],
      orderBy: 'date DESC',
    );

    final sales = rows.map((r) => Sale.fromMap(r)).toList();

    // Aggregate values
    double totalSales = 0;
    double cashReceived = 0;
    double creditGiven = 0;
    int creditCustomerCount = 0;

    for (final sale in sales) {
      totalSales += sale.totalPrice;
      if (sale.isCredit) {
        creditGiven += sale.totalPrice;
        creditCustomerCount++;
      } else {
        cashReceived += sale.totalPrice;
      }
    }

    return {
      'sales': sales,
      'totalSales': totalSales,
      'cashReceived': cashReceived,
      'creditGiven': creditGiven,
      'transactionCount': sales.length,
      'creditCustomerCount': creditCustomerCount,
    };
  }

  /// Get all sales for a specific product
  Future<List<Sale>> getSalesByProduct(int productId) async {
    final db = await _db.database;
    final rows = await db.query(
      DatabaseHelper.tableSales,
      where: 'productId = ?',
      whereArgs: [productId],
      orderBy: 'date DESC',
    );
    return rows.map((r) => Sale.fromMap(r)).toList();
  }
}

