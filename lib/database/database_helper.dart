// lib/database/database_helper.dart
// SQLite database setup. No seed data — app starts empty on first install.

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  static const String _dbName = 'bookbaazar.db';
  static const int _dbVersion = 2; // bumped to add imageEmoji column

  static const String tableProducts  = 'products';
  static const String tableSales     = 'sales';
  static const String tableCustomers = 'customers';
  static const String tableCredits   = 'credits';

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add imageEmoji column if upgrading from v1
      try {
        await db.execute(
          "ALTER TABLE $tableProducts ADD COLUMN imageEmoji TEXT DEFAULT ''");
      } catch (_) {}
    }
  }

  Future<void> _createTables(Database db, int version) async {
    // Products — includes imageEmoji for visual product icon
    await db.execute('''
      CREATE TABLE $tableProducts (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        name              TEXT    NOT NULL,
        category          TEXT    NOT NULL,
        costPrice         REAL    NOT NULL,
        sellingPrice      REAL    NOT NULL,
        quantity          INTEGER NOT NULL DEFAULT 0,
        lowStockThreshold INTEGER NOT NULL DEFAULT 10,
        imageEmoji        TEXT    DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableSales (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        productId   INTEGER NOT NULL,
        productName TEXT    NOT NULL,
        quantity    INTEGER NOT NULL,
        totalPrice  REAL    NOT NULL,
        date        TEXT    NOT NULL,
        isCredit    INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (productId) REFERENCES $tableProducts(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableCustomers (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        name        TEXT NOT NULL,
        phone       TEXT NOT NULL,
        address     TEXT DEFAULT '',
        avatarIndex INTEGER DEFAULT 0,
        createdAt   TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableCredits (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        customerId INTEGER NOT NULL,
        saleId     INTEGER,
        amount     REAL    NOT NULL,
        isPaid     INTEGER NOT NULL DEFAULT 0,
        date       TEXT    NOT NULL,
        note       TEXT    DEFAULT '',
        FOREIGN KEY (customerId) REFERENCES $tableCustomers(id),
        FOREIGN KEY (saleId)     REFERENCES $tableSales(id)
      )
    ''');
    // No seed data — app starts with a clean slate on first install
  }

  /// Wipe all data (used in Settings → Reset)
  Future<void> resetDatabase() async {
    final db = await database;
    await db.delete(tableCredits);
    await db.delete(tableSales);
    await db.delete(tableCustomers);
    await db.delete(tableProducts);
    _database = null;
  }
}
