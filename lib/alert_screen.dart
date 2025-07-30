import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AlertScreen extends StatefulWidget {
  @override
  _AlertScreenState createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _sendingAlert = false;
  String _status = '';

  String? _selectedEmergencyType;
  final List<String> _emergencyTypes = [
    'Police',
    'Fire',
    'Ambulance',
    'Other',
  ];

  Future<String> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      Placemark place = placemarks.first;
      return "${place.subLocality}, ${place.locality}";
    } catch (e) {
      return "Unknown location";
    }
  }

  Future<void> _sendEmergencyAlert() async {
    if (_selectedEmergencyType == null) {
      setState(() {
        _status = "Please select an emergency type.";
      });
      return;
    }

    setState(() {
      _sendingAlert = true;
      _status = 'Getting location...';
    });

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _status = 'Location permission denied';
          _sendingAlert = false;
        });
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _status = 'Location permission permanently denied';
        _sendingAlert = false;
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _status = 'Getting address...';
      });

      String address =
          await _getAddressFromCoordinates(position.latitude, position.longitude);

      String userId = _auth.currentUser?.uid ?? 'unknown_user';

      setState(() {
        _status = 'Sending alert...';
      });

      await FirebaseFirestore.instance.collection('alerts').add({
        'emergencyType': _selectedEmergencyType,
        'location': {
          'lat': position.latitude,
          'lng': position.longitude,
        },
        'address': address,
        'status': 'New',
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userId,
      });

      setState(() {
        _status = 'Alert sent successfully!';
        _sendingAlert = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to send alert: $e';
        _sendingAlert = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Emergency Alert'),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Emergency Type',
                  border: OutlineInputBorder(),
                ),
                value: _selectedEmergencyType,
                items: _emergencyTypes
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedEmergencyType = val;
                  });
                },
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _sendingAlert ? null : _sendEmergencyAlert,
                icon: Icon(Icons.warning, size: 28),
                label: Text(
                  _sendingAlert ? 'Sending...' : 'Send Emergency Alert',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
              ),
              SizedBox(height: 24),
              Text(
                _status,
                style: TextStyle(
                  fontSize: 16,
                  color: _status.startsWith('Failed') ? Colors.red : Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
