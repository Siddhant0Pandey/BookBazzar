// lib/services/customer_service.dart
import '../database/database_helper.dart';
import '../models/models.dart';

class CustomerService {
  final DatabaseHelper _db = DatabaseHelper();

  Future<List<Customer>> getAllCustomers() async {
    final db = await _db.database;
    final rows = await db.query(
      DatabaseHelper.tableCustomers,
      orderBy: 'name ASC',
    );
    return rows.map((r) => Customer.fromMap(r)).toList();
  }

  Future<Customer?> getCustomerById(int id) async {
    final db = await _db.database;
    final rows = await db.query(
      DatabaseHelper.tableCustomers,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Customer.fromMap(rows.first);
  }

  Future<int> addCustomer(Customer customer) async {
    final db = await _db.database;
    return await db.insert(DatabaseHelper.tableCustomers, customer.toMap());
  }

  Future<void> updateCustomer(Customer customer) async {
    final db = await _db.database;
    await db.update(
      DatabaseHelper.tableCustomers,
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> getCustomerCount() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableCustomers}',
    );
    return result.first['count'] as int;
  }
}
