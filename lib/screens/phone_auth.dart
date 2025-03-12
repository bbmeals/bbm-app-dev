// phone_auth_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({Key? key}) : super(key: key);

  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String? _verificationId;
  bool _isLoading = false;
  bool _codeSent = false;

  // Initiates phone number verification using Firebase's client SDK.
  Future<void> _verifyPhone() async {
    setState(() {
      _isLoading = true;
    });
    await _auth.verifyPhoneNumber(
      phoneNumber: _phoneController.text.trim(),
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // This callback is invoked on automatic code retrieval.
        await _auth.signInWithCredential(credential);
        await _sendTokenToBackend();
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Verification failed: ${e.message}')));
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _isLoading = false;
          _codeSent = true;
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // Uses the OTP provided by the user to complete the sign-in.
  Future<void> _submitOtp() async {
    if (_verificationId == null) return;
    setState(() {
      _isLoading = true;
    });
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );
      await _auth.signInWithCredential(credential);
      await _sendTokenToBackend();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('OTP verification failed: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Once signed in, retrieve the ID token and send it to the backend.
  Future<void> _sendTokenToBackend() async {
    User? user = _auth.currentUser;
    if (user == null) return;
    String idToken = (await user.getIdToken())!;


    try {
      // Replace with your backend URL.
      final response = await http.post(
        Uri.parse('http://<YOUR_BACKEND_HOST>:8080/verify-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );
      if (response.statusCode == 200) {
        // Successful verification on the backend.
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Login successful.')));
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        final error = jsonDecode(response.body)['error'];
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Backend error: $error')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error sending token: $e')));
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Login', style: AppTextStyles.headline2),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator()
              : _codeSent
              ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter the OTP sent to your phone', style: AppTextStyles.subtitle1),
              const SizedBox(height: 16),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'OTP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Verify', style: AppTextStyles.subtitle1.copyWith(color: Colors.white)),
                ),
              ),
            ],
          )
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter your phone number', style: AppTextStyles.subtitle1),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixText: '+1 ', // Adjust the country code if needed.
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _verifyPhone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Send OTP', style: AppTextStyles.subtitle1.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
