// lib/services/credit_service.dart
// All database operations for customer credits.
// Implements Credit Balance Algorithm.

import '../database/database_helper.dart';
import '../models/models.dart';

class CreditService {
  final DatabaseHelper _db = DatabaseHelper();

  // ─── Add a credit entry ─────────────────────────────────────────

  Future<void> addCredit({
    required int customerId,
    int? saleId,
    required double amount, // Positive = debt, Negative = payment
    required String note,
  }) async {
    final db = await _db.database;
    final credit = Credit(
      customerId: customerId,
      saleId: saleId,
      amount: amount,
      date: DateTime.now(),
      note: note,
    );
    await db.insert(DatabaseHelper.tableCredits, credit.toMap());
  }

  // ─── Credit Balance Algorithm ───────────────────────────────────
  // balance = sum of all credits (positive=debt, negative=payment)
  // Running balance per customer

  Future<double> getCustomerBalance(int customerId) async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as balance
      FROM ${DatabaseHelper.tableCredits}
      WHERE customerId = ?
    ''', [customerId]);
    return (result.first['balance'] as num).toDouble();
  }

  /// Get all credit entries for a customer, most recent first
  Future<List<Credit>> getCustomerCredits(int customerId) async {
    final db = await _db.database;
    final rows = await db.query(
      DatabaseHelper.tableCredits,
      where: 'customerId = ?',
      whereArgs: [customerId],
      orderBy: 'date DESC',
    );
    return rows.map((r) => Credit.fromMap(r)).toList();
  }

  /// Record a payment (reduces customer's balance)
  Future<void> recordPayment(int customerId, double amount) async {
    await addCredit(
      customerId: customerId,
      amount: -amount, // Negative = payment reduces debt
      note: 'Payment Received',
    );
  }

  /// Get summary for all customers with credit activity
  Future<List<CustomerSummary>> getAllCustomerSummaries() async {
    final db = await _db.database;

    // Get all customers
    final customerRows = await db.query(
      DatabaseHelper.tableCustomers,
      orderBy: 'name ASC',
    );

    final summaries = <CustomerSummary>[];

    for (final row in customerRows) {
      final customer = Customer.fromMap(row);

      // Aggregate credit data per customer
      final creditResult = await db.rawQuery('''
        SELECT
          COALESCE(SUM(CASE WHEN amount > 0 THEN amount ELSE 0 END), 0) as totalCredit,
          COALESCE(SUM(CASE WHEN amount < 0 THEN ABS(amount) ELSE 0 END), 0) as totalPaid,
          MAX(date) as lastActivity
        FROM ${DatabaseHelper.tableCredits}
        WHERE customerId = ?
      ''', [customer.id]);

      final data = creditResult.first;
      final lastActivityStr = data['lastActivity'] as String?;

      summaries.add(CustomerSummary(
        customer: customer,
        totalCredit: (data['totalCredit'] as num).toDouble(),
        totalPaid: (data['totalPaid'] as num).toDouble(),
        lastActivityDate: lastActivityStr != null
            ? DateTime.tryParse(lastActivityStr)
            : null,
      ));
    }

    return summaries;
  }

  /// Total outstanding credit across all customers
  Future<double> getTotalOutstandingCredit() async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM ${DatabaseHelper.tableCredits}
    ''');
    final total = (result.first['total'] as num).toDouble();
    return total < 0 ? 0 : total;
  }

  /// Count customers with pending balances
  Future<int> getPendingCustomerCount() async {
    final summaries = await getAllCustomerSummaries();
    return summaries.where((s) => s.outstanding > 0).length;
  }
}

