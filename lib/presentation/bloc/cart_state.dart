
class CartState {
  final List<CartItem> cartItems;

  CartState({required this.cartItems});
}

class CartItem {
  final String productId;
  final String productName;
  final String productImage;
  final double productPrice;
  final int quantity; // Added

  CartItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.quantity, // Added
  });

  CartItem copyWith({int? quantity}) { //Added
    return CartItem(
      productId: productId,
      productName: productName,
      productImage: productImage,
      productPrice: productPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}