// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
//
// final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
//
// class AuthService {
//   static Future<String> requestOtp(String phoneNumber) async {
//     final url = Uri.parse('$baseUrl/auth/request-otp');
//     try {
//       print('Requesting OTP for phone: $phoneNumber at $url');
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'phoneNumber': phoneNumber}),
//       );
//       print('Response status code: ${response.statusCode}');
//       print('Response body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print('Decoded data: $data');
//         return data['verificationId'];
//       } else {
//         print('Error: Failed to request OTP. Response: ${response.body}');
//         throw Exception('Failed to request OTP: ${response.body}');
//       }
//     } catch (error) {
//       print('Exception in requestOtp: $error');
//       rethrow;
//     }
//   }
//
//   static Future<String> verifyOtp(String verificationId, String otp) async {
//     final url = Uri.parse('$baseUrl/auth/verify-otp');
//     try {
//       print('Verifying OTP: $otp with verificationId: $verificationId at $url');
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'verificationId': verificationId, 'otp': otp}),
//       );
//       print('Response status code: ${response.statusCode}');
//       print('Response body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print('Decoded data: $data');
//         return data['token'];
//       } else {
//         print('Error: Failed to verify OTP. Response: ${response.body}');
//         throw Exception('Failed to verify OTP: ${response.body}');
//       }
//     } catch (error) {
//       print('Exception in verifyOtp: $error');
//       rethrow;
//     }
//   }
// }
