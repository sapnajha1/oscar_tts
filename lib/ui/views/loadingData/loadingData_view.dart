// import 'package:flutter/material.dart';
//
// import '../../../core/constants/app_colors.dart';
//
// class LoadingPage extends StatelessWidget {
//
//   @override
//   Widget build(BuildContext context) {
//     var mq = MediaQuery.of(context).size;
//
//     return Scaffold(
//
//       backgroundColor: AppColors.backgroundColor,
//       appBar:
//       AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         backgroundColor: AppColors.backgroundColor,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(mq.width * 0.04),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(height: mq.height * 0.10),
//               Image.asset(
//                 'assets1/Waiting.png',
//                 width: mq.width * 0.8,
//                 height: mq.width * 0.8,
//               ),
//               SizedBox(height: mq.height * 0.05),
//               LinearProgressIndicator(
//                 // value: _controller.value,
//                 color: Color.fromRGBO(81, 160, 155, 1.0),
//                 backgroundColor: Colors.white,
//                 minHeight: 30,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               SizedBox(height: mq.height * 0.05),
//               Text(
//                 'Please wait a moment while we prepare the text for you',
//                 style: TextStyle(
//                   fontSize: mq.width * 0.05,
//                   fontWeight: FontWeight.normal,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//
//     );
//   }
// }
//
//
//
//
//
