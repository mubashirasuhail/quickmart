import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_mart/presentation/bloc/cart_bloc.dart';
import 'package:quick_mart/presentation/bloc/cart_state.dart';
import 'package:quick_mart/presentation/bloc/cart_event.dart';
import 'package:quick_mart/presentation/screens/checkout.dart';
import 'package:quick_mart/presentation/widgets/color.dart'; // Make sure this path is correct for AppColors
import 'package:quick_mart/presentation/screens/home_screen.dart'; // Assuming your home screen is named HomeScreen1
import 'package:quick_mart/presentation/screens/favorites_screen.dart';
import 'package:quick_mart/presentation/widgets/order_details.dart'; // Assuming your favorites screen is named Favorites

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  static const double _deliveryCharge = 50.0;
  int _selectedIndex = 1; // 0: Home, 1: Cart, 2: Favorites

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen1()),
      );
    } else if (index == 1) {
      // Stay on Cart page
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Favorites()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OrderDetails()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.cartItems.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          final subtotal = state.cartItems.fold<double>(
              0, (sum, item) => sum + (item.productPrice * item.quantity));
          final totalAmountWithDelivery = subtotal + _deliveryCharge;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = state.cartItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              // Product Image with fixed size
                              SizedBox(
                                width: 80, // Fixed width for the image
                                height: 80, // Fixed height for the image
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    item.productImage,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                                'assets/images/placeholder.png',
                                                fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Product Details (Name, Price, Quantity controls)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${item.productPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.green),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove,
                                                size: 18),
                                            onPressed: () {
                                              if (item.quantity > 1) {
                                                context.read<CartBloc>().add(
                                                      UpdateCartItemQuantityEvent(
                                                          item.productId,
                                                          item.quantity - 1),
                                                    );
                                              } else {
                                                context.read<CartBloc>().add(
                                                    RemoveFromCartEvent(
                                                        item.productId));
                                              }
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                                minWidth: 30, minHeight: 30),
                                          ),
                                          Text(
                                            '${item.quantity}',
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          IconButton(
                                            icon:
                                                const Icon(Icons.add, size: 18),
                                            onPressed: () {
                                              context.read<CartBloc>().add(
                                                    UpdateCartItemQuantityEvent(
                                                        item.productId,
                                                        item.quantity + 1),
                                                  );
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                                minWidth: 30, minHeight: 30),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Remove Button
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red, size: 24),
                                onPressed: () {
                                  context
                                      .read<CartBloc>()
                                      .add(RemoveFromCartEvent(item.productId));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            '${item.productName} removed from cart.')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                      height: 20), // Space between list and price details

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Price Details',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Divider(), // Visual separator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Price:',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black87)),
                            Text('₹${subtotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black87)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Delivery Charge:',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black87)),
                            Text('₹${_deliveryCharge.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black87)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Amount:',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black87)),
                            Text(
                                ' ₹${totalAmountWithDelivery.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black87)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20), // Space before bottom edge
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          final subtotal = state.cartItems.fold<double>(
              0, (sum, item) => sum + (item.productPrice * item.quantity));
          final totalAmountWithDelivery = subtotal + _deliveryCharge;

          return Column(
            mainAxisSize:
                MainAxisSize.min, // Prevents column from taking full height
            children: [
              // Your existing checkout and total amount section
              if (state
                  .cartItems.isNotEmpty) // Only show this if cart is not empty
                Container(
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
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Total Amount:',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.black54)),
                          Text(
                            '₹${totalAmountWithDelivery.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutPage(
                                  totalAmount: totalAmountWithDelivery),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Proceed to Checkout',
                            style: TextStyle(fontSize: 15)),
                      ),
                    ],
                  ),
                ),

              BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart),
                    label: 'Cart',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.favorite,
                    ),
                    label: 'Favorites',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.list_alt),
                    label: 'Orders',
                  ),
                ],
                currentIndex: _selectedIndex,
                unselectedItemColor: Colors.grey,
                selectedItemColor: Colors.amber[800],
                 type: BottomNavigationBarType.fixed,
                unselectedLabelStyle: const TextStyle(
                  color: Colors.grey, // Set the text color to grey
                  fontSize: 12, // You can adjust font size if needed
                ), // Use theme primary color
                onTap: _onItemTapped,
              ),
            ],
          );
        },
      ),
    );
  }
}
