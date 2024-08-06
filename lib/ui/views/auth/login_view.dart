import 'dart:convert';

import 'package:google_fonts/google_fonts.dart';
import 'package:oscar_stt/ui/views/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_colors.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  var googleSignInAccount;

  Future<void> GoogleLogin() async {
    print('Google login method called');

    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/userinfo.profile',
        'openid', // Ensure openid scope is included
      ],

    );

    // _googleSignIn.signIn().then((result) {
    //   result?.authentication.then((googleKey) {
    //     String? accessToken = googleKey.accessToken;
    //     String? idToken = googleKey.idToken;
    //     print("ID Token: $idToken");
    //     print("Access Token: $accessToken");
    //     print("Google Sign-In successful");
    //     print("Signed in as: ${_googleSignIn.currentUser?.displayName}");
    //     print("Image link: ${_googleSignIn.currentUser?.photoUrl}");
    //     print("Email-id: ${_googleSignIn.currentUser?.email}");
    //     print("ID: ${_googleSignIn.currentUser?.id}");
    //
    //     if (accessToken != null) {
    //       _authWithMeraki(accessToken, context);
    //     } else {
    //       print("ACCESS TOKEN is NULL");
    //     }
    //
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Successfully Logged In')),
    //     );
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => HomePage(),
    //       ),
    //     );
    //   }).catchError((err) {
    //     print('Inner error: $err');
    //   });
    // }).catchError((err) {
    //   print('Error occurred: $err');
    // });

    try {
      var result = await _googleSignIn.signIn();
      print(result);

      googleSignInAccount = result;
      if (result != null) {
        GoogleSignInAuthentication googleAuth = await result.authentication;
        String? accessToken = googleAuth.accessToken;
        String? idToken = googleAuth.idToken;
        print("ID Token: $idToken");
        print("Access Token: $accessToken");
        print("Google Sign-In successful");
        print("Signed in as: ${result.displayName}");
        print("Image link: ${result.photoUrl}");
        print("Email-id: ${result.email}");
        print("Authentication id: ${result.serverAuthCode}");
        print("ID: ${result.id}");
        print("Google Sign-In successful");

        if (accessToken != null) {
          await _authWithMeraki(accessToken, context);
        }else {
          print("ACCESS TOKEN is NULL");
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully Logged In')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      } else {
        print("Sign-in canceled");
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> _authWithMeraki(String accessToken, BuildContext context) async {
    final String apiUrl = 'https://dev-oscar.merakilearn.org/api/v1/auth/login/google';

    final response = await http.post(
     Uri.parse(apiUrl),
     headers: {
       'Context-Type' : 'application/json',
     } ,
      body: json.encode({
        'access_token' : accessToken,
      })
    );
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      print("Backend Authentication successful: $responseBody");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication failed'))
      );
    }
  }

  PageController _pageController = PageController();
  int _currentPage = 0;

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _onDashTap(int page) {
    _pageController.animateToPage(
      page,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final imageSize = screenWidth * 0.75;
    final padding = screenWidth * 0.05;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: screenHeight * 0.2),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  _buildPage1(imageSize),
                  _buildPage2(imageSize),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _onDashTap(0),
                  child: Container(
                    width: screenWidth * 0.09,
                    height: screenHeight * 0.01,
                    decoration: BoxDecoration(
                      color: _currentPage == 0 ? AppColors.ButtonColor2 : Colors.grey[400],
                      borderRadius: BorderRadius.circular(20), // Set the border radius
                    ),                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                GestureDetector(
                  onTap: () => _onDashTap(1),
                  child: Container(
                    width: screenWidth * 0.09,
                    height: screenHeight * 0.01,
                    decoration: BoxDecoration(
                      color: _currentPage == 1 ? AppColors.ButtonColor2 : Colors.grey[400],
                      borderRadius: BorderRadius.circular(20), // Set the border radius
                    ),                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Container(
                height: screenHeight * 0.06,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.0),
                  border: Border.all(color: AppColors.ButtonColor2, width: 1.0),
                ),
                child: InkWell(
                  onTap: () {
                    GoogleLogin();
                  },
                  borderRadius: BorderRadius.circular(100.0),
                  // splashColor:  Colors.pink,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.ButtonColor2,
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015, horizontal: screenWidth * 0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          // color: AppColors.ButtonColor2,
                          height: screenHeight * 0.06,
                          width: screenWidth * 0.1,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                          child: Image.asset(
                            'assets1/g2.png',
                            height: screenHeight * 0.05,
                            width: screenHeight * 0.05,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Text(
                          'Login with Google',
                          style: GoogleFonts.karla(color: Colors.white, fontSize: screenWidth * 0.04),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage1(double imageSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Image.asset(
            'assets1/Frame.png',
            width: imageSize,
            height: imageSize,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 20.0),
        Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              Text(
                'Speech your thoughts',
                style: GoogleFonts.spectral(
                  fontSize: 25.0,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Text(
                'You can download or save You can download or save You can download or save',
                style: GoogleFonts.karla(
                  fontSize: 15.0,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPage2(double imageSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Image.asset(
            'assets1/Frame2.png',
            width: imageSize,
            height: imageSize * 0.85,
          ),
        ),
        SizedBox(height: 20.0),
        Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              Text(
                "Let AI Do it's magic",
                style: GoogleFonts.spectral(
                  fontSize: 25.0,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Text(
                'You can download or save You can download or save You can download or save',
                style: GoogleFonts.karla(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}



