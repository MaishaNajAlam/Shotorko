import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String verificationId = '';
  bool otpSent = false;
  bool isLoading = false;
  String errorMessage = '';

  Future<void> sendOTP() async {
    final phone = phoneController.text.trim();

    if (!phone.startsWith('+')) {
      setState(() {
        errorMessage = 'Enter phone number with country code (e.g., +880...)';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
            await _saveFCMAndLocation();
            setState(() => isLoading = false);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } catch (e) {
            setState(() {
              errorMessage = 'Auto-verification failed: $e';
              isLoading = false;
            });
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            errorMessage = e.message ?? 'Verification failed';
            isLoading = false;
          });
        },
        codeSent: (String verId, int? resendToken) {
          setState(() {
            verificationId = verId;
            otpSent = true;
            isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to send OTP: $e';
        isLoading = false;
      });
    }
  }

  Future<void> verifyOTP() async {
    final smsCode = otpController.text.trim();
    if (smsCode.length != 6) {
      setState(() {
        errorMessage = 'OTP must be 6 digits';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);
      await _saveFCMAndLocation();
      setState(() => isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'OTP verification failed';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An unknown error occurred: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _saveFCMAndLocation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() {
          errorMessage = 'Location permission denied';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': fcmToken,
        'location': {
          'lat': position.latitude,
          'lng': position.longitude,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to save data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shotorko - Login')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  otpSent ? 'Enter the OTP sent to your phone' : 'Enter your phone number',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 20),
                if (!otpSent) ...[
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number (+880...)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : sendOTP,
                    icon: Icon(Icons.send),
                    label: Text('Send OTP'),
                    style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                  ),
                ] else ...[
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'OTP Code',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : verifyOTP,
                    icon: Icon(Icons.check),
                    label: Text('Verify OTP'),
                    style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                  ),
                ],
                if (isLoading) ...[
                  SizedBox(height: 20),
                  CircularProgressIndicator(),
                ],
                if (errorMessage.isNotEmpty) ...[
                  SizedBox(height: 20),
                  Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
