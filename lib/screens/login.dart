import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';


class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({Key? key}) : super(key: key);

  @override
  _PhoneNumberScreenState createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // For now, simply navigate to the OTP screen.
  void _sendOtp() async {
    print('Inside _sendOtp');
    String phone = '+1${_phoneController.text.trim()}'; // Adjust country code accordingly.
    print('Phone number: $phone');

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('Verification completed. Received credential: $credential');
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            print('Sign-in with credential successful.');
            Navigator.pushReplacementNamed(context, '/home');
          } catch (e) {
            print('Error during signInWithCredential: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Sign in error: $e")),
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: ${e.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Verification Failed: ${e.message}")),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          print('Code sent. VerificationId: $verificationId, ResendToken: $resendToken');
          Navigator.pushNamed(
            context,
            '/otp',
            arguments: verificationId,
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Code auto-retrieval timeout for verificationId: $verificationId');
          // Optionally handle the timeout.
        },
      );
    } catch (error) {
      print('Error calling verifyPhoneNumber: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error initiating phone verification: $error")),
      );
    }
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your phone number',
                style: AppTextStyles.subtitle1,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixText: '+1 ', // Include a country code prefix if needed.
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Send OTP',
                    style: AppTextStyles.subtitle1.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
