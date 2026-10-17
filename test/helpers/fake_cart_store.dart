import 'package:bazaarflow/core/database/database_helper.dart';
import 'package:bazaarflow/features/cart/models/cart_item.dart';

/// In-memory stand-in for [DatabaseHelper] so cart logic can run without sqflite.
class FakeCartStore implements DatabaseHelper {
  final List<CartItem> items = [];
  int _nextId = 1;

  @override
  Future<int> insertCartItem(CartItem item) async {
    final index = items.indexWhere((e) => e.productId == item.productId);
    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + item.quantity);
    } else {
      items.add(item.copyWith(id: _nextId++));
    }
    return 1;
  }

  @override
  Future<List<CartItem>> getCartItems() async => List.from(items);

  @override
  Future<int> updateCartItem(CartItem item) async {
    final index = items.indexWhere((e) => e.id == item.id);
    if (index >= 0) items[index] = item;
    return 1;
  }

  @override
  Future<int> deleteCartItem(int id) async {
    items.removeWhere((e) => e.id == id);
    return 1;
  }

  @override
  Future<int> clearCart() async {
    items.clear();
    return 1;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
