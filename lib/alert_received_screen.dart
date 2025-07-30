import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AlertReceivedScreen extends StatelessWidget {
  final String userName;
  final double lat;
  final double lng;
  final String alertTime;

  AlertReceivedScreen({
    required this.userName,
    required this.lat,
    required this.lng,
    required this.alertTime,
  });

  // void _callUser() async {
  //   const phoneNumber = 'tel:+8801720616636'; // TODO: Replace with real user's phone number from Firestore
  //   if (await canLaunchUrl(Uri.parse(phoneNumber))) {
  //     await launchUrl(Uri.parse(phoneNumber));
  //   }
  // }
  void _callUser(BuildContext context, String phoneNumber) async {
  final Uri telUri = Uri(scheme: 'tel', path: phoneNumber);

  try {
    final launched = await launchUrl(
      telUri,
      mode: LaunchMode.externalApplication, // Ensures it opens the phone app
    );

    if (!launched) {
      _showDialError(context, phoneNumber);
    }
  } catch (e) {
    _showDialError(context, phoneNumber);
  }
}

void _showDialError(BuildContext context, String number) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Sorry, your device does not support automatic calling.\n'
        'Please dial manually: $number',
        style: TextStyle(fontSize: 16),
      ),
      duration: Duration(seconds: 5),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final CameraPosition _initialPosition = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 14,
    );

    return Scaffold(
      appBar: AppBar(title: Text('Emergency Alert')),
      body: Column(
        children: [
          ListTile(
            title: Text('Alert from $userName'),
            subtitle: Text('Time: $alertTime'),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              markers: {
                Marker(
                  markerId: MarkerId('alert'),
                  position: LatLng(lat, lng),
                  infoWindow: InfoWindow(title: 'Emergency Location'),
                )
              },
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: ElevatedButton.icon(
          //     onPressed: _callUser,
          //     icon: Icon(Icons.phone),
          //     label: Text('Call $userName'),
          //   ),
          Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
          onPressed: () => _callUser(context, userName),
          icon: Icon(Icons.phone),
          label: Text('Call $userName'),
          ),
          ),
        ],
      ),
    );
  }
}
