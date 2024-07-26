import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:oscar_stt/core/viewmodels/splash_viewmodel.dart';
import '../auth/login_view.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  _checkSessionAndNavigate() async {
    final splashViewModel = Provider.of<SplashViewModel>(context, listen: false);
    await splashViewModel.initialize();
    await Future.delayed(Duration(seconds: 3), () {}); // 3 seconds delay

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(220, 236, 235, 1.0),
      body: Center(
        child: Text(
          'Oscar',
          style: GoogleFonts.spectral(
            fontSize: 64.0,
            color: Color.fromRGBO(81, 160, 155, 1.0),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
