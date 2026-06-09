class CartItem {
  final int? id; // local id
  final int productId;
  final String title;
  final double price;
  final String imageUrl;
  final int quantity;

  CartItem({
    this.id,
    required this.productId,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'title': title,
      'price': price,
      'image_url': imageUrl,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      title: map['title'] as String,
      price: map['price'] as double,
      imageUrl: map['image_url'] as String,
      quantity: map['quantity'] as int,
    );
  }

  CartItem copyWith({
    int? id,
    int? productId,
    String? title,
    double? price,
    String? imageUrl,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      title: title ?? this.title,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }
}
