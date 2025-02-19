// // Flutter code for a cart screen similar to the provided image
// import 'package:flutter/material.dart';
//
//
//
//
// class CartApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: CartScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
//
// class CartScreen extends StatefulWidget {
//   @override
//   _CartScreenState createState() => _CartScreenState();
// }
//
// class _CartScreenState extends State<CartScreen> {
//   int quantity1 = 1;
//   int quantity2 = 1;
//   int quantity3 = 1;
//
//   void increment(int index) {
//     setState(() {
//       if (index == 1) quantity1++;
//       if (index == 2) quantity2++;
//       if (index == 3) quantity3++;
//     });
//   }
//
//   void decrement(int index) {
//     setState(() {
//       if (index == 1 && quantity1 > 1) quantity1--;
//       if (index == 2 && quantity2 > 1) quantity2--;
//       if (index == 3 && quantity3 > 1) quantity3--;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Cart'),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView(
//               children: [
//                 cartItem('Roasted Salmon', 7.95, quantity1, 1),
//                 cartItem('Roasted Salmon', 7.95, quantity2, 2),
//                 cartItem('Roasted Salmon', 7.95, quantity3, 3),
//                 Divider(),
//                 ListTile(
//                   leading: Icon(Icons.note_add),
//                   title: Text('Add a note'),
//                   onTap: () {
//                     // Add note functionality
//                   },
//                 ),
//                 Divider(),
//                 ListTile(
//                   title: Text('Subtotal'),
//                   trailing: Text('\$${(7.95 * (quantity1 + quantity2 + quantity3)).toStringAsFixed(2)}'),
//                 ),
//                 Divider(),
//                 recommendedItem(),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.orange,
//                 minimumSize: Size(double.infinity, 50),
//               ),
//               onPressed: () {
//                 // Checkout functionality
//               },
//               child: Text('Go to checkout', style: TextStyle(color: Colors.white)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget cartItem(String title, double price, int quantity, int index) {
//     return ListTile(
//       leading: Image.network('https://via.placeholder.com/50'),
//       title: Text(title),
//       subtitle: Text('\$${price.toStringAsFixed(2)}'),
//       trailing: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           IconButton(
//             icon: Icon(Icons.remove),
//             onPressed: () => decrement(index),
//           ),
//           Text('$quantity'),
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () => increment(index),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget recommendedItem() {
//     return ListTile(
//       leading: Image.network('https://via.placeholder.com/50'),
//       title: Text('Roasted Salmon'),
//       subtitle: Text('Roasted salmon with rice, vegetables and sauce.'),
//       trailing: IconButton(
//         icon: Icon(Icons.add_circle),
//         onPressed: () {
//           // Add recommended item functionality
//         },
//       ),
//     );
//   }
// }
