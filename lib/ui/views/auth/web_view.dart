// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
// class GoogleSignInWebView extends StatefulWidget {
//   final String initialUrl;
//   const GoogleSignInWebView({Key? key, required this.initialUrl}) : super(key: key);
//
//   @override
//   State<GoogleSignInWebView> createState() => _GoogleSignInWebViewState();
// }
//
// class _GoogleSignInWebViewState extends State<GoogleSignInWebView> {
//   final Completer<WebViewController> _controller = Completer<WebViewController>();
//
//   @override
//   void initState() {
//     super.initState();
//     if (Platform.isAndroid) {
//       WebView.platform = SurfaceAndroidWebView();  // This requires a version supporting SurfaceAndroidWebView
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Google Sign-In'),
//       ),
//       body: WebView(
//         initialUrl: widget.initialUrl,
//         javascriptMode: JavascriptMode.unrestricted,
//         onWebViewCreated: (WebViewController webViewController) {
//           _controller.complete(webViewController);
//         },
//         navigationDelegate: (NavigationRequest request) {
//           // Detect when the redirect happens and extract the auth code
//           if (request.url.startsWith('your-redirect-url')) {
//             // Extract the auth code or token from the URL
//             final Uri uri = Uri.parse(request.url);
//             String? authCode = uri.queryParameters['code'];
//             if (authCode != null) {
//               Navigator.pop(context, authCode);
//             }
//             return NavigationDecision.prevent;
//           }
//           return NavigationDecision.navigate;
//         },
//       ),
//     );
//   }
// }
