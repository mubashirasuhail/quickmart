import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import 'dart:async'; // <--- Add this import

// Assuming you have ProductDetailScreen and other necessary imports
import 'package:quick_mart/presentation/screens/product_detail.dart';
import 'package:quick_mart/presentation/widgets/color.dart';

class ProductScreen extends StatefulWidget {
  final String category; // This is the category name passed from HomeScreen1

  const ProductScreen({super.key, required this.category});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late final String _queryCategory;
  // Use a Set to efficiently check if a product is favorited
  final Set<String> _favoriteProductIds = {};
  // Stream subscription for favorites
  StreamSubscription? _favoritesSubscription;

  @override
  void initState() {
    super.initState();
    _queryCategory = widget.category.toLowerCase();
    developer.log('Fetching products for category: $_queryCategory', name: 'ProductScreen');
    _listenToFavorites(); // Start listening to favorite changes
  }

  @override
  void dispose() {
    _favoritesSubscription?.cancel(); // Cancel the subscription when the widget is disposed
    super.dispose();
  }

  // Listen to changes in the 'favorites' collection
  void _listenToFavorites() {
    _favoritesSubscription = FirebaseFirestore.instance
        .collection('favorites')
        .snapshots()
        .listen((snapshot) {
      if (mounted) { // Only update state if the widget is still mounted
        setState(() {
          _favoriteProductIds.clear();
          for (var doc in snapshot.docs) {
            _favoriteProductIds.add(doc.id); // Add product ID to the set
          }
        });
        developer.log('Favorites updated: ${_favoriteProductIds.length} items', name: 'ProductScreen');
      }
    }, onError: (error) {
      developer.log('Error listening to favorites: $error', name: 'ProductScreenError');
    });
  }

  // Helper method to safely get product price, handling String or num
  double _getProductPrice(Map<String, dynamic> product) {
    final dynamic priceData = product['price'];
    if (priceData is num) {
      return priceData.toDouble();
    } else if (priceData is String) {
      try {
        return double.parse(priceData);
      } catch (e) {
        developer.log('Error parsing price string "${priceData}": $e', name: 'ProductPriceParsing');
        return 0.0;
      }
    }
    return 0.0; // Default for unexpected types
  }

  // Function to toggle favorite status
  Future<void> _toggleFavorite(Map<String, dynamic> product) async {
    final String productId = product['id'] as String? ?? '';
    if (productId.isEmpty) {
      developer.log('Attempted to toggle favorite for product with empty ID', name: 'ToggleFavoriteError');
      return;
    }

    final DocumentReference favoriteDocRef =
        FirebaseFirestore.instance.collection('favorites').doc(productId);

    if (_favoriteProductIds.contains(productId)) {
      // Product is currently favorited, so remove it
      try {
        await favoriteDocRef.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from favorites.')),
        );
        developer.log('Product $productId removed from favorites.', name: 'ToggleFavorite');
      } catch (e) {
        developer.log('Error removing product $productId from favorites: $e', name: 'ToggleFavoriteError');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove from favorites: $e')),
        );
      }
    } else {
      // Product is not favorited, so add it
      try {
        await favoriteDocRef.set({
          'productname': product['productname'],
          'image': product['image'],
          'price': product['price'],
          'description': product['description'],
          'category': product['category'], // Store category for potential filtering in favorites
          'moreImages': product['moreImages'] ?? [], // Ensure moreImages is stored if available
          // Add any other relevant product details you want to store in favorites
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to favorites!')),
        );
        developer.log('Product $productId added to favorites.', name: 'ToggleFavorite');
      } catch (e) {
        developer.log('Error adding product $productId to favorites: $e', name: 'ToggleFavoriteError');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to favorites: $e')),
        );
      }
    }
    // The _listenToFavorites stream will automatically update _favoriteProductIds
    // once the Firestore operation completes, triggering a setState.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category), // Display the original category name
        backgroundColor: AppColors.darkgreen, // Or your app's primary color
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Use the lowercase _queryCategory for the Firestore query
        stream: FirebaseFirestore.instance
            .collection('product')
            .where('category', isEqualTo: _queryCategory)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            developer.log('Error loading products for category ${_queryCategory}: ${snapshot.error}', name: 'ProductScreenError', error: snapshot.error);
            return Center(child: Text('Error loading products: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No products found for '${widget.category}'."));
          }

          final List<Map<String, dynamic>> products = snapshot.data!.docs.map((doc) {
            return {...doc.data() as Map<String, dynamic>, 'id': doc.id};
          }).toList();

          // Optional: Sort products by name for consistent display
          products.sort((a, b) => (a['productname'] as String? ?? '').compareTo(b['productname'] as String? ?? ''));

          return GridView.builder(
            padding: const EdgeInsets.all(10.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // You can adjust this based on your design
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75, // Adjust as needed to fit content
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final String productId = product['id'] as String? ?? '';
              final String productName = product['productname'] as String? ?? 'N/A';
              final String productImage = product['image'] as String? ?? '';
              final String productDescription = product['description'] as String? ?? '';
              final double productPrice = _getProductPrice(product);
              final List<String> moreImages = (product['moreImages'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ?? [];

              // Determine if the current product is a favorite
              final bool isFavorite = _favoriteProductIds.contains(productId);

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
                child: Card( // Using Card for a nicer visual container
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Stack( // Use Stack to position the favorite icon
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                              child: Image.network(
                                productImage,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
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
                                  return Image.asset('assets/images/placeholder.png', fit: BoxFit.contain);
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${productPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(color: AppColors.darkgreen, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Favorite icon positioned at the top right
                      Positioned(
                        top: 5,
                        right: 5,
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                            size: 28,
                          ),
                          onPressed: () => _toggleFavorite(product),
                          tooltip: isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
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
}