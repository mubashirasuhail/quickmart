import 'package:flutter/material.dart';
import 'package:quick_mart/presentation/screens/privacy_policy.dart';
import 'package:quick_mart/presentation/screens/rules_regulation.dart';


class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Privacy Policy'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text('Rules and Regulations'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RulesAndRegulationsPage()),
              );
            },
          ),
          Divider(),
          // Add other settings options here
        ],
      ),
    );
  }
}