import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quick_mart/presentation/widgets/banner.dart';
import 'package:quick_mart/presentation/widgets/icon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true; // To track loading state

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  // Fetch data from Firestore
  Future<void> fetchCategories() async {
    try {
      // Fetch data from the 'category' collection
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('category').get();

      // Map Firestore documents to list of categories
      List<Map<String, dynamic>> fetchedCategories = querySnapshot.docs
          .map((doc) => {
                'name': doc['name'] ?? 'Unknown',
                'image': doc['image'] ?? '', // Assuming 'image' is a URL
              })
          .toList();

      // Update state with fetched categories
      setState(() {
        categories = fetchedCategories;
        isLoading = false; // Data fetched, stop loading
      });
    } catch (e) {
      // Handle any errors
      setState(() {
        isLoading = false; // In case of error, stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    // App Bar
                    Row(
                      children: [
                        MyIconButton(
                          icon: Icons.menu,
                          pressed: () {},
                        ),
                        const Spacer(),
                        MyIconButton(
                          icon: Icons.trolley,
                          pressed: () {},
                        ),
                      ],
                    ),
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 22),
                      child: TextField(
                        decoration: InputDecoration(
                          filled: true,
                          prefixIcon: const Icon(Icons.search),
                          fillColor: Colors.white,
                          border: InputBorder.none,
                          hintText: 'Search Product',
                          hintStyle: const TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    // Categories Section
                    SizedBox(
                      height: 120,
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : categories.isEmpty
                              ? const Center(child: Text("No categories found"))
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: categories.length,
                                  itemBuilder: (context, index) {
                                    String imageUrl = categories[index]['image'];
                                    String categoryName = categories[index]['name'];

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          // CircleAvatar with image
                                          CircleAvatar(
                                            radius: 40,
                                            backgroundImage: (imageUrl.isNotEmpty)
                                                ? NetworkImage(imageUrl)
                                                : const AssetImage('assets/images/google.jpg') as ImageProvider,
                                          ),
                                          const SizedBox(height: 5),
                                          // Category name
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
                                    );
                                  },
                                ),
                    ),

                    const SizedBox(height: 20),
                    const BannerExpl(),
                    const SizedBox(height: 20),
                    const Text(
                      'Our Top Products',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // Sample Grid for Products (Replace with dynamic content later)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/iconlogo.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
