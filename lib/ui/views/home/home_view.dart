
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oscar_stt/core/constants/app_colors.dart';
import 'package:oscar_stt/ui/views/transcribe/transcribe_view.dart';
import '../../../core/viewmodels/api_service.dart';
import '../../shared/styles/text_style.dart';
import '../profile/profile_view.dart';
import '../record/record_view.dart';



import 'package:oscar_stt/core/viewmodels/delete_api_service.dart';

class HomePage extends StatefulWidget {
  final String profileName;
  final String profilePicUrl;
  final String transcribedata;
  final String tokenid;

  const HomePage({
    Key? key,
    required this.transcribedata,
    required this.profileName,
    required this.profilePicUrl,
    required this.tokenid,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>> _transcriptionsFuture;
  List<Map<String, dynamic>> _currentTranscriptions = [];

  //
  // @override
  // void initState() {
  //   super.initState();
  //   _transcriptionsFuture = ApiService().fetchTranscriptions(widget.tokenid);
  //
  //
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (ModalRoute.of(context)?.settings.arguments == true) {
  //       _showRefreshAlertDialog();
  //       _refreshData(); // Refresh data when returning from another page
  //
  //     }
  //   });
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch fresh data every time the dependencies change, i.e., when the user comes back to this page
    _transcriptionsFuture = ApiService().fetchTranscriptions(widget.tokenid);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)?.settings.arguments == true) {
        _showRefreshAlertDialog();
        _refreshData(); // Refresh data when returning from another page
      }
    });
  }

  // /////////////////////////////////////////////////////////////////////
  bool _showPopupFlag = false;

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (_showPopupFlag) {
  //     _showPopup();
  //     _showPopupFlag = false; // Reset the flag
  //   }
  // }

  Future<void> _navigateToTranscribeResult() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TranscribeResult(
          transcribedText: 'Your Transcription',
          onDelete: () {},
          tokenid: '123',
        ),
      ),
    );

    if (result == 'show_popup') {
      setState(() {
        _showPopupFlag = true;
      });
    }
  }

  void _showPopup() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
        var mq = MediaQuery.of(context).size;
        return Center(
          child: Container(
            width: mq.width * 0.8,
            height: mq.height * 0.2,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                'Refresh screen for new transcription',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, -1.0);
        var end = Offset.zero;
        var curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );

    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pop();
    });
  }
  // ////////////////////////////////////////////////////////////////////
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //       _transcriptionsFuture = ApiService().fetchTranscriptions(widget.tokenid);
  //
  //   _refreshData(); // Re-initialize the data
  // }

  // void _refreshData() {
  //   setState(() {
  //     _transcriptionsFuture = ApiService().fetchTranscriptions(widget.tokenid);
  //   });
  // }

// Inside HomePage when navigating to TranscriptionPage
//   void _navigateToTranscriptionPage(BuildContext context) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => TranscribeResult(onDelete: _confirmDeleteTranscription, transcribedText: '', tokenid: '',)),
//     );
//
//     if (result == 'Transcription deleted') {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Your transcription has been deleted')),
//       );
//     }
//   }
//
//   void _onDeleteCallback() {
//     // This will be triggered when transcription is deleted in the TranscriptionPage
//     // You can handle any additional logic here (if needed)
//   }


  void _showRefreshAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notice'),
          content: Text('Refresh page for new Transcription'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshData() async {
    final newTranscriptions = await ApiService().fetchTranscriptions(widget.tokenid);

    setState(() {
      _transcriptionsFuture = Future.value(newTranscriptions);
      _currentTranscriptions = newTranscriptions;
    });

    if (_currentTranscriptions.length < newTranscriptions.length) {
      _showNewTranscriptionSnackBar();
    }

    // _currentTranscriptions = newTranscriptions;
  }

  void _showNewTranscriptionSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New transcription added'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToTranscriptionPage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TranscribeResult(
          onDelete: () => _confirmDeleteTranscription(context as String), transcribedText: '', tokenid: '', // Pass the callback here
        ),
      ),
    );

    if (result == 'Transcription deleted') {
      // Handle additional logic after navigating back, if necessary
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your transcription has been deleted')),
      );
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  // Future<void> _confirmDeleteTranscription(String transcriptionId) async {
  //   bool? isConfirmed = await showDialog<bool>(
  //     context: context,
  //     barrierDismissible: true,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.zero,
  //         ),
  //         title: Text('Confirm Delete'),
  //         content: Text('Are you sure you want to delete this note?'),
  //         actions: <Widget>[
  //           SizedBox(height: 20.0),
  //           Container(
  //             decoration: BoxDecoration(
  //               color: Colors.red,
  //               borderRadius: BorderRadius.circular(50.0),
  //             ),
  //             padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 5.0),
  //             child: TextButton(
  //               child: Text('Cancel'),
  //               style: TextButton.styleFrom(
  //                 foregroundColor: Colors.white,
  //               ),
  //               onPressed: () {
  //                 Navigator.of(context).pop(false); // Dismiss dialog and return false
  //               },
  //             ),
  //           ),
  //           Container(
  //             decoration: BoxDecoration(
  //               color: AppColors.ButtonColor2,
  //               borderRadius: BorderRadius.circular(50.0),
  //             ),
  //             padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 5.0),
  //             child: TextButton(
  //               child: Text(
  //                 'Delete',
  //                 style: TextStyle(color: Colors.white),
  //               ),
  //               onPressed: () {
  //                 Navigator.of(context).pop(true); // Dismiss dialog and return true
  //               },
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  //
  //   if (isConfirmed ?? false) {
  //     bool deleted = await _deleteTranscription(transcriptionId); // Perform deletion
  //
  //     if (deleted) {
  //       Navigator.of(context).pop('Transcription deleted'); // Return result to HomePage
  //     }
  //   }
  // }
  //
  // Future<bool> _deleteTranscription(String transcriptionId) async {
  //   // Your deletion logic here
  //   // Return true if deletion was successful, false otherwise
  // }

  ////////////////////////////////////////////////////////////////////////////////////////////////

  Future<void> _confirmDeleteTranscription(String transcriptionId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user can tap outside to dismiss the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // No border radius
          ),
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this note?'),
          actions: <Widget>[
            SizedBox(height: 20.0),

            Container(

            decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(50.0),),
        padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 5.0),

        child: TextButton(
                child: Text('Cancel'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white, // Text color
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the dialog
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.ButtonColor2,
                borderRadius: BorderRadius.circular(50.0),
              ),
              padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 5.0),
              child: TextButton(
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the dialog
                  _deleteTranscription(transcriptionId); // Perform deletion
                },
              ),
            ),
          ],
        );
      },
    );



  }
  void _deleteTranscription(String transcriptionId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://dev-oscar.merakilearn.org/api/v1/transcriptions/$transcriptionId'),
        headers: {'Authorization': 'Bearer ${widget.tokenid}'},
      );

      if (response.statusCode == 200) {
        // Successfully deleted, you may need to refresh the data
        print('deleted successfully');
        setState(() {
          _transcriptionsFuture = _fetchTranscriptions(); // Refresh the data
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transcription deleted'),
          ),
        );
      } else if(response.statusCode == 400){
        print('bad request');

      }
      else if(response.statusCode == 404){
        print('Transcription not found');

      }
      else {
        throw Exception('Failed to delete transcription');
      }
    } catch (e) {
      // Handle the error
      print('Error: $e');
    }
  }
  /////////////////////////////////////////////////////////
  Future<List<Map<String, dynamic>>> _fetchTranscriptions() async {
    final response = await http.get(
      Uri.parse('https://dev-oscar.merakilearn.org/api/v1/transcriptions'),
      headers: {'Authorization': 'Bearer ${widget.tokenid}'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Failed to load transcriptions');
    }
  }

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final imageSize = screenWidth * 0.75;


    return Scaffold(
      // backgroundColor: AppColors.backgroundColor,
      backgroundColor: Color.fromRGBO(220, 236, 235, 1.0),

      appBar:
      AppBar(
        backgroundColor:Color.fromRGBO(220, 236, 235, 1.0),
        scrolledUnderElevation: 0.0,
        automaticallyImplyLeading: false,
        elevation: 0,
        // backgroundColor: Colo,
        title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SvgPicture.asset(
              'assets1/Oscar Logo with Text.svg',
              width: imageSize,
              height: imageSize * 0.15,
            ),

            IconButton(
              icon: CircleAvatar(
                backgroundImage: widget.profilePicUrl != null && widget.profilePicUrl!.isNotEmpty
                    ? NetworkImage(widget.profilePicUrl!)
                    : null, // Only provide the image if it exists
                radius: mq.width * 0.04, // Adjust size as needed
                backgroundColor: Colors.blue, // Optional: set a background color for the text avatar
                child: widget.profilePicUrl == null || widget.profilePicUrl!.isEmpty
                    ? Text(
                  widget.profileName.isNotEmpty ? widget.profileName[0].toUpperCase() : '',
                  style: TextStyle(
                    color: Colors.white, // Optional: text color
                    fontSize: mq.width * 0.04, // Adjust font size as needed
                  ),
                )
                    : null, // Show the first letter of the user's name if no profile picture
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                      profileName: widget.profileName,
                      profilePicUrl: widget.profilePicUrl,
                    ),
                  ),
                );
              },
            )


            // IconButton(
            //   icon: CircleAvatar(
            //     backgroundImage: NetworkImage(widget.profilePicUrl ?? 'default_image_url'),
            //     radius: mq.width * 0.04, // Adjust size as needed
            //     backgroundColor: Colors.transparent, // Optional: to avoid default background color
            //   ),
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => SettingsScreen(
            //           profileName: widget.profileName,
            //           profilePicUrl: widget.profilePicUrl,
            //         ),
            //       ),
            //     );
            //   },
            // )

          ],
        ),),
    // drawer: Container(
    //     color: Colors.lightBlue,
    //   ),

      body:      RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _transcriptionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return SingleChildScrollView( // Use SingleChildScrollView to enable scrolling
                physics: AlwaysScrollableScrollPhysics(), // Ensures scroll even when empty
                child: Container(
                  height: mq.height - kToolbarHeight, // Full height minus AppBar
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
                      crossAxisAlignment: CrossAxisAlignment.center, // Center the content horizontally
                      children: [
                        // Display "My Transcriptions (0)" at the top left
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.all(mq.width * 0.05),
                            child: Text(
                              "My Transcripts (0)",
                              style: TextStyles.defaultTextStyle(
                                fontSize: mq.width * 0.06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: mq.height * 0.20),
                        // IconButton(
                        //   icon: Icon(Icons.refresh, color: AppColors.ButtonColor,),
                        //   onPressed: () {
                        //     if (_currentTranscriptions.isEmpty) {
                        //       _refreshData();
                        //     }
                        //   },
                        // ),
                        // Text(
                        //   'Refresh your page',
                        //   style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                        // ),

                        // Spacer(), // Pushes content to the center

                        // The image
                        Image.asset(
                          'assets1/homeimage.png', // Path to the image asset
                          width: 100, // You can adjust the width as needed
                          height: 100, // You can adjust the height as needed
                        ),

                        Padding(
                          padding: const EdgeInsets.all(10.0), // Add space between the image and text
                          child: Text(
                            "We are excited to see what your first transcription will be",
                            textAlign: TextAlign.center,
                            style: TextStyles.defaultTextStyle(
                              fontSize: mq.width * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Spacer(), // Pushes content to the center
                      ],
                    ),
                  ),
                ),
              );
            } else {
              List<Map<String, dynamic>> transcriptions = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(mq.width * 0.05),
                    child: Text(
                      "My Transcriptions (${transcriptions.length})",
                      style: TextStyles.defaultTextStyle(
                        fontSize: mq.width * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: mq.height * 0.05),
                  Expanded(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        scrollbarTheme: ScrollbarThemeData(
                          thumbColor: WidgetStateProperty.all(AppColors.ButtonColor2),
                          trackColor: WidgetStateProperty.all(Colors.white),
                          trackVisibility: WidgetStateProperty.all(true),
                          thumbVisibility: WidgetStateProperty.all(true),
                          thickness: WidgetStateProperty.all(10.0),
                          radius: Radius.circular(80.0),
                        ),
                      ),
                      child:
                      ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05), // Added padding on left and right
                        itemCount: transcriptions.length,
                        itemBuilder: (context, index) {
                          final transcription = transcriptions[index];
                          return Card(
                            color: AppColors.ButtonColor,
                            margin: EdgeInsets.symmetric(vertical: 10.0),
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 70.0,
                                    child: Scrollbar(
                                      child: SingleChildScrollView(
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 8.0,left: 8.0),                                          child: Text(
                                            transcription['transcribedText'],
                                            style: TextStyle(
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Container(
                                    height: 30.0,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.copy,
                                            color: Colors.black,
                                            size: 16.0,
                                          ),
                                          onPressed: () {
                                            Clipboard.setData(
                                              ClipboardData(text: transcription['transcribedText']),
                                            );
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Copied to clipboard')),
                                            );
                                          },
                                        ),
                                        SizedBox(width: 8.0),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete_outline_rounded,
                                            color: Colors.black,
                                            size: 17.0,
                                          ),
                                          onPressed: () {
                                            _confirmDeleteTranscription(transcription['id'].toString());
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),

    //   floatingActionButton: FloatingActionButton(
    //     shape: const CircleBorder(),
    //     onPressed: () async {
    //       final newTranscription = await
    //       Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //             builder: (context) => RecordView(
    //               onRecordingComplete: (transcribedText) {
    //                 _refreshData();
    //                 Navigator.pop(context, true); // Return true to indicate that new transcription is added
    //
    //                 setState(() {
    //                   _transcriptionsFuture = _fetchTranscriptions();
    //                 });
    //
    //                 // setState(() {
    //                 //   _transcriptionsFuture = ApiService().fetchTranscriptions(widget.tokenid);
    //                 // });
    //
    //                 Navigator.pushReplacement(
    //                   context,
    //                   MaterialPageRoute(
    //                     builder: (context) => TranscribeResult(
    //                       transcribedText: transcribedText,
    //                       onDelete: () => _deleteTranscription(transcribedText),
    //                       tokenid: widget.tokenid,
    //                     ),
    //                   ),
    //                 );
    //               },
    //               tokenid: widget.tokenid,
    //             ),
    //           )
    //       );
    //       if (newTranscription != null && newTranscription == true) {
    //         _refreshData();
    //       }
    //     },
    //     child: Container(
    //       width: 100.0, // Adjust the size of the circular container
    //       height: 100.0,
    //       decoration: BoxDecoration(
    //         color: Colors.red, // Set the background color to yellow
    //         shape: BoxShape.circle, // Make the container circular
    //       ),
    //       child: Image.asset(
    //         'assets1/mic.png',
    //         width: 40.0,
    //         height: 40.0,
    //       ),
    //     ),
    //     backgroundColor: AppColors.ButtonColor2,
    //   ),
    //
    //   floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    //
    //
    //   // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    //   //
    //   //
    //   //
    //   // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    // );



      floatingActionButton: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Larger circular container
          Container(
            width: 100.0,
            height: 100.0,
            decoration: BoxDecoration(
              color: AppColors.flotingButton, // Set the background color to yellow
              shape: BoxShape.circle,
            ),
          ),
          // Mic image inside the container
          GestureDetector(
            onTap: () async {
              final newTranscription = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecordView(
                    onRecordingComplete: (transcribedText) {
                      _refreshData();
                      Navigator.pop(context, true);

                      setState(() {
                        _transcriptionsFuture = _fetchTranscriptions();
                      });

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TranscribeResult(
                            transcribedText: transcribedText,
                            onDelete: () => _deleteTranscription(transcribedText),
                            tokenid: widget.tokenid,
                          ),
                        ),
                      );
                    },
                    tokenid: widget.tokenid,
                  ),
                ),
              );
              if (newTranscription != null && newTranscription == true) {

                _refreshData();
              }
            },
            child: Image.asset(
              'assets1/mic.png',
              width: 60.0, // Adjust size of the mic image
              height: 60.0,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );

  }
}



