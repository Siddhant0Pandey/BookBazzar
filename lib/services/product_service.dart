// lib/services/product_service.dart
// All database operations for products.
// Implements Stock Update Algorithm and Low Stock Detection.

import '../database/database_helper.dart';
import '../models/product_model.dart';

class ProductService {
  final DatabaseHelper _db = DatabaseHelper();

  // ─── CRUD Operations ───────────────────────────────────────────

  /// Get all products sorted by name
  Future<List<Product>> getAllProducts() async {
    final db = await _db.database;
    final rows = await db.query(
      DatabaseHelper.tableProducts,
      orderBy: 'name ASC',
    );
    return rows.map((row) => Product.fromMap(row)).toList();
  }

  /// Get a single product by ID
  Future<Product?> getProductById(int id) async {
    final db = await _db.database;
    final rows = await db.query(
      DatabaseHelper.tableProducts,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Product.fromMap(rows.first);
  }

  /// Insert a new product, returns its new ID
  Future<int> addProduct(Product product) async {
    final db = await _db.database;
    return await db.insert(DatabaseHelper.tableProducts, product.toMap());
  }

  /// Update an existing product
  Future<void> updateProduct(Product product) async {
    final db = await _db.database;
    await db.update(
      DatabaseHelper.tableProducts,
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  /// Delete a product by ID
  Future<void> deleteProduct(int id) async {
    final db = await _db.database;
    await db.delete(
      DatabaseHelper.tableProducts,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── Stock Update Algorithm ─────────────────────────────────────
  // When a sale is made:
  // 1. Check if stock is sufficient
  // 2. Deduct quantity sold
  // 3. Save to database
  // Returns true if successful, false if not enough stock

  Future<bool> deductStock(int productId, int quantitySold) async {
    final product = await getProductById(productId);
    if (product == null) return false;

    // Step 1: Check sufficient stock (FIFO logic — sell oldest first conceptually)
    if (product.quantity < quantitySold) {
      return false; // Insufficient stock
    }

    // Step 2: Deduct quantity
    final newQty = product.quantity - quantitySold;
    final updated = product.copyWith(quantity: newQty);

    // Step 3: Save
    await updateProduct(updated);
    return true;
  }

  // ─── Low Stock Detection Algorithm ─────────────────────────────
  // Returns products where quantity <= lowStockThreshold

  Future<List<Product>> getLowStockProducts() async {
    final db = await _db.database;
    // Raw query for performance: quantity > 0 AND quantity <= threshold
    final rows = await db.rawQuery('''
      SELECT * FROM ${DatabaseHelper.tableProducts}
      WHERE quantity > 0 AND quantity <= lowStockThreshold
      ORDER BY quantity ASC
    ''');
    return rows.map((row) => Product.fromMap(row)).toList();
  }

  /// Get out-of-stock products
  Future<List<Product>> getOutOfStockProducts() async {
    final db = await _db.database;
    final rows = await db.query(
      DatabaseHelper.tableProducts,
      where: 'quantity <= 0',
      orderBy: 'name ASC',
    );
    return rows.map((row) => Product.fromMap(row)).toList();
  }

  /// Count total products
  Future<int> getProductCount() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableProducts}',
    );
    return result.first['count'] as int;
  }

  /// Count how many products are low in stock
  Future<int> getLowStockCount() async {
    final items = await getLowStockProducts();
    return items.length;
  }
}
