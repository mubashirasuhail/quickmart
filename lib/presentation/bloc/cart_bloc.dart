import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';


class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartState(cartItems: [])) {
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<UpdateCartItemQuantityEvent>(_onUpdateCartItemQuantity); // Added
  }

  void _onAddToCart(AddToCartEvent event, Emitter<CartState> emit) {
    final newItem = CartItem(
      productId: event.productId,
      productName: event.productName,
      productImage: event.productImage,
      productPrice: event.productPrice,
      quantity: 1, // Initialize quantity to 1
    );

    emit(CartState(cartItems: [...state.cartItems, newItem]));
  }

  void _onRemoveFromCart(RemoveFromCartEvent event, Emitter<CartState> emit) {
    final updatedCart = state.cartItems
        .where((item) => item.productId != event.productId)
        .toList();
    emit(CartState(cartItems: updatedCart));
  }

  void _onUpdateCartItemQuantity(
      UpdateCartItemQuantityEvent event, Emitter<CartState> emit) {
    final updatedCart = state.cartItems.map((item) {
      if (item.productId == event.productId) {
        return item.copyWith(quantity: event.quantity > 0 ? event.quantity : 1);
      }
      return item;
    }).toList();
    emit(CartState(cartItems: updatedCart));
  }
}