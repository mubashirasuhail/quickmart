import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

class OrderDetails extends StatefulWidget {
  const OrderDetails({super.key});

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _ordersStream;

  @override
  void initState() {
    super.initState();
    _ordersStream = _firestore
        .collection('order')
        .orderBy('orderDate', descending: true)
        .snapshots();
  }

  Color _getOrderStatusColor(String status) {
    String cleanedStatus = status.trim().toLowerCase();
    developer.log('Evaluating status: "$cleanedStatus"', name: 'OrderStatusColor');

    switch (cleanedStatus) {
      case 'delivered':
        return Colors.blue;
      case 'accepted':
      case 'placed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        developer.log('Status "$cleanedStatus" did not match a predefined color. Defaulting to black.', name: 'OrderStatusColorWarning');
        return Colors.black;
    }
  }

  String _formatPaymentMethod(String method) {
    String cleanedMethod = method.trim().toLowerCase();
    switch (cleanedMethod) {
      case 'cod':
        return 'COD';
      case 'credit_card':
        return 'Credit Card';
      case 'netbanking':
        return 'Net Banking';
      default:
        return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _ordersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot<Map<String, dynamic>> orderDoc =
                  snapshot.data!.docs[index];
              SimpleOrder order = SimpleOrder.fromFirestore(orderDoc);

              // --- UPDATED DATE FORMAT HERE ---
              String formattedDate =
                  DateFormat('dd-MM-yyyy – hh:mm a').format(order.orderDate);
              // --------------------------------

              Color statusColor = _getOrderStatusColor(order.orderStatus);
              String formattedPaymentMethod = _formatPaymentMethod(order.paymentMethod);

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order ID: ${order.orderId}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Order Date: $formattedDate',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Payment Method: $formattedPaymentMethod',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        'Total Amount: ₹${order.totalAmount?.toStringAsFixed(2) ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text('Order Status: ${order.orderStatus}',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: statusColor)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class SimpleOrder {
  String orderId;
  String paymentMethod;
  double? totalAmount;
  DateTime orderDate;
  String orderStatus;

  SimpleOrder({
    required this.orderId,
    required this.paymentMethod,
    this.totalAmount,
    required this.orderDate,
    required this.orderStatus,
  });

  factory SimpleOrder.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null || data['orderStatus'] == null) {
      developer.log('Order data is null or orderStatus is null for document ID: ${doc.id}', name: 'FirestoreDataWarning');
      return SimpleOrder(
        orderId: doc.id,
        paymentMethod: data?['paymentMethod'] ?? 'N/A',
        totalAmount: (data?['totalAmount'] is String
                ? double.tryParse(data!['totalAmount'])
                : data?['totalAmount']?.toDouble()) ??
            0.0,
        orderDate: (data?['orderDate'] is Timestamp)
            ? (data!['orderDate'] as Timestamp).toDate()
            : DateTime.now(),
        orderStatus: 'Unknown',
      );
    }

    String orderId = doc.id;
    if (orderId.startsWith('COD-')) {
      orderId = orderId.substring(4);
    } else if (orderId.startsWith('pay-')) {
      orderId = orderId.substring(4);
    }

    dynamic orderDateData = data['orderDate'];
    DateTime orderDate;

    if (orderDateData is Timestamp) {
      orderDate = orderDateData.toDate();
    } else if (orderDateData is String) {
      DateTime? parsedDate = DateTime.tryParse(orderDateData);
      if (parsedDate == null) {
        developer.log("Warning: Could not parse orderDate String: $orderDateData for order ID: ${doc.id}", name: 'OrderDateParsing');
        orderDate = DateTime.now();
      } else {
        orderDate = parsedDate;
      }
    } else {
      orderDate = DateTime.now();
    }

    return SimpleOrder(
      orderId: orderId,
      paymentMethod: data['paymentMethod'] ?? 'N/A',
      totalAmount: data['totalAmount'] is String
          ? double.tryParse(data['totalAmount'])
          : data['totalAmount']?.toDouble(),
      orderDate: orderDate,
      orderStatus: data['orderStatus'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> get toFirestore => {
        'orderId': orderId,
        'paymentMethod': paymentMethod,
        'totalAmount': totalAmount,
        'orderDate': orderDate,
        'orderStatus': orderStatus,
      };
}