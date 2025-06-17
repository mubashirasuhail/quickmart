import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';


class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartState(cartItems: [])) {
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<UpdateCartItemQuantityEvent>(_onUpdateCartItemQuantity);
  on<ClearCartEvent>(_onClearCart); // NEW: Register the ClearCartEvent
  }

  void _onAddToCart(AddToCartEvent event, Emitter<CartState> emit) {
    final newItem = CartItem(
      productId: event.productId,
      productName: event.productName,
      productImage: event.productImage,
      productPrice: event.productPrice,
      quantity: 1, // Initialize quantity to 1
    );

    // Check if item already exists to update quantity instead of adding duplicate
    final existingItemIndex = state.cartItems.indexWhere((item) => item.productId == event.productId);

    if (existingItemIndex != -1) {
      final updatedCartItems = List<CartItem>.from(state.cartItems);
      final existingItem = updatedCartItems[existingItemIndex];
      updatedCartItems[existingItemIndex] = existingItem.copyWith(quantity: existingItem.quantity + 1);
      emit(CartState(cartItems: updatedCartItems));
    } else {
      emit(CartState(cartItems: [...state.cartItems, newItem]));
    }
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
        // Ensure quantity doesn't go below 1
        return item.copyWith(quantity: event.quantity > 0 ? event.quantity : 1);
      }
      return item;
    }).toList();
    emit(CartState(cartItems: updatedCart));
  }


 /* void _onClearCart(ClearCartEvent event, Emitter<CartState> emit) {
    emit(CartState(cartItems: [])); // Emit a new state with an empty list of cart items
  }*/
   void _onClearCart(ClearCartEvent event, Emitter<CartState> emit) {
    emit( CartState(
        cartItems: [])); // Emit a new state with an empty list of cart items
  }
}