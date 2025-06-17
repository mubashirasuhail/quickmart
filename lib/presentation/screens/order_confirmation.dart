import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quick_mart/presentation/screens/checkout.dart';
import 'package:quick_mart/presentation/widgets/color.dart';

class OrderConfirmationPage extends StatelessWidget {
  final Order order;

  const OrderConfirmationPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(order.orderDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
        //backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- START OF THE ANIMATED CHECKMARK AND MESSAGE ---
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: value,
                          child: const Column(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 80), // Larger icon
                              SizedBox(height: 15),
                              Text(
                                'Your Order Has Been Placed!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 5), // Added this line as per your request
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // --- END OF THE ANIMATED CHECKMARK AND MESSAGE ---
                  const SizedBox(height: 30), // This adds space after the animated part
                  _infoRow(Icons.receipt_long, "Order ID", order.orderId),
                  _infoRow(Icons.calendar_today, "Order Date", formattedDate),
                  _infoRow(Icons.location_on, "Address", order.address),
                  _infoRow(Icons.payment, "Payment", order.paymentMethod),
                  _infoRow(Icons.currency_rupee, "Total", "₹${order.totalAmount.toStringAsFixed(2)}"),
                  _infoRow(Icons.local_shipping, "Status", order.orderStatus,
                      isBold: true, highlightColor: Colors.blue),
                  const SizedBox(height: 30),
                  Center(
                    child: 
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.shopping_cart,color: Colors.white),
                      label: const Text("Continue Shopping", style: TextStyle(fontSize: 16,color: Colors.white )),
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value,
      {bool isBold = false, Color? highlightColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: highlightColor ?? Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$title: ",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
                color: highlightColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}