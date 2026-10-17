import 'package:flutter/foundation.dart';
import '../../../core/database/database_helper.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final DatabaseHelper _db;

  List<CartItem> _items = [];
  bool _isLoading = true;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get isEmpty => _items.isEmpty;

  // Total number of units, used for the cart badge
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  CartProvider({DatabaseHelper? database}) : _db = database ?? DatabaseHelper.instance {
    loadCart();
  }

  Future<void> loadCart() async {
    _items = await _db.getCartItems();
    _isLoading = false;
    notifyListeners();
  }

  // Adds the item, merging quantities if the product is already in the cart
  Future<void> addItem(CartItem item) async {
    await _db.insertCartItem(item);
    await loadCart();
  }

  Future<void> updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeItem(item.id!);
      return;
    }
    final updatedItem = item.copyWith(quantity: newQuantity);
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      _items[index] = updatedItem;
      notifyListeners();
    }
    await _db.updateCartItem(updatedItem);
  }

  // Removes locally before persisting so a Dismissible leaves the tree immediately
  Future<void> removeItem(int id) async {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
    await _db.deleteCartItem(id);
  }

  Future<void> clear() async {
    _items = [];
    notifyListeners();
    await _db.clearCart();
  }
}
