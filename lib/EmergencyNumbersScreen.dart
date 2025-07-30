import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyNumbersScreen extends StatelessWidget {
  final List<Map<String, String>> numbers = [
    {'name': 'Police', 'number': '999'},
    {'name': 'Fire Service', 'number': '199'},
    {'name': 'Ambulance', 'number': '199'},
    {'name': 'Ambulance (Alternative)', 'number': '16666'},
    {'name': 'Road Accident Emergency', 'number': '109'},
    {'name': 'Women\'s Helpline', 'number': '+8801720616636'},
  ];

  Future<void> _callNumber(BuildContext context, String number) async {
    final Uri telUri = Uri(scheme: 'tel', path: number);

    try {
      final launched = await launchUrl(
        telUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sorry, your device does not support automatic calling.\nPlease dial manually: $number',
              style: TextStyle(fontSize: 16),
            ),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sorry, your device does not support automatic calling.\nPlease dial manually: $number',
            style: TextStyle(fontSize: 16),
          ),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Numbers'),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: ListView.separated(
        itemCount: numbers.length,
        separatorBuilder: (_, __) => Divider(color: Colors.grey[300]),
        itemBuilder: (context, index) {
          final item = numbers[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.phone, color: Colors.white),
            ),
            title: Text(item['name']!),
            subtitle: Text(item['number']!),
            onTap: () => _callNumber(context, item['number']!),
            contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          );
        },
      ),
    );
  }
}
