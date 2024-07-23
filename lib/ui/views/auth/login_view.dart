import 'package:oscar_stt/ui/views/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../../core/viewmodels/auth_viewmodel.dart';
import '../../shared/components/custom_button.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {

  var  googleSignInAccount;

  GoogleLogin() async {
    print('google login method called');

    GoogleSignIn _googleSignIn = GoogleSignIn(
        // clientId:
        // "127094237249-oomrst4eg2ir2q13dum6g4su6nb78n4f.apps.googleusercontent.com"
    );
    try {
      var result = await _googleSignIn.signIn();
      print(result);

      googleSignInAccount = result;
      if (result != null){
        print("Signed in as: ${result}");
        print("Signed in as: ${result.displayName}");
        print("image link: ${result.photoUrl}");
        print("Email-id: ${result.email}");
        print("Authentication id: ${result.serverAuthCode}");
        print("${result.id}");

        print("mydata $googleSignInAccount");
        print("google signin methood successful access");

        // setuserData();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully Login'),),);
        Navigator.push(context, MaterialPageRoute(builder: ((context) =>
            HomePage()
            // Responsive_layout(
            //    mobileScaffold: MobilePage(title: 'mobilepage',userdata:googleSignInAccount, ),
            //    tabletScaffold: tabletPage(title: 'tabletpage',userdata:googleSignInAccount,),
            //    desktopScaffold: DesktopPage(title: 'desktoppage',userdata:googleSignInAccount, selectedLevel: '', ))
        )));
      }
      else{
        print("Signin-canceled");
      }
    } catch (error)
    {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    //
    final imageSize = screenWidth*0.5;
    final padding = screenWidth*0.05;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets1/ai image.jpg'),
                    fit: BoxFit.cover,
                  )),
            ),
            
            SizedBox(height: screenHeight*0.05,),
            Text(
              "Speech your thoughts",
              style: TextStyle(
                fontSize: screenWidth * 0.06, // 6% of screen width
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.01), // 1% of screen height
            Text(
              "You can download or save\nYou can download or save\nYou can download or save",
              style: TextStyle(
                fontSize: screenWidth * 0.04, // 4% of screen width
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: screenHeight * 0.05),
            ElevatedButton(onPressed: (){GoogleLogin();}, child: Container(child: Text("Login"),))

            // Consumer<LoginViewModel>(
            //   builder: (context, viewModel, child) {
            //     return CustomButton(
            //       text: "Login with Google",
            //       onPressed: viewModel!.loginWithGoogle,
            //       icon: Image.asset('assets/images/google_logo.png', width: screenWidth * 0.06, height: screenWidth * 0.06),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
