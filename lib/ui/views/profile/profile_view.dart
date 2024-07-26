import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
//
//
// import 'package:demo_oscar/core/constants/app_colors.dart';
// import 'package:flutter/material.dart';
// import '../../shared/styles/text_style.dart';
//
// class UserProfile extends StatefulWidget {
//   const UserProfile({super.key});
//
//   @override
//   State<UserProfile> createState() => _UserProfileState();
// }
//
// class _UserProfileState extends State<UserProfile> {
//   String? profilePictureUrl;
//   String? profileName;
//
//   @override
//   Widget build(BuildContext context) {
//     var mq = MediaQuery.of(context).size;
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final double screenHeight = MediaQuery.of(context).size.height;
//     final double dynamicPadding = screenWidth * 0.05;
//
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: AppBar(
//         backgroundColor: AppColors.backgroundColor,
//         title: Center(
//           child: Text(
//             "Settings",
//             style: TextStyles.defaultTextStyle(
//               fontsize: mq.width * 0.08,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(dynamicPadding),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: mq.width * 0.17,
//                   height: mq.height * 0.08,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     border: Border.all(
//                       color: AppColors.buttonColor,
//                       width: 2.5,
//                     ),
//                     borderRadius: BorderRadius.circular(50),
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(50),
//                     child: profilePictureUrl != null
//                         ? Image.network(
//                       profilePictureUrl!,
//                       fit: BoxFit.cover,
//                     )
//                         : Image.asset(
//                       'assets1/Profile.png',
//                       width: mq.width * 0.10,
//                       height: mq.height * 0.10,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: mq.width * 0.05),
//                 Expanded(
//                   child: Text(
//                     profileName ?? "Profile Name",
//                     style: TextStyles.defaultTextStyle(
//                       fontsize: mq.width * 0.05,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
