import 'package:flutter_test/flutter_test.dart';

import 'package:bazaarflow/features/cart/models/cart_item.dart';
import 'package:bazaarflow/features/cart/providers/cart_provider.dart';

import 'helpers/fake_cart_store.dart';

CartItem item(int productId, {double price = 10, int quantity = 1}) {
  return CartItem(
    productId: productId,
    title: 'Product $productId',
    price: price,
    imageUrl: 'https://example.com/$productId.png',
    quantity: quantity,
  );
}

void main() {
  late FakeCartStore store;
  late CartProvider cart;

  setUp(() async {
    store = FakeCartStore();
    cart = CartProvider(database: store);
    await cart.loadCart();
  });

  test('starts empty once loaded', () {
    expect(cart.isLoading, isFalse);
    expect(cart.isEmpty, isTrue);
    expect(cart.itemCount, 0);
    expect(cart.totalPrice, 0);
  });

  test('loads items already in the store', () async {
    await store.insertCartItem(item(1, quantity: 2));
    final reloaded = CartProvider(database: store);
    await reloaded.loadCart();

    expect(reloaded.items, hasLength(1));
    expect(reloaded.itemCount, 2);
  });

  test('adding the same product merges quantities', () async {
    await cart.addItem(item(1, price: 5, quantity: 2));
    await cart.addItem(item(1, price: 5, quantity: 3));
    await cart.addItem(item(2, price: 2.5));

    expect(cart.items, hasLength(2));
    expect(cart.itemCount, 6);
    expect(cart.totalPrice, 27.5);
  });

  test('updateQuantity changes the item and persists it', () async {
    await cart.addItem(item(1));
    await cart.updateQuantity(cart.items.first, 4);

    expect(cart.itemCount, 4);
    expect(store.items.first.quantity, 4);
  });

  test('updateQuantity to zero removes the item', () async {
    await cart.addItem(item(1));
    await cart.updateQuantity(cart.items.first, 0);

    expect(cart.isEmpty, isTrue);
    expect(store.items, isEmpty);
  });

  test('removeItem updates listeners before the store write finishes', () async {
    await cart.addItem(item(1));
    await cart.addItem(item(2));
    var notified = false;
    cart.addListener(() => notified = true);

    final pending = cart.removeItem(cart.items.first.id!);
    expect(notified, isTrue);
    expect(cart.items, hasLength(1));
    await pending;
    expect(store.items, hasLength(1));
  });

  test('clear empties the cart and the store', () async {
    await cart.addItem(item(1));
    await cart.addItem(item(2));
    await cart.clear();

    expect(cart.isEmpty, isTrue);
    expect(store.items, isEmpty);
  });
}
