import 'package:flutter/material.dart';
import 'package:quick_mart/presentation/screens/address.dart';
import 'package:quick_mart/presentation/screens/address1.dart';
import 'package:quick_mart/presentation/screens/checkout.dart';
import 'package:quick_mart/presentation/screens/login_screen.dart';
import 'package:quick_mart/presentation/screens/order_confirmation.dart';
import 'package:quick_mart/presentation/widgets/color.dart'; // Your custom colors
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quick_mart/presentation/widgets/order_details.dart'; // Import Firebase Auth

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // Initialize with default or empty values, these will be overwritten by Firebase data
  String _userName = 'Loading Name...';
  String _userEmail = 'Loading Email...';
 // String _userPhone = 'N/A'; // Phone number might not be available
  String _userProfileImageUrl = ''; // Will store Firebase photoURL or a placeholder

  @override
  void initState() {
    super.initState();
    _loadUserDataFromFirebase(); // Fetch user data from Firebase
  }

  void _loadUserDataFromFirebase() {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in, update state with their data
      setState(() {
        _userName = user.displayName ?? 'No Name Set'; // Firebase display name
        _userEmail = user.email ?? 'No Email Available'; // Firebase email
      //  _userPhone = user.phoneNumber ?? 'N/A'; // Firebase phone number (if available)

        // Use Firebase photo URL if available, otherwise use a placeholder
        if (user.photoURL != null && user.photoURL!.isNotEmpty) {
          _userProfileImageUrl = user.photoURL!;
        } else {
          // Ensure 'assets/images/placeholder.png' exists in your pubspec.yaml
          // and in your assets folder
          _userProfileImageUrl = 'assets/images/placeholder.png';
        }
      });
    } else {
      // No user is logged in
      setState(() {
        _userName = 'Guest User';
        _userEmail = 'Please Log In';
      //  _userPhone = 'N/A';
        _userProfileImageUrl = 'assets/images/placeholder.png';
      });
    }
  }

  // Function to handle user logout


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       // title: const Text('My Profile'),
        backgroundColor: AppColors.darkgreen, // Use your app's primary color
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- Profile Header Section ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            decoration: const BoxDecoration(
              color: AppColors.darkgreen, // Consistent background color
              // Add a subtle curve or rounded bottom if desired
              // borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50, // Larger radius for profile picture
                  backgroundColor: Colors.white,
                  // Dynamically choose between NetworkImage or AssetImage
                  backgroundImage: _userProfileImageUrl.startsWith('http')
                      ? NetworkImage(_userProfileImageUrl) as ImageProvider
                      : AssetImage(_userProfileImageUrl) as ImageProvider,
                  onBackgroundImageError: (exception, stackTrace) {
                    // Fallback to local placeholder if network image fails or is bad
                    if (mounted) {
                      setState(() {
                        _userProfileImageUrl = 'assets/images/placeholder.png';
                      });
                    }
                  },
                  // Show person icon if placeholder or empty URL
                  child: _userProfileImageUrl == 'assets/images/placeholder.png' || _userProfileImageUrl.isEmpty
                      ? const Icon(Icons.person, size: 60, color: Colors.grey)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _userEmail,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
               // const SizedBox(height: 5),
              /*  Text(
                  _userPhone,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),*/
              ],
            ),
          ),
          // --- End Profile Header Section ---

          const SizedBox(height: 20), // Spacing below the header

          // --- Profile Options (ListView) ---
          Expanded( // Expanded makes ListView take available space
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('My Address'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SavedAddressesListPage()),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Go to Address Page')),
                    );
                  },
                ),
                const Divider(), // Visual separator
                ListTile(
                  leading: const Icon(Icons.receipt),
                  title: const Text('My Orders'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                     Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OrderDetails()),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Go to My Orders Page')),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to log out?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(dialogContext).pop(); // Dismiss dialog
                              },
                            ),
                            TextButton(
                              child: const Text('Logout'),
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (ctx) => const Loginscreen1()),);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                // You can add more list items here if needed
              ],
            ),
          ),
          // --- End Profile Options ---
        ],
      ),
    );
  }
}

