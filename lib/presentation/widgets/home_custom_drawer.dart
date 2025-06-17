import 'package:flutter/material.dart';

import 'package:quick_mart/presentation/screens/privacy_policy.dart';

import 'package:quick_mart/presentation/screens/profile_view.dart';
import 'package:quick_mart/presentation/screens/rules_regulation.dart';
import 'package:quick_mart/presentation/widgets/color.dart';

class CustomDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userProfileImageUrl;
  final VoidCallback onSignOut;
  final Function(int) onItemTapped;
  final VoidCallback navigateToOrderDetails;

  const CustomDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userProfileImageUrl,
    required this.onSignOut,
    required this.onItemTapped,
    required this.navigateToOrderDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileView()),
              );
            },
            child: UserAccountsDrawerHeader(
              accountName: Text(
                userName,
                style: const TextStyle(color: Colors.white),
              ),
              accountEmail: Text(
                userEmail,
                style: const TextStyle(color: Colors.white70),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: userProfileImageUrl.startsWith('http')
                    ? NetworkImage(userProfileImageUrl) as ImageProvider
                    : AssetImage(userProfileImageUrl) as ImageProvider,
                onBackgroundImageError: (exception, stackTrace) {
                  // No setState in stateless – so handle fallback outside if needed
                },
                child: userProfileImageUrl == 'assets/images/placeholder.png' ||
                        userProfileImageUrl.isEmpty
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
              decoration: const BoxDecoration(
                color: AppColors.darkgreen,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Cart'),
            onTap: () {
              Navigator.pop(context);
              onItemTapped(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () {
              Navigator.pop(context);
              onItemTapped(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('My Orders'),
            onTap: () {
              Navigator.pop(context);
              navigateToOrderDetails();
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PrivacyPolicyPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.rule),
            title: const Text('Rules and Regulations'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RulesAndRegulationsPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              onSignOut();
            },
          ),
        ],
      ),
    );
  }
}