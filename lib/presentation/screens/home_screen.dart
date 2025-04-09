import 'package:flutter/material.dart';
import 'package:quick_mart/presentation/screens/cart_screen.dart';
import 'package:quick_mart/presentation/screens/favorites_screen.dart';
import 'package:quick_mart/presentation/screens/search_screen.dart';
import 'package:quick_mart/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import 'package:quick_mart/presentation/screens/login_screen.dart';
import 'package:quick_mart/presentation/widgets/banner.dart';
import 'package:quick_mart/presentation/widgets/icon.dart';
import 'package:quick_mart/presentation/screens/product_screen.dart';

class HomeScreen1 extends StatefulWidget {
  const HomeScreen1({super.key});

  @override
  State<HomeScreen1> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen1> {
  final auth = Authservice();
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> categories = [];
  final List<Map<String, dynamic>> _topProducts = [];
  bool isLoadingCategories = true;
  bool _isLoadingTopProducts = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    _loadTopProducts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchCategories() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('category').get();

      List<Map<String, dynamic>> fetchedCategories = querySnapshot.docs
          .map((doc) => {
                'name': doc['name'] ?? 'Unknown',
                'image': doc['image'] ?? '',
              })
          .toList();

      setState(() {
        categories = fetchedCategories;
        isLoadingCategories = false;
      });
    } catch (e) {
      developer.log('Error fetching categories: $e', name: 'CategoryFetch', error: e);
      setState(() {
        isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadTopProducts() async {
    setState(() {
      _isLoadingTopProducts = true;
    });
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection("topproducts").get();
      _topProducts.clear();
      for (var doc in snapshot.docs) {
        _topProducts.add(doc.data());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading top products: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingTopProducts = false;
      });
    }
  }

  void _signOut() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Do you want to logout?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await auth.signout();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Logged out successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (ctx) => const Loginscreen1()),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Logout failed: ${e.toString()}"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void _onSearch() {
    String searchText = searchController.text.trim();
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
      );
    }
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Favorites()),
      );
    }
  }

  Widget header() {
    return Row(
      children: [
        MyIconButton(icon: Icons.menu, pressed: () {}),
        const Spacer(),
        MyIconButton(icon: Icons.exit_to_app, pressed: _signOut),
      ],
    );
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
      child: isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
              ? const Center(child: Text("No categories found"))
              : ListView.builder(
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
                                  : const AssetImage('assets/images/google.jpg')
                                      as ImageProvider,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              categoryName,
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
                ),
    );
  }

  Widget topProductsGrid() {
    return _isLoadingTopProducts
        ? const Center(child: CircularProgressIndicator())
        : _topProducts.isEmpty
            ? const Center(child: Text("No top products found"))
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemCount: _topProducts.length,
                itemBuilder: (context, index) {
                  final product = _topProducts[index];
                  return Container(
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
                              product['image'],
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context, Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                return const Center(child: Icon(Icons.error_outline));
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
                                product['name'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Price: ${product['price']}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
  }

  Widget bottomNavigation(BuildContext context) {
    return BottomNavigationBar(
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
          icon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.amber[800],
      onTap: _onItemTapped,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header(),
              const SizedBox(height: 22),
              search(),
              const SizedBox(height: 20),
              category(context),
              const SizedBox(height: 20),
              const BannerExpl(),
              const SizedBox(height: 20),
              const Text('Our Top Products',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              topProductsGrid(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigation(context),
    );
  }
}

class MyIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback pressed;

  const MyIconButton({super.key, required this.icon, required this.pressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: pressed,
    );
  }
}

class BannerExpl extends StatelessWidget {
  const BannerExpl({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.orange[100],
      ),
      child: const Center(
        child: Text(
          'Amazing Offers and Discounts Here!',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      ),
    );
  }
}