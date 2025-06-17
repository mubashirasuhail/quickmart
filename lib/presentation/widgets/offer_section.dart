import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quick_mart/presentation/screens/product_detail.dart';
import 'dart:developer' as developer;

double _getProductPrice(Map<String, dynamic> product) {
  // Replace with your own logic for price extraction
  return double.tryParse(product['price'].toString()) ?? 0.0;
}

Widget topProductsGrid(BuildContext context) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection("product")
        .where('offerType', isEqualTo: 'Top Product')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        developer.log('Error loading top products: ${snapshot.error}',
            name: 'TopProductStreamError', error: snapshot.error);
        return Center(child: Text("Error: ${snapshot.error}"));
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(child: Text("No top products found"));
      }

      final List<Map<String, dynamic>> products = snapshot.data!.docs.map((doc) {
        return {...doc.data() as Map<String, dynamic>, 'id': doc.id};
      }).toList();

      products.sort((a, b) => (a['productname'] as String? ?? '')
          .compareTo(b['productname'] as String? ?? ''));

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.7,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final productId = product['id'] ?? '';
          final productName = product['productname'] ?? 'N/A';
          final productImage = product['image'] ?? '';
          final productDescription = product['description'] ?? '';
          final productPrice = _getProductPrice(product);
          final moreImages =
              (product['moreImages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(
                    productId: productId,
                    productName: productName,
                    productImage: productImage,
                    productDescription: productDescription,
                    productPrice: productPrice,
                    moreImages: moreImages,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network(
                        productImage,
                        fit: BoxFit.cover,
                        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded) return child;
                          return frame == null
                              ? Image.asset('assets/images/placeholder.png', fit: BoxFit.contain)
                              : child;
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset('assets/images/placeholder.png', fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(productName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis),
                        Text('₹${productPrice.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget buildProductOfferSection(BuildContext context, String offerTypeTitle) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          offerTypeTitle,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("product")
            .where('offerType', isEqualTo: offerTypeTitle)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            developer.log('Error loading $offerTypeTitle: ${snapshot.error}',
                name: 'OfferTypeStreamError', error: snapshot.error);
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("No products available."),
            );
          }

          final products = snapshot.data!.docs.map((doc) {
            return {...doc.data() as Map<String, dynamic>, 'id': doc.id};
          }).toList();

          products.sort((a, b) => (a['productname'] as String? ?? '')
              .compareTo(b['productname'] as String? ?? ''));

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final productId = product['id'] ?? '';
              final productName = product['productname'] ?? 'N/A';
              final productImage = product['image'] ?? '';
              final productDescription = product['description'] ?? '';
              final productPrice = _getProductPrice(product);
              final moreImages =
                  (product['moreImages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        productId: productId,
                        productName: productName,
                        productImage: productImage,
                        productDescription: productDescription,
                        productPrice: productPrice,
                        moreImages: moreImages,
                        
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(
                            productImage,
                            fit: BoxFit.cover,
                            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                              if (wasSynchronouslyLoaded) return child;
                              return frame == null
                                  ? Image.asset('assets/images/placeholder.png',
                                      fit: BoxFit.contain)
                                  : child;
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset('assets/images/placeholder.png',
                                    fit: BoxFit.contain),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(productName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis),
                            Text('₹${productPrice.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      const SizedBox(height: 20),
    ],
  );
}
