import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/cart/models/cart_item.dart';

class DatabaseHelper {
  static const _databaseName = "bazaarflow.db";
  static const _databaseVersion = 1;

  static const tableCart = 'cart_items';

  // Make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // this opens the database (and creates it if it doesn't exist)
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableCart (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id INTEGER NOT NULL UNIQUE,
            title TEXT NOT NULL,
            price REAL NOT NULL,
            image_url TEXT NOT NULL,
            quantity INTEGER NOT NULL DEFAULT 1
          )
          ''');
  }

  // --- CRUD Operations for Cart ---

  // Insert a cart item or update quantity if it exists
  Future<int> insertCartItem(CartItem item) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> existingItems = await db.query(
      tableCart,
      where: 'product_id = ?',
      whereArgs: [item.productId],
    );

    if (existingItems.isNotEmpty) {
      final existingItem = CartItem.fromMap(existingItems.first);
      final newQuantity = existingItem.quantity + item.quantity;
      return await db.update(
        tableCart,
        {'quantity': newQuantity},
        where: 'product_id = ?',
        whereArgs: [item.productId],
      );
    } else {
      return await db.insert(tableCart, item.toMap());
    }
  }

  // Get all cart items
  Future<List<CartItem>> getCartItems() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableCart);
    return List.generate(maps.length, (i) {
      return CartItem.fromMap(maps[i]);
    });
  }

  // Update a cart item (e.g., quantity change)
  Future<int> updateCartItem(CartItem item) async {
    Database db = await instance.database;
    return await db.update(
      tableCart,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Delete a cart item
  Future<int> deleteCartItem(int id) async {
    Database db = await instance.database;
    return await db.delete(
      tableCart,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Clear cart
  Future<int> clearCart() async {
    Database db = await instance.database;
    return await db.delete(tableCart);
  }
}
