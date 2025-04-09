import 'package:flutter/material.dart';
import 'package:quick_mart/presentation/screens/product_screen.dart';
import 'package:quick_mart/presentation/widgets/banner.dart';
import 'package:quick_mart/presentation/widgets/icon.dart';

class HomeScreenWidgets {
  final TextEditingController searchController;
  final int selectedIndex;
  final bool isLoading;
  final List<Map<String, dynamic>> categories;
  final VoidCallback signOut;
  final Function(int) onItemTapped;
  final VoidCallback onSearch;

  HomeScreenWidgets({
    required this.searchController,
    required this.selectedIndex,
    required this.isLoading,
    required this.categories,
    required this.signOut,
    required this.onItemTapped,
    required this.onSearch,
  });

  Widget buildHomeScreen(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header(),
                const SizedBox(height: 22),
                search(),
                const SizedBox(height: 20),
                category(),
                const SizedBox(height: 20),
                const BannerExpl(),
                const SizedBox(height: 20),
                const Text('Our Top Products'),
                const SizedBox(height: 20),
                topProducts(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigation(),
    );
  }

  BottomNavigationBar bottomNavigation() {
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
      currentIndex: selectedIndex,
      selectedItemColor: Colors.amber[800],
      onTap: onItemTapped,
    );
  }

  SizedBox category() {
    return SizedBox(
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
                                  : const AssetImage(
                                          'assets/images/placeholder.png') // Placeholder
                                      as ImageProvider,
                              child: imageUrl.isEmpty
                                  ? const Icon(Icons.image,
                                      size: 40, color: Colors.grey) // Placeholder Icon
                                  : null,
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

  TextField search() {
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
          icon: const Icon(Icons.search, color: Colors.grey), // Added search icon
          onPressed: onSearch,
        ),
      ),
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSearch(),
    );
  }

  Row header() {
    return Row(
      children: [
        MyIconButton(icon: Icons.menu, pressed: () {}),
        const Spacer(),
        MyIconButton(icon: Icons.exit_to_app, pressed: signOut),
      ],
    );
  }

  GridView topProducts() {
    return GridView.builder(
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
    );
  }
}