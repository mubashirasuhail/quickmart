import 'package:flutter/material.dart';
import 'package:quick_mart/presentation/bloc/cart_bloc.dart';
import 'package:quick_mart/presentation/bloc/cart_event.dart';
import 'package:quick_mart/presentation/screens/address1.dart'; // Ensure this path is correct
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_confirmation.dart'; // Ensure this path is correct
import 'package:flutter_bloc/flutter_bloc.dart'; // Import flutter_bloc
// Adjust this path to your CartEvent file


// Placeholder for your order model
class Order {
  String orderId;
  String address;
  String paymentMethod;
  double totalAmount;
  DateTime orderDate;
  String orderStatus; // Added order status

  Order({
    required this.orderId,
    required this.address,
    required this.paymentMethod,
    required this.totalAmount,
    required this.orderDate,
    required this.orderStatus,
  });

  // Factory constructor to create an Order object from a Firebase document.
  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Order(
      orderId: data['orderId'] ?? '',
      address: data['address'] ?? '',
      paymentMethod: data['paymentMethod'] ?? '',
      totalAmount: data['totalAmount']?.toDouble() ?? 0.0, // Ensure it's a double
      orderDate: (data['orderDate'] as Timestamp).toDate(), // Convert Timestamp to DateTime
      orderStatus: data['orderStatus'] ?? '', // Get order status
    );
  }

  // Convert Order object to a map for storing in Firebase. Use a computed property.
  Map<String, dynamic> get toFirestore => {
        'orderId': orderId,
        'address': address,
        'paymentMethod': paymentMethod,
        'totalAmount': totalAmount,
        'orderDate': orderDate, // Store as DateTime; Firestore will handle the conversion
        'orderStatus': orderStatus,
      };
}

// MODIFIED: MyIconButton now accepts a Widget for its icon
class MyIconButton extends StatelessWidget {
  final Widget iconWidget; // Changed type from IconData to Widget
  final VoidCallback pressed;
  final double? iconSize; // Optional: for controlling the size of the image asset

  const MyIconButton({
    super.key,
    required this.iconWidget,
    required this.pressed,
    this.iconSize, // Added iconSize
  });

  @override
  Widget build(BuildContext context) {
    return InkWell( // Using InkWell for a more flexible tap area and visual feedback
      onTap: pressed,
      child: SizedBox( // Wrap in SizedBox to control the size of the tappable area
        width: iconSize ?? 48, // Default size if not provided
        height: iconSize ?? 48, // Default size if not provided
        child: Center(child: iconWidget), // Center the icon widget
      ),
    );
  }
}


class CheckoutPage extends StatefulWidget {
  final double totalAmount;

  const CheckoutPage({super.key, required this.totalAmount});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? _paymentMethod;
  Address? _addressData; // Stores the complete Address object
  Razorpay? _razorpay;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    _paymentMethod = 'credit_card';
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay?.clear();
    super.dispose();
  }

  Future<void> _addOrderToFirestore(Order order) async {
    if (mounted) {
      setState(() {
        _isPlacingOrder = true;
      });
    }
    try {
      await _firestore.collection('order').add(order.toFirestore);
      debugPrint('Order added to Firestore successfully!');
    } catch (e) {
      debugPrint('Error adding order to Firestore: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add order. Please check your internet connection.'),
          ),
        );
        setState(() {
          _isPlacingOrder = false;
        });
      }
      rethrow; // Re-throw to propagate the error
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false; // Ensure loading indicator is dismissed
        });
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Construct the full address string for the order object, joined by newlines for internal storage/display
    final String fullAddress = _addressData == null
        ? 'N/A'
        : [
            _addressData!.addressName,
            _addressData!.streetAddress,
            _addressData!.area,
          //  _addressData!.city,
          //  _addressData!.state,
          //  _addressData!.zipCode,
          //  _addressData!.country,
            _addressData!.currentLocation,
          ].where((s) => s != null && s.isNotEmpty).join('\n'); // Changed to newline

    Order order = Order(
      orderId: response.paymentId ?? 'N/A',
      address: fullAddress, // Use the comprehensive address here
      paymentMethod: _paymentMethod!,
      totalAmount: widget.totalAmount,
      orderDate: DateTime.now(),
      orderStatus: 'Placed',
    );

    try {
      await _addOrderToFirestore(order);

      // >>> ADDITION: Clear the cart after successful payment <<<
      if (mounted) {
        BlocProvider.of<CartBloc>(context).add(ClearCartEvent());
      }
      // >>> END ADDITION <<<

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderConfirmationPage(order: order),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while confirming your order. Please try again.'),
          ),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      setState(() {
        _isPlacingOrder = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Failed: ${response.message}')),
      );
      debugPrint('Payment Error: ${response.code} - ${response.message}');
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('External Wallet Selected!')),
      );
      debugPrint('External Wallet: ${response.walletName}');
    }
  }

  Future<void> _openCheckout() async {
    if (_addressData == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a delivery address before placing your order.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    var options = {
      'key': 'rzp_test_Dc4h2aSQLqMk9y', // Replace with your actual test key
      'amount': (widget.totalAmount * 100).toInt(), // Amount in paise
      'name': 'Quick Mart',
      'description': 'Payment for your order',
      'prefill': {
        'contact': '9526769503', // Use user's phone number
        'email': 'mubikdl@gmail.com' // Use user's email
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay?.open(options);
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing payment: $e')),
        );
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Construct the full address string for display, joined by newlines
    final String fullDisplayedAddress = _addressData == null
        ? 'No address selected'
        : [
            _addressData!.addressName,
            _addressData!.streetAddress,
            _addressData!.area,

            _addressData!.currentLocation,
          ].where((s) => s != null && s.isNotEmpty).join('\n');

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Delivery Address Section ---
            const Text(
              'Delivery Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display the full address
                    Text(
                      fullDisplayedAddress,
                      style: TextStyle(
                        fontSize: 16,
                        color: _addressData == null ? const Color.fromARGB(255, 62, 61, 61) : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddressPage(initialAddress: _addressData),
                            ),
                          );
                          if (result != null && result is Address) {
                            setState(() {
                              _addressData = result;
                            });
                          }
                        },
                        icon: const Icon(Icons.location_on),
                        label: Text(_addressData == null ? 'Add Address' : 'Change Address'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Payment Method Section ---
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              color: Colors.white,
              elevation: 2,
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        // Using MyIconButton with Image.asset for credit card
                        MyIconButton(
                          iconWidget: Image.asset(
                            'assets/images/cred.png', // Your credit card image asset
                            width: 74, // Adjust size as needed
                            height: 94, // Adjust size as needed
                          ),
                          pressed: () {
                            setState(() {
                              _paymentMethod = 'credit_card';
                            });
                          },
                          iconSize: 48, // Set a larger tappable area for the icon
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Credit/Debit Card'),
                        ),
                      ],
                    ),
                    value: 'credit_card',
                    groupValue: _paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _paymentMethod = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        // Using MyIconButton with Image.asset for cash on delivery
                        MyIconButton(
                          iconWidget: Image.asset(
                            'assets/images/cod.png', // Your cash on delivery image asset
                            width: 54, // Adjust size as needed
                            height: 44, // Adjust size as needed
                          ),
                          pressed: () {
                            setState(() {
                              _paymentMethod = 'cod';
                            });
                          },
                          iconSize: 48, // Set a larger tappable area for the icon
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Cash on Delivery'),
                        ),
                      ],
                    ),
                    value: 'cod',
                    groupValue: _paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _paymentMethod = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Order Summary Section ---
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount:',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    '₹${widget.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- Place Order Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPlacingOrder
                    ? null
                    : () {
                        if (_addressData == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a delivery address.'),
                            ),
                          );
                          return;
                        }

                        if (_paymentMethod == 'credit_card') {
                          _openCheckout();
                        } else if (_paymentMethod == 'cod') {
                          // Construct the full address string for the order object, joined by newlines
                          final String fullAddressForOrder = _addressData == null
                              ? 'N/A'
                              : [
                                  _addressData!.addressName,
                                  _addressData!.streetAddress,
                                  _addressData!.area,

                                  _addressData!.currentLocation,
                                ].where((s) => s != null && s.isNotEmpty).join('\n');

                          Order order = Order(
                            orderId: 'COD-${DateTime.now().millisecondsSinceEpoch}',
                            address: fullAddressForOrder, // Use the comprehensive address here
                            paymentMethod: _paymentMethod!,
                            totalAmount: widget.totalAmount,
                            orderDate: DateTime.now(),
                            orderStatus: 'Placed',
                          );
                          _showOrderConfirmationDialog(order);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a payment method.'),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(10),
                               ),
                     backgroundColor: Theme.of(context).primaryColor,
                               foregroundColor: Colors.white,

                     textStyle: const TextStyle(fontSize: 18),
                ),
                child: _isPlacingOrder
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(width: 10),
                          Text('Placing Order...'),
                        ],
                      )
                    : const Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show dialog for COD order confirmation
  void _showOrderConfirmationDialog(Order order) {
    final localContext = context;

    showDialog(
      context: localContext,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Order'),
        content: const Text('Do you want to confirm your order with Cash on Delivery?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close the dialog
              await _addOrderToFirestore(order); // This will set _isPlacingOrder
              if (mounted) {
                // >>> ADDITION: Clear the cart after successful COD order <<<
                BlocProvider.of<CartBloc>(localContext).add(ClearCartEvent());
                // >>> END ADDITION <<<

                ScaffoldMessenger.of(localContext).showSnackBar(
                  const SnackBar(
                    content: Text('Order placed with Cash on Delivery.'),
                  ),
                );
                Navigator.pushReplacement(
                  localContext,
                  MaterialPageRoute(
                    builder: (context) => OrderConfirmationPage(order: order),
                  ),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}