import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'alert_screen.dart';
import 'emergency_contacts_screen.dart';
import 'EmergencyNumbersScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    saveUserFcmToken(); // Save token on startup
  }

  Future<void> saveUserFcmToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fcmToken': fcmToken,
          'phone': user.phoneNumber ?? '',
        }, SetOptions(merge: true));
        print('FCM token saved for user: ${user.uid}');
      }
    } catch (e) {
      print('Failed to save FCM token: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shotorko Dashboard'),
        backgroundColor: Colors.redAccent,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.redAccent),
              child: Text(
                'Shotorko Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.contacts),
              title: Text('Manage Emergency Contacts'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EmergencyContactsScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Emergency Numbers'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EmergencyNumbersScreen()));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About App'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Shotorko v1.0 – Stay Safe!')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Help section coming soon.')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Settings coming soon!')),
                );
              },
            ),
            // ListTile(
            //   leading: Icon(Icons.logout),
            //   title: Text('Logout'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       SnackBar(content: Text('Logout functionality coming soon.')),
            //     );
            //   },
            // ),
            ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () async {
            Navigator.pop(context);
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pushReplacementNamed('/auth');
           },
          ),
          ],
        ),
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: Icon(Icons.warning_amber_rounded),
          label: Text(
            'Send Emergency Alert',
            style: TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AlertScreen()));
          },
        ),
      ),
    );
  }
}
