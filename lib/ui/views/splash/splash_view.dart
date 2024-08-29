import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:oscar_stt/core/viewmodels/splash_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_view.dart';
import '../home/home_view.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String KEYLOGIN = "Login";




  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }


  _checkSessionAndNavigate() async {
    await Future.delayed(Duration(seconds: 3)); // 3 seconds delay

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool(KEYLOGIN);

    if (isLoggedIn != null && isLoggedIn) {
      String profileName = prefs.getString('profileName') ?? '';
      String profilePicUrl = prefs.getString('profilePicUrl') ?? '';
      String transcribedata = prefs.getString('transcribedata') ?? '';
      String tokenid = prefs.getString('tokenid') ?? '';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            profileName: profileName,
            profilePicUrl: profilePicUrl,
            transcribedata: transcribedata,
            tokenid: tokenid,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageSize = screenWidth * 0.75;

    return Scaffold(
      backgroundColor: Color.fromRGBO(220, 236, 235, 1.0),
      body: Center(
        child:
        SvgPicture.asset(
          'assets1/Oscar Logo with Text.svg',
          width: imageSize,
          height: imageSize * 0.75,
        ),

        // Image.asset(
        //   'assets1/Group 2.png',  // Path to your image asset
        //   height: 64.0,      // Adjust height to match the size of the original text if needed
        //   fit: BoxFit.contain, // Adjust the fit to control how the image fits in its box
        // ),
      ),
    );
  }
}
