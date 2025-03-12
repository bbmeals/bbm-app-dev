// import 'package:built_better_app/theme/app_theme.dart';
// import 'package:flutter/material.dart';
// import 'screens/homepage.dart';
// import 'screens/menu_page.dart';
//
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Built Better App',
//       debugShowCheckedModeBanner: false,
//       theme: buildAppTheme(),
//       home: const HomePage(),
//       routes: {
//         '/menu': (context) => MenuPage(),
//       },
//     );
//   }
// }

// Update main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:built_better_app/theme/app_theme.dart';
import 'package:built_better_app/providers/cart_provider.dart';
import 'package:built_better_app/screens/homepage.dart';
import 'package:built_better_app/screens/menu_page.dart';
import 'package:built_better_app/screens/cart_page.dart';
import 'package:built_better_app/screens/login.dart';
import 'package:built_better_app/screens/otp.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:built_better_app/screens/phone_auth.dart';
import 'package:built_better_app/screens/checkout_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Built Better App',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        initialRoute: '/',
        routes: {
          // '/': (context) => const HomePage(),
          '/menu': (context) => MenuPage(),
          '/cart': (context) => const CartPage(),
          '/': (context) => const PhoneNumberScreen(),
          // '/': (context) => MenuPage(),
          // '/otp': (context) => const OtpScreen(),
          '/otp': (context) {
            final verificationId = ModalRoute.of(context)?.settings.arguments as String;
            return OtpScreen(verificationId: verificationId);
          },
          '/home': (context) => const HomePage(),
          // '/': (context) => const PhoneAuthScreen(),
          '/checkout': (context) => const CheckoutPage(),

        },
      ),
    );
  }
}