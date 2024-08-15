import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_view.dart';

class SettingsScreen extends StatefulWidget {
  final String profileName;
  final String profilePicUrl;

  SettingsScreen({
    Key? key,
    required this.profileName,
    required this.profilePicUrl,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Color greenContainerColor = Color(0xFF51A09B);
  final Color signOutColor = Color(0xFF4D4D4D);

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color.fromRGBO(220, 236, 235, 1.0),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: mq.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: mq.height * 0.05),
            Center(
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: mq.width * 0.09,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: mq.height * 0.02),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            //     CircleAvatar(
            //       radius: mq.width * 0.09,
            //       backgroundImage: NetworkImage(widget.profilePicUrl),
            //       child: widget.profilePicUrl.isEmpty
            //           ? Icon(Icons.person, size: mq.width * 0.08)
            //           : null,
            //     ),
            //     SizedBox(width: mq.width * 0.03),
            //     Text(widget.profileName, style: TextStyle(fontSize: mq.width * 0.05)),
            //   ],
            // ),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: mq.width * 0.18, // Adjust size according to the radius
                  height: mq.width * 0.18, // Adjust size according to the radius
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: greenContainerColor, width: 2), // Red border with 2 width
                  ),
                  child: CircleAvatar(
                    radius: mq.width * 0.09,
                    backgroundImage: widget.profilePicUrl.isNotEmpty
                        ? NetworkImage(widget.profilePicUrl)
                        : null,
                    child: widget.profilePicUrl.isEmpty
                        ? Icon(Icons.person, size: mq.width * 0.08)
                        : null,
                  ),
                ),
                SizedBox(width: mq.width * 0.03),
                Text(widget.profileName, style: TextStyle(fontSize: mq.width * 0.05)),
              ],
            ),

            SizedBox(height: mq.height * 0.02),
            Container(
              width: double.infinity,
              height: mq.height * 0.2,
              padding: EdgeInsets.all(mq.width * 0.04),
              decoration: BoxDecoration(
                color: greenContainerColor,
                borderRadius: BorderRadius.circular(mq.width * 0.04),
              ),
              child: Stack(
                children: [
                  Row(
                    children: [
                      Container(
                        width: mq.width * 0.1,
                        height: mq.width * 0.1,
                        margin: EdgeInsets.only(bottom: mq.height * 0.1, left: mq.width * 0.02),
                        child: Icon(Icons.tips_and_updates_outlined, size: mq.width * 0.11, color: Colors.white),
                      ),
                      SizedBox(width: mq.width * 0.03),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Unlock time limit and many more features",
                            style: GoogleFonts.karla(
                              color: Colors.white,
                              fontSize: mq.width * 0.050,
                              fontWeight: FontWeight.w700,
                              height: 1.7,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: SizedBox(
                      width: mq.width * 0.4,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFD8E0DF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(mq.width * 0.08),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: mq.height * 0.015),
                        ),
                        child: Text('Get Oscar Pro', style: TextStyle(color: Colors.black, fontSize: mq.width * 0.05)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: mq.height * 0.02),
            Expanded(
              child: ListView.separated(
                itemCount: 4,
                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey),
                itemBuilder: (context, index) {
                  IconData iconData;
                  String title;
                  switch (index) {
                    case 0:
                      iconData = Icons.book_outlined;
                      title = "Terms of use";
                      break;
                    case 1:
                      iconData = Icons.privacy_tip_outlined;
                      title = "Privacy policy";
                      break;
                    case 2:
                      iconData = Icons.email_outlined;
                      title = "Email us";
                      break;
                    case 3:
                      iconData = Icons.share;
                      title = "Recommend us";
                      break;
                    default:
                      iconData = Icons.help;
                      title = "Item $index";
                  }
                  return ListTile(
                    leading: Icon(iconData, size: mq.width * 0.08),
                    title: Text(title, style: TextStyle(color: Colors.black, fontSize: mq.width * 0.05)),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.black, size: mq.width * 0.04),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: mq.width * 0.05, bottom: mq.height * 0.02),
              child: TextButton(
                onPressed: () {
                  _signOut(context);
                },
                child: Text(
                  'SignOut',
                  style: GoogleFonts.karla(
                    fontSize: mq.width * 0.045,
                    fontWeight: FontWeight.w400,
                    color: signOutColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _signOut(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginView()),
          (Route<dynamic> route) => false,
    );
  }
}


// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/material.dart';
//
// import '../auth/login_view.dart';
//
//
// class SettingsScreen extends StatelessWidget {
//   final Color greenContainerColor = Color(0xFF51A09B);
//   final Color signOutColor = Color(0xFF4D4D4D);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//       // appBar: AppBar(
//       //   // title: Text('Settings'),
//       // ),
//       backgroundColor: Color.fromRGBO(220, 236, 235, 1.0),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 40),
//             Center(
//               child: Text(
//                 'Settings',
//                 style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
//               ),
//             ),
//             SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 CircleAvatar(
//                   radius: 34,
//                   child: Icon(Icons.person, size: 32),
//                 ),
//                 SizedBox(width: 10),
//                 Text('Profile Name', style: TextStyle(fontSize: 18)),
//               ],
//             ),
//
//             SizedBox(height: 16),
//             Container(
//               width: 326,
//               height: 161,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: greenContainerColor,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Stack(
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         width: 40,
//                         height: 40,
//                         margin: const EdgeInsets.only(bottom: 80, left: 8,),
//                         child: Icon(Icons.tips_and_updates,
//                             size: 32, color: Colors.white),
//                       ),
//                       SizedBox(width: 10),
//                       Expanded(
//                         child: Align(
//                           alignment: Alignment.topLeft,
//                           child: Text(
//                             "Unlock time limit and many more features",
//                             style: GoogleFonts.karla(
//                               color: Colors.white,
//                               fontSize: 14,
//
//                               fontWeight: FontWeight.w700,
//                               height: 1.7,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Positioned(
//                     bottom: 0,
//                     right: 0,
//                     child: ElevatedButton(
//                       onPressed: () {},
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Color(0xFFD8E0DF),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(100),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 12),
//                       ),
//                       child: Text('Get Oscar Pro',
//                         style: TextStyle(color: Colors.black),),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 16),
//             Expanded(
//               child: ListView.separated(
//                 itemCount: 4,
//                 separatorBuilder: (context, index) =>
//                     Divider(height: 1, color: Colors.grey),
//                 itemBuilder: (context, index) {
//                   IconData iconData;
//                   String title;
//                   switch (index) {
//                     case 0:
//                       iconData = Icons.book;
//                       title = "Terms of use";
//                       break;
//                     case 1:
//                       iconData = Icons.privacy_tip;
//                       title = "Privacy policy";
//                       break;
//                     case 2:
//                       iconData = Icons.email;
//                       title = "Email us";
//                       break;
//                     case 3:
//                       iconData = Icons.recommend;
//                       title = "Recommend us";
//                       break;
//                     default:
//                       iconData = Icons.help;
//                       title = "Item $index";
//                   }
//                   return ListTile(
//                     leading: Icon(iconData, color: Colors.black, size: 32),
//                     title: Text(title, style: TextStyle(color: Colors.black)),
//                     trailing: Icon(
//                         Icons.arrow_forward_ios, color: Colors.black),
//                   );
//                 },
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 19.0, bottom: 16.0),
//               child: TextButton(
//                 onPressed: () {
//                   _signOut(context);
//                 },
//                 child: Text(
//                   'Sign out',
//                   style: GoogleFonts.karla(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w400,
//                     color: signOutColor,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   void _signOut(BuildContext context) {
//
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (context) => LoginView()),
//           (Route<dynamic> route) => false,
//     );
//   }
// }