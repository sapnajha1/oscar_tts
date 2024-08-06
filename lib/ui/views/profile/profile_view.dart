import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import '../auth/login_view.dart';


class SettingsScreen extends StatelessWidget {
  final Color greenContainerColor = Color(0xFF51A09B);
  final Color signOutColor = Color(0xFF4D4D4D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // appBar: AppBar(
      //   // title: Text('Settings'),
      // ),
      backgroundColor: Color.fromRGBO(220, 236, 235, 1.0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            Center(
              child: Text(
                'Settings',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 34,
                  child: Icon(Icons.person, size: 32),
                ),
                SizedBox(width: 10),
                Text('Profile Name', style: TextStyle(fontSize: 18)),
              ],
            ),

            SizedBox(height: 16),
            Container(
              width: 326,
              height: 161,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: greenContainerColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(bottom: 80, left: 8,),
                        child: Icon(Icons.tips_and_updates,
                            size: 32, color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Unlock time limit and many more features",
                            style: GoogleFonts.karla(
                              color: Colors.white,
                              fontSize: 14,

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
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFD8E0DF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      child: Text('Get Oscar Pro',
                        style: TextStyle(color: Colors.black),),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: 4,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: Colors.grey),
                itemBuilder: (context, index) {
                  IconData iconData;
                  String title;
                  switch (index) {
                    case 0:
                      iconData = Icons.book;
                      title = "Terms of use";
                      break;
                    case 1:
                      iconData = Icons.privacy_tip;
                      title = "Privacy policy";
                      break;
                    case 2:
                      iconData = Icons.email;
                      title = "Email us";
                      break;
                    case 3:
                      iconData = Icons.recommend;
                      title = "Recommend us";
                      break;
                    default:
                      iconData = Icons.help;
                      title = "Item $index";
                  }
                  return ListTile(
                    leading: Icon(iconData, color: Colors.black, size: 32),
                    title: Text(title, style: TextStyle(color: Colors.black)),
                    trailing: Icon(
                        Icons.arrow_forward_ios, color: Colors.black),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 19.0, bottom: 16.0),
              child: TextButton(
                onPressed: () {
                  _signOut(context);
                },
                child: Text(
                  'Sign out',
                  style: GoogleFonts.karla(
                    fontSize: 16,
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
    // Perform your sign-out logic here
    // For example, clear user session, tokens, etc.

    // Navigate to the LoginPage
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginView()),
          (Route<dynamic> route) => false,
    );
  }
}