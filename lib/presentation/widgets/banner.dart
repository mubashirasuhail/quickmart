/*import 'package:flutter/material.dart';

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
}*/
import 'package:flutter/material.dart' hide CarouselController;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'dart:developer' as developer;

class BannerExpl extends StatefulWidget {
  const BannerExpl({super.key});

  @override
  State<BannerExpl> createState() => _BannerExplState();
}

class _BannerExplState extends State<BannerExpl> {
  List<String> _bannerImageUrls = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchBanners();
  }

  Future<void> _fetchBanners() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('banners')
              .orderBy('timestamp', descending: true)
              .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _errorMessage = 'No banners found.';
          _isLoading = false;
        });
        return;
      }

      final List<String> fetchedUrls = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data != null && data.containsKey('url') && data['url'] is String) {
          fetchedUrls.add(data['url'] as String);
        } else {
          developer.log('Banner document ${doc.id} missing "url" field or it\'s not a string.', name: 'BannerExpl');
        }
      }

      setState(() {
        _bannerImageUrls = fetchedUrls;
        _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      developer.log('Error fetching banners: $e', name: 'BannerExpl', error: e);
      setState(() {
        _errorMessage = 'Failed to load banners. Please try again later.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[200],
        ),
        child: const CircularProgressIndicator(),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.red[50],
        ),
        child: Text(
          _errorMessage,
          style: TextStyle(color: Colors.red[700]),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_bannerImageUrls.isEmpty) {
      return Container(
        height: 130,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.orange[100],
        ),
        child: const Center(
          child: Text(
            'No banners available.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ),
      );
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 150.0,
        // --- Key Change Here ---
        autoPlay: false, // Set this to false to disable auto-play
        // --- End Key Change ---
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        // autoPlayInterval: const Duration(seconds: 3), // These are ignored when autoPlay is false
        // autoPlayAnimationDuration: const Duration(milliseconds: 800),
        // autoPlayCurve: Curves.fastOutSlowIn,
        // pauseAutoPlayOnTouch: true,
        viewportFraction: 0.8,
      ),
      items: _bannerImageUrls.map((imageUrl) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
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
                  errorBuilder: (context, error, stackTrace) {
                    developer.log('Error loading banner image: $error', name: 'BannerExpl', error: error, stackTrace: stackTrace);
                    return Container(
                      color: Colors.red[100],
                      child: const Icon(Icons.broken_image, size: 50, color: Colors.red),
                    );
                  },
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}