import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quick_mart/presentation/screens/product_screen.dart';

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
              })
          .toList();

      setState(() {
        searchResults = fetchedProducts;
        isLoading = false;
        _sortProducts(); // Apply sorting after fetching
      });
    } catch (e) {
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
        title: Text('Search results for "${searchController.text}"'),
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
                          String imageUrl = searchResults[index]['image'];
                          String name = searchResults[index]['productname'];
                          String category = searchResults[index]['category'];
                          String price = searchResults[index]['price'].toString();

                          return ListTile(
                            leading: imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    width: 50,
                                    height: 50,
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
                                        Image.asset('assets/images/placeholder.png'),
                                  )
                                : Image.asset('assets/images/placeholder.png', width: 50, height: 50, fit: BoxFit.cover,),
                            title: Text(name),
                            subtitle: Text('Category: $category\nPrice: ₹ $price'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductScreen(
                                    category: category,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}