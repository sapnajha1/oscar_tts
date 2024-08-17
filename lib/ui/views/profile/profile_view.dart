import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
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
  final String contactEmail = 'hi@navgurukul.org';
  final String termsOfUseText = '''
Terms of Use

1. **Acceptance of Terms**
   By accessing and using this application, you agree to comply with and be bound by these Terms of Use.

2. **User Responsibilities**
   You are responsible for maintaining the confidentiality of your account and password and for restricting access to your device. You agree to accept responsibility for all activities that occur under your account.

3. **Content**
   All content provided on this application is for informational purposes only. We make no representations or warranties of any kind regarding the accuracy or completeness of any content.

4. **Prohibited Activities**
   You agree not to engage in any activities that may harm the application or interfere with its operation, including but not limited to, hacking, distributing malware, or any illegal activity.

5. **Limitation of Liability**
   We shall not be liable for any damages arising from the use or inability to use the application, including but not limited to, direct, indirect, incidental, or consequential damages.

6. **Changes to Terms**
   We reserve the right to change these Terms of Use at any time. Any changes will be effective immediately upon posting the updated terms on the application.

7. **Governing Law**
   These Terms of Use shall be governed by and construed in accordance with the laws of the jurisdiction in which the application is operated.

8. **Contact Us**
   If you have any questions or concerns about these Terms of Use, please contact us at ( hi@navgurukul.org ).
  ''';

  final String privacyPolicyText = '''
Privacy Policy

1. **Information We Collect**
   We collect information from you when you use our application, including personal information such as your name, email address, and usage data.

2. **How We Use Your Information**
   We use your information to provide and improve our services, communicate with you, and for other purposes disclosed at the time of collection.

3. **Sharing Your Information**
   We do not sell, trade, or otherwise transfer your personal information to outside parties, except as required by law or with your consent.

4. **Data Security**
   We implement appropriate security measures to protect your personal information from unauthorized access, alteration, disclosure, or destruction.

5. **Cookies and Tracking Technologies**
   We use cookies and other tracking technologies to enhance your experience and analyze usage patterns. You can manage your cookie preferences through your browser settings.

6. **Third-Party Services**
   Our application may include links to third-party websites or services. We are not responsible for the privacy practices or content of these third parties.

7. **Changes to Privacy Policy**
   We may update our Privacy Policy from time to time. Any changes will be posted on this page, and you are encouraged to review it periodically.

8. **Contact Us**
   If you have any questions about this Privacy Policy, please contact us at ( hi@navgurukul.org ).
  ''';

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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: mq.width * 0.18,
                  height: mq.width * 0.18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: greenContainerColor, width: 2),
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
                itemCount: 3,
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
                    // case 3:
                    //   iconData = Icons.share;
                    //   title = "Recommend us";
                    //   break;
                    default:
                      iconData = Icons.help;
                      title = "Item $index";
                  }
                  return ListTile(
                    leading: Icon(iconData, size: mq.width * 0.08),
                    title: Text(title, style: TextStyle(color: Colors.black, fontSize: mq.width * 0.05)),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.black, size: mq.width * 0.04),
                    onTap: () {
                      if (index == 0) { // Handle Terms of Use button tap
                        _showTermsOfUseDialog(context);
                      } else if (index == 1) { // Handle Privacy Policy button tap
                        _showPrivacyPolicyDialog(context);
                      } else if (index == 2) { // Handle Email Us button tap
                        _showEmailDialog(context);
                      }
                    },
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

  void _showEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Contact Us'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(contactEmail,style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600),),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: contactEmail));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Email address copied to clipboard')),
                  );
                },
                child: Text('Copy'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showTermsOfUseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Terms of Use'),
          content: SingleChildScrollView(
            child: Text(termsOfUseText),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Agree'),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Privacy Policy'),
          content: SingleChildScrollView(
            child: Text(privacyPolicyText),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Agree'),
            ),
          ],
        );
      },
    );
  }

  void _signOut(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Signing out...'),
        duration: Duration(seconds: 1),
      ),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginView()),
          (Route<dynamic> route) => false,
    );
  }
}
