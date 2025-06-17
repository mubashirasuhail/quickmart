abstract class CartEvent {}

class AddToCartEvent extends CartEvent {
  final String productId;
  final String productName;
  final String productImage;
  final double productPrice;

  AddToCartEvent({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.productPrice,
  });
}

class RemoveFromCartEvent extends CartEvent {
  final String productId;

  RemoveFromCartEvent(this.productId);
}

class UpdateCartItemQuantityEvent extends CartEvent { //Added
  final String productId;
  final int quantity;

  UpdateCartItemQuantityEvent(this.productId, this.quantity);
}
class ClearCartEvent extends CartEvent {}
