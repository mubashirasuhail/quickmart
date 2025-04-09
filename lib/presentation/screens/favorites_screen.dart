import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

// Define the FavoritesState
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

// Define the FavoritesEvent
abstract class FavoritesEvent {}

class LoadFavorites extends FavoritesEvent {}

class RemoveFavorite extends FavoritesEvent {
  final String productId;
  RemoveFavorite(this.productId);
}

// Define the FavoritesBloc
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

// Favorites Widget
class Favorites extends StatelessWidget {
  const Favorites({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = FavoritesBloc();
        bloc.add(LoadFavorites());
        return bloc;
      },
      child: const FavoritesView(),
    );
  }
}

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Favorites')),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state.status == FavoritesStateStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == FavoritesStateStatus.error) {
            return Center(child: Text('Error: ${state.errorMessage ?? "Unknown Error"}'));
          } else if (state.favoriteProducts.isEmpty) {
            return const Center(child: Text('No favorites yet.'));
          } else {
            return ListView.builder(
              itemCount: state.favoriteProducts.length,
              itemBuilder: (context, index) {
                var product = state.favoriteProducts[index].data() as Map<String, dynamic>;
                return ListTile(
                  leading: product['image'] != null
                      ? Image.network(
                          product['image'],
                          width: 50,
                          height: 50,
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
                      : Image.asset('assets/images/placeholder.png', width: 50, height: 50),
                  title: Text(product['productname'] ?? 'No Name'),
                  subtitle: Text('₹${product['price']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      final productId = state.favoriteProducts[index].id;
                      context.read<FavoritesBloc>().add(RemoveFavorite(productId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Removed from favorites."),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}