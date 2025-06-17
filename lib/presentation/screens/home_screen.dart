import 'package:flutter/material.dart';
import 'package:quick_mart/core/utils/auth_utils.dart';
import 'package:quick_mart/presentation/screens/cart_screen.dart';
import 'package:quick_mart/presentation/screens/favorites_screen.dart';
import 'package:quick_mart/presentation/screens/privacy_policy.dart';
import 'package:quick_mart/presentation/screens/product_detail.dart';
import 'package:quick_mart/presentation/screens/profile_view.dart';
import 'package:quick_mart/presentation/screens/rules_regulation.dart';
import 'package:quick_mart/presentation/screens/search_screen.dart';
import 'package:quick_mart/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quick_mart/presentation/screens/login_screen.dart';
import 'package:quick_mart/presentation/screens/product_screen.dart';
import 'package:quick_mart/presentation/widgets/banner.dart';
import 'package:quick_mart/presentation/widgets/bottom_navigation.dart';
import 'package:quick_mart/presentation/widgets/button.dart';
import 'package:quick_mart/presentation/widgets/color.dart';
import 'package:quick_mart/presentation/widgets/home_custom_drawer.dart';
import 'package:quick_mart/presentation/widgets/home_header.dart';
import 'package:quick_mart/presentation/widgets/home_search_category.dart';
import 'package:quick_mart/presentation/widgets/offer_section.dart';
import 'package:quick_mart/presentation/widgets/order_details.dart';

class HomeScreen1 extends StatefulWidget {
  const HomeScreen1({super.key});

  @override
  State<HomeScreen1> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen1> {
  final auth = Authservice();
  final TextEditingController searchController = TextEditingController();

  int _selectedIndex = 0;
  String _userName = 'Guest User';
  String _userEmail = '';
  String _userProfileImageUrl = 'https://via.placeholder.com/150';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _navigateToOrderDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OrderDetails()),
    );
  }

  Future<void> _fetchUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _userName =
            currentUser.displayName ?? currentUser.email ?? 'QuickMart User';
        _userEmail = currentUser.email ?? '';
      
        _userProfileImageUrl = currentUser.photoURL ??
            'https://i.pravatar.cc/150?img=${(DateTime.now().millisecond % 70) + 1}';
      });
    }
  }

   void _signOut() {
    showSignOutDialog(
      context: context,
      signOutFunction: () async {
        await auth.signout();
      },
    );
  }

  void _onSearch() {
    String searchText = searchController.text.trim();
    searchController.clear();
    if (searchText.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchScreen(query: searchText),
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartPage()),
      ).then((_) {
        setState(() {
          _selectedIndex = 0; // Set selected index back to Home
        });
      });
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Favorites()),
      ).then((_) {
        setState(() {
          _selectedIndex = 0; // Set selected index back to Home
        });
      });
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OrderDetails()),
      ).then((_) {
        setState(() {
          _selectedIndex = 0; // Set selected index back to Home
        });
      });
    }
  }



  Widget search() {
    return TextField(
      controller: searchController,
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
          onPressed: _onSearch,
        ),
      ),
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _onSearch(),
    );
  }

  Widget category(BuildContext context) {
    return SizedBox(
      height: 120,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('category')
            .snapshots(), // Listen to real-time changes
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

          final List<Map<String, dynamic>> fetchedCategories =
              snapshot.data!.docs
                  .map((doc) => {
                        'name': doc['name'] ?? 'Unknown',
                        'image': doc['image'] ?? '',
                      })
                  .toList();

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: fetchedCategories.length,
            itemBuilder: (context, index) {
              String imageUrl = fetchedCategories[index]['image'];
              String categoryName = fetchedCategories[index]['name'];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductScreen(category: categoryName),
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
                            : const AssetImage('assets/images/placeholder.png')
                                as ImageProvider,
                        onBackgroundImageError: (exception, stackTrace) {
                          developer.log(
                              'Error loading category image: $exception',
                              error: exception,
                              stackTrace: stackTrace);
                        },
                      ),
                      const SizedBox(height: 5),
                      Text(
                        // Capitalize the first letter
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

  // Helper method to safely get product price, handling String or num
  double _getProductPrice(Map<String, dynamic> product) {
    final dynamic priceData = product['price'];
    if (priceData is num) {
      return priceData.toDouble();
    } else if (priceData is String) {
      try {
        return double.parse(priceData);
      } catch (e) {
        developer.log('Error parsing price string "${priceData}": $e',
            name: 'ProductPriceParsing');
        return 0.0;
      }
    }
    return 0.0; // Default for unexpected types
  }

  

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     drawer: CustomDrawer(
  userName: _userName,
  userEmail: _userEmail,
  userProfileImageUrl: _userProfileImageUrl,
  onSignOut: _signOut,
  onItemTapped: _onItemTapped,
  navigateToOrderDetails: _navigateToOrderDetails,
),
      body: SafeArea(
        child: Column(
          children: [
            const Header(),// Your existing header
            const SizedBox(height: 15),
            Expanded(
              // Using Expanded with SingleChildScrollView is crucial for flexible layout
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                 //     SearchAndCategoryWidget(onSearchSubmitted: widgetonSearchSubmitted)
                      search(),
                      const SizedBox(height: 20),
                      category(context), // Category list, now real-time
                      const SizedBox(height: 20),
                      const BannerExpl(), // Your banner
                      const SizedBox(height: 20),

                      // Section for "Our Top Products" (specific offerType)
                      const Text('Our Top Products',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      topProductsGrid(context), // Top Products Grid, now real-time
                      const SizedBox(height: 20),

                      // Dynamically build sections for OTHER offer types
                      // This StreamBuilder fetches all products to find distinct offerTypes
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("product")
                            .snapshots(),
                        builder: (context, productSnapshot) {
                          if (productSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (productSnapshot.hasError) {
                            developer.log(
                                'Error loading products for offer type discovery: ${productSnapshot.error}',
                                name: 'OfferTypeDiscoveryError',
                                error: productSnapshot.error);
                            return Center(
                                child: Text("Error loading special offers."));
                          }
                          if (!productSnapshot.hasData ||
                              productSnapshot.data!.docs.isEmpty) {
                            return const SizedBox
                                .shrink(); // No products to categorize
                          }

                          // Extract unique offer types (excluding 'Top Product')
                          Set<String> distinctOfferTypes = {};
                          for (var doc in productSnapshot.data!.docs) {
                            final data = doc.data() as Map<String, dynamic>;
                            final offerType = data['offerType'] as String?;
                            // Ensure offerType is not null, not empty, and not 'Top Product'
                            if (offerType != null &&
                                offerType.isNotEmpty &&
                                offerType != 'Top Product') {
                              distinctOfferTypes.add(offerType);
                            }
                          }

                          // Convert to a sorted list for consistent display order of sections
                          List<String> sortedOfferTypes =
                              distinctOfferTypes.toList()..sort();

                          if (sortedOfferTypes.isEmpty) {
                            return const Center(
                                child:
                                    Text("No other special offers available."));
                          }

                          // Build a _buildProductOfferSection for each discovered offer type
                          return Column(
                            children: sortedOfferTypes.map((offerType) {
                              return buildProductOfferSection(context,
                                  offerType); // Each section has its own StreamBuilder
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationWidget(  selectedIndex: _selectedIndex,
  onItemTapped: _onItemTapped,),
    );
  }
}
