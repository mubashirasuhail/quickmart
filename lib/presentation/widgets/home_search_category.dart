import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

import '../screens/product_screen.dart';

// Search widget function
Widget search(TextEditingController controller, Function(String) onSearchSubmitted) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      hintText: "Search Product",
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      suffixIcon: IconButton(
        icon: const Icon(Icons.search, color: Colors.grey),
        onPressed: () {
          String searchText = controller.text.trim();
          controller.clear();
          if (searchText.isNotEmpty) {
            onSearchSubmitted(searchText);
          }
        },
      ),
    ),
    textInputAction: TextInputAction.search,
    onSubmitted: (_) {
      String searchText = controller.text.trim();
      controller.clear();
      if (searchText.isNotEmpty) {
        onSearchSubmitted(searchText);
      }
    },
  );
}

// Category list widget function
Widget category(BuildContext context) {
  return SizedBox(
    height: 120,
    child: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('category').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          developer.log('Error fetching categories: ${snapshot.error}',
              name: 'CategoryStreamError', error: snapshot.error);
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No categories found"));
        }

        final categories = snapshot.data!.docs.map((doc) {
          return {
            'name': doc['name'] ?? 'Unknown',
            'image': doc['image'] ?? '',
          };
        }).toList();

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            String imageUrl = categories[index]['image'];
            String categoryName = categories[index]['name'];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductScreen(category: categoryName),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : const AssetImage('assets/images/placeholder.png') as ImageProvider,
                      onBackgroundImageError: (exception, stackTrace) {
                        developer.log('Error loading image: $exception',
                            error: exception, stackTrace: stackTrace);
                      },
                    ),
                    const SizedBox(height: 5),
                    Text(
                      categoryName.isNotEmpty
                          ? '${categoryName[0].toUpperCase()}${categoryName.substring(1)}'
                          : categoryName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
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
  );
}