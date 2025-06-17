import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quick_mart/presentation/screens/product_detail.dart';
import 'package:quick_mart/presentation/widgets/color.dart';
// If you don't need product_screen.dart import, you can remove it.
// import 'package:quick_mart/presentation/screens/product_screen.dart';


class SearchScreen extends StatefulWidget {
  final String query;
  const SearchScreen({super.key, required this.query});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = true;
  String? _sortOption; // Added sort option

  @override
  void initState() {
    super.initState();
    searchController.text = widget.query;
    searchController.addListener(_onSearchChanged);
    searchProducts(widget.query);
  }

  Future<void> searchProducts(String query) async {
    try {
      if (query.isEmpty) {
        setState(() {
          searchResults = [];
          isLoading = false;
        });
        return;
      }

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('product')
          .orderBy('productname')
          .startAt([query]).endAt(['$query\uf8ff'])
          .get();

      List<Map<String, dynamic>> fetchedProducts = querySnapshot.docs
          .map((doc) => {
                'productname': doc['productname'] ?? 'Unknown',
                'category': doc['category'] ?? 'Unknown',
                'description': doc['description'] ?? 'No description',
                'image': doc['image'] ?? '',
                'price': doc['price'] ?? 'N/A',
                'id': doc.id,
                'moreImages': (doc['moreImages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
              })
          .toList();

      setState(() {
        searchResults = fetchedProducts;
        isLoading = false;
        _sortProducts(); // Apply sorting after fetching
      });
    } catch (e) {
      debugPrint("Error searching products: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    String query = searchController.text.trim();
    setState(() {
      isLoading = true;
    });
    searchProducts(query);
  }

  void _sortProducts() {
    if (_sortOption == 'Lowest to Highest') {
      searchResults.sort((a, b) => double.parse(a['price'].toString())
          .compareTo(double.parse(b['price'].toString())));
    } else if (_sortOption == 'Highest to Lowest') {
      searchResults.sort((a, b) => double.parse(b['price'].toString())
          .compareTo(double.parse(a['price'].toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results for "${searchController.text}"'),
       // centerTitle: true, // Center the app bar title
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search for products...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder( // Added for consistency
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder( // Added for consistency
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.darkgreen), // Highlight when focused
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _sortOption,
                  hint: const Text('Sort by Price'),
                  onChanged: (value) {
                    setState(() {
                      _sortOption = value;
                      _sortProducts();
                    });
                  },
                  items: <String>[
                    'Lowest to Highest',
                    'Highest to Lowest',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const Spacer(),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : searchResults.isEmpty
                    ? const Center(child: Text("No products found"))
                    : ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final Map<String, dynamic> currentProduct = searchResults[index];

                          String productId = currentProduct['id'];
                          String productName = currentProduct['productname'];
                          String productImage = currentProduct['image'];
                          String productDescription = currentProduct['description'];
                          double productPrice = double.tryParse(currentProduct['price'].toString()) ?? 0.0;
                          List<String> moreImages = currentProduct['moreImages'] is List
                              ? List<String>.from(currentProduct['moreImages'])
                              : [];


                          return Card( // Changed from ListTile to Card
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            elevation: 4, // Add some shadow
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
                            child: InkWell( // Make the entire card tappable
                              borderRadius: BorderRadius.circular(12), // Match card border
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
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product Image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Container( // Using Container for placeholder background if image is empty
                                        color: Colors.grey[200], // Placeholder color
                                        width: 90, // Larger image
                                        height: 80,
                                        child: productImage.isNotEmpty
                                            ? Image.network(
                                                productImage,
                                                fit: BoxFit.cover,
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
                                                errorBuilder: (context, error, stackTrace) =>
                                                    Image.asset('assets/images/placeholder.png', fit: BoxFit.cover),
                                              )
                                            : Image.asset('assets/images/placeholder.png', fit: BoxFit.cover),
                                      ),
                                    ),
                                    const SizedBox(width: 15), // Spacing between image and text

                                    // Product Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            productName,
                                            style: const TextStyle(
                                              fontSize: 17, // Slightly larger font
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6), // Spacing
                                          Text(
                                            '₹ ${productPrice.toStringAsFixed(2)}', // Format price to 2 decimal places
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green, // Highlight price with green
                                            ),
                                          ),
                                          const SizedBox(height: 6), // Spacing
                                      /*    Text(
                                            productDescription,
                                            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                            maxLines: 2, // Show a snippet of description
                                            overflow: TextOverflow.ellipsis,
                                          ),*/
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}