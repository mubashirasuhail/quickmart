import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_mart/presentation/bloc/cart_bloc.dart';
import 'package:quick_mart/presentation/bloc/cart_event.dart';
import 'package:quick_mart/presentation/bloc/cart_state.dart';
import 'package:quick_mart/presentation/screens/cart_screen.dart';

import 'package:quick_mart/presentation/widgets/color.dart';
// Make sure you import your CartItem model

class ProductDetailScreen extends StatelessWidget {
  final String productId;
  final String productName;
  final String productImage;
  final String productDescription;
  final double productPrice;
  final List<String> moreImages;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.productDescription,
    required this.productPrice,
    required this.moreImages,
  });

  static const double _deliveryCharge = 50.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(productName)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                productImage,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/images/placeholder.png');
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                productName,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                productDescription,
                style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 80, 79, 79)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '₹$productPrice',
                style: const TextStyle(fontSize: 18, color: Colors.green),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'More Images',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: moreImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.network(
                        moreImages[index],
                        width: 150,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/placeholder.png',
                            width: 150,
                            height: 150,
                            fit: BoxFit.contain,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          final subtotal = state.cartItems.fold<double>(
              0, (sum, item) => sum + (item.productPrice * item.quantity));
          final totalAmountWithDelivery = subtotal + _deliveryCharge;

          return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.4),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: const Offset(0, -5),
                ),
              ],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                 //   const Text('Amount:', style: TextStyle(fontSize: 18, color: Colors.black54)),
                    Text(
                   
                          '₹${productPrice.toStringAsFixed(2)}' ,
                         
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkgreen),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    // Option 1: Use firstWhereOrNull from collection package
                    // If you add the 'collection' package, this is the cleanest.
                    // final existingCartItem = state.cartItems.firstWhereOrNull(
                    //   (item) => item.productId == productId,
                    // );

                    // Option 2 (Current Fix): Explicitly check for an item and return null if not found
                    CartItem? existingCartItem; // Declare as nullable
                    try {
                      existingCartItem = state.cartItems.firstWhere(
                        (item) => item.productId == productId,
                      );
                    } catch (e) {
                      // If firstWhere doesn't find anything, it throws a StateError.
                      // We catch it and existingCartItem remains null.
                    }

                    if (existingCartItem != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartPage()),
                      );
                    } else {
                        context.read<CartBloc>().add(AddToCartEvent(
                            productId: productId,
                            productName: productName,
                            productImage: productImage,
                            productPrice: productPrice,
                          ));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to cart')),
                      );
                    
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => const CartPage()),
                      // );
                    }
                  },
                   
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: BlocBuilder<CartBloc, CartState>(
                    builder: (context, cartState) {
                      final bool isInCart = cartState.cartItems.any((item) => item.productId == productId);
                      return Text(
                        isInCart ? 'Go to Cart' : 'Add to Cart',
                        style: const TextStyle(fontSize: 15),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}