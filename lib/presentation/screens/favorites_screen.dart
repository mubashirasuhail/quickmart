import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import 'dart:async';

// Assuming product_detail.dart is in this path and accepts parameters
import 'package:quick_mart/presentation/screens/product_detail.dart';
import 'package:quick_mart/presentation/screens/home_screen.dart';
import 'package:quick_mart/presentation/screens/cart_screen.dart';
import 'package:quick_mart/presentation/widgets/bottom_navigation.dart';

// Import your AppColors for theme consistency
import 'package:quick_mart/presentation/widgets/color.dart'; // Ensure AppColors is defined here
import 'package:quick_mart/presentation/widgets/order_details.dart';

// --- FavoritesBloc and State (unchanged) ---
enum FavoritesStateStatus { initial, loading, loaded, error }

class FavoritesState {
  final FavoritesStateStatus status;
  final List<DocumentSnapshot> favoriteProducts;
  final String? errorMessage;

  FavoritesState({
    this.status = FavoritesStateStatus.initial,
    this.favoriteProducts = const [],
    this.errorMessage,
  });

  FavoritesState copyWith({
    FavoritesStateStatus? status,
    List<DocumentSnapshot>? favoriteProducts,
    String? errorMessage,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favoriteProducts: favoriteProducts ?? this.favoriteProducts,
      errorMessage: errorMessage,
    );
  }
}

abstract class FavoritesEvent {}

class LoadFavorites extends FavoritesEvent {}

class RemoveFavorite extends FavoritesEvent {
  final String productId;
  RemoveFavorite(this.productId);
}

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc() : super(FavoritesState()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<RemoveFavorite>(_onRemoveFavorite);
  }

  Future<void> _onLoadFavorites(LoadFavorites event, Emitter<FavoritesState> emit) async {
    emit(state.copyWith(status: FavoritesStateStatus.loading));
    try {
      var snapshot = await FirebaseFirestore.instance.collection('favorites').get();
      emit(state.copyWith(status: FavoritesStateStatus.loaded, favoriteProducts: snapshot.docs));
    } catch (e) {
      developer.log('Error loading favorites: $e', name: 'FavoritesLoad');
      emit(state.copyWith(status: FavoritesStateStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onRemoveFavorite(RemoveFavorite event, Emitter<FavoritesState> emit) async {
    try {
      await FirebaseFirestore.instance.collection('favorites').doc(event.productId).delete();
      add(LoadFavorites()); // Reload favorites after removal
    } catch (e) {
      developer.log('Error removing favorite: ${e.toString()}', name: 'FavoritesRemove');
      emit(state.copyWith(status: FavoritesStateStatus.error, errorMessage: e.toString()));
    }
  }
}

// --- Favorites Widget (BlocProvider setup - unchanged) ---
class Favorites extends StatelessWidget {
  const Favorites({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = FavoritesBloc();
        bloc.add(LoadFavorites()); // Trigger loading favorites on creation
        return bloc;
      },
      child: const FavoritesView(),
    );
  }
}

// --- FavoritesView (UI implementation - MODIFIED for larger images) ---
class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  int _selectedIndex = 2; // 0: Home, 1: Cart, 2: Favorites (Favorites is the third tab)

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen1()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CartPage()),
      );
    } else if (index == 2) {
      // Stay on Favorites page
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OrderDetails()),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favourites'),
        centerTitle: true,
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state.status == FavoritesStateStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == FavoritesStateStatus.error) {
            return Center(child: Text('Error: ${state.errorMessage ?? "Unknown Error"}'));
          } else if (state.favoriteProducts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'No favorites yet!',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Tap the heart icon on products to add them here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            return GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                // *** Adjusted childAspectRatio back to 0.75 for larger images ***
                // This makes the height proportionally greater relative to the width.
                childAspectRatio: 0.75,
              ),
              itemCount: state.favoriteProducts.length,
              itemBuilder: (context, index) {
                final Map<String, dynamic> productData =
                    state.favoriteProducts[index].data() as Map<String, dynamic>;
                final String productId = state.favoriteProducts[index].id;

                String productName = productData['productname'] ?? 'No Name';
                String productImage = productData['image'] ?? '';
                String productDescription = productData['description'] ?? 'No description available.';
                double productPrice = _getProductPrice(productData); // Use the helper function
                List<String> moreImages = (productData['moreImages'] is List)
                    ? List<String>.from(productData['moreImages'])
                    : [];

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
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
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: Image.network(
                                  productImage,
                                  fit: BoxFit.cover, // Ensures the image fills the available space
                                  loadingBuilder: (BuildContext context, Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset('assets/images/placeholder.png', fit: BoxFit.contain), // Using contain for placeholder
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16, // Matching ProductScreen font size
                                    ),
                                    maxLines: 1, // Restrict to 1 line with ellipsis
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹ ${productPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: AppColors.darkgreen, // Using AppColors for consistency
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14, // Matching ProductScreen font size
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red, size: 28),
                            onPressed: () {
                              context.read<FavoritesBloc>().add(RemoveFavorite(productId));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Removed from favorites."),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            tooltip: 'Remove from Favorites',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      // --- Bottom Navigation Bar ---
      bottomNavigationBar:BottomNavigationWidget(  selectedIndex: _selectedIndex,
  onItemTapped: _onItemTapped,)
    );
  }
}