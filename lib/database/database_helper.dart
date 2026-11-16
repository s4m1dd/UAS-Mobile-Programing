import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kasir.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createTransactionTables(db);
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
    CREATE TABLE users (
      id $idType,
      username $textType,
      password $textType,
      fullName $textType,
      email $textType,
      phone $textType,
      createdAt $textType
    )
    ''');

    await db.execute('''
    CREATE TABLE products (
      id $idType,
      name $textType,
      category $textType,
      price $realType,
      stock $intType,
      description TEXT,
      createdAt $textType,
      soldCount INTEGER DEFAULT 0
    )
    ''');

    await _createTransactionTables(db);
  }

  Future _createTransactionTables(Database db) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
    CREATE TABLE transactions (
      id $idType,
      transactionCode $textType,
      transactionDate $textType,
      totalAmount $realType,
      totalItems $intType,
      customerName TEXT,
      notes TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE transaction_items (
      id $idType,
      transactionId $intType,
      productId $intType,
      productName $textType,
      price $realType,
      quantity $intType,
      subtotal $realType,
      FOREIGN KEY (transactionId) REFERENCES transactions (id) ON DELETE CASCADE
    )
    ''');
  }

  // User CRUD
  Future<User?> createUser(User user) async {
    final db = await database;
    final id = await db.insert('users', user.toMap());
    return user.copyWith(id: id);
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> login(String username, String password) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Product CRUD
  Future<Product> createProduct(Product product) async {
    final db = await database;
    final id = await db.insert('products', product.toMap());
    return product.copyWith(id: id);
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final result = await db.query('products', orderBy: 'createdAt DESC');
    return result.map((map) => Product.fromMap(map)).toList();
  }

  Future<Product?> getProduct(int id) async {
    final db = await database;
    final maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;

    final totalProducts = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM products')) ??
        0;

    final totalStock = Sqflite.firstIntValue(
            await db.rawQuery('SELECT SUM(stock) FROM products')) ??
        0;

    final totalSold = Sqflite.firstIntValue(
            await db.rawQuery('SELECT SUM(soldCount) FROM products')) ??
        0;

    final totalRevenue = (await db.rawQuery(
                'SELECT SUM(price * soldCount) as revenue FROM products'))
            .first['revenue'] ??
        0.0;

    final categoryStats = await db.rawQuery('''
      SELECT category, COUNT(*) as count, SUM(stock) as totalStock
      FROM products
      GROUP BY category
    ''');

    return {
      'totalProducts': totalProducts,
      'totalStock': totalStock,
      'totalSold': totalSold,
      'totalRevenue': totalRevenue,
      'categoryStats': categoryStats,
    };
  }

  Future close() async {
    final db = await database;
    db.close();
  }

  // Transaction CRUD
  Future<Transaction> createTransaction(
    Transaction transaction,
    List<TransactionItem> items,
  ) async {
    final db = await database;

    return await db.transaction((txn) async {
      // Insert transaction
      final transactionId =
          await txn.insert('transactions', transaction.toMap());

      // Insert transaction items and update product stock
      for (var item in items) {
        await txn.insert(
          'transaction_items',
          item.copyWith(transactionId: transactionId).toMap(),
        );

        // Update product stock and sold count
        await txn.rawUpdate('''
          UPDATE products 
          SET stock = stock - ?, soldCount = soldCount + ?
          WHERE id = ?
        ''', [item.quantity, item.quantity, item.productId]);
      }

      return transaction.copyWith(id: transactionId);
    });
  }

  Future<List<Transaction>> getAllTransactions() async {
    final db = await database;
    final result = await db.query(
      'transactions',
      orderBy: 'transactionDate DESC',
    );
    return result.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<Transaction?> getTransaction(int id) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Transaction.fromMap(maps.first);
    }
    return null;
  }

  Future<List<TransactionItem>> getTransactionItems(int transactionId) async {
    final db = await database;
    final result = await db.query(
      'transaction_items',
      where: 'transactionId = ?',
      whereArgs: [transactionId],
    );
    return result.map((map) => TransactionItem.fromMap(map)).toList();
  }

  Future<Map<String, dynamic>> getTransactionStatistics() async {
    final db = await database;

    final totalTransactions = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM transactions')) ??
        0;

    final todayRevenue = (await db.rawQuery('''
      SELECT SUM(totalAmount) as revenue FROM transactions
      WHERE DATE(transactionDate) = DATE('now', 'localtime')
    ''')).first['revenue'] ?? 0.0;

    final monthlyRevenue = (await db.rawQuery('''
      SELECT SUM(totalAmount) as revenue FROM transactions
      WHERE strftime('%Y-%m', transactionDate) = strftime('%Y-%m', 'now', 'localtime')
    ''')).first['revenue'] ?? 0.0;

    return {
      'totalTransactions': totalTransactions,
      'todayRevenue': todayRevenue,
      'monthlyRevenue': monthlyRevenue,
    };
  }
}
