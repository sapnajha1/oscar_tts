import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oscar_stt/core/constants/app_colors.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:printing/printing.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:pdf/widgets.dart' as pdfWidgets;
// import 'package:share/share.dart';
import 'package:share_plus/share_plus.dart';

import '../home/home_view.dart';
// import 'package:open_file/open_file.dart';

class TranscribeResult extends StatefulWidget {
  final String transcribedText;
  final VoidCallback onDelete;
  final String tokenid;

  const TranscribeResult({
    Key? key,
    required this.transcribedText,
    required this.onDelete,
    required this.tokenid,
  }) : super(key: key);

  @override
  State<TranscribeResult> createState() => _TranscribeResultState();
}

class _TranscribeResultState extends State<TranscribeResult> {
  bool _isEditing = false;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.transcribedText);
  }

  // void _handleBack() {
  //   Navigator.pop(context, ); // Pass the text back to HomePage
  // }

  void _handleBack() {
    Navigator.pop(context, 'show_popup'); // Pass a specific result
  }


  //  _shareText() {
  //   Share.share(_textController.text);
  // }

  // void _downloadPDF() async {
  //   final pdf = pw.Document();
  //   final font = await pdfWidgets.Font.ttf(await rootBundle.load('assets1/fonts/Roboto-Regular.ttf'));
  //
  //   pdf.addPage(
  //     pw.Page(
  //       build: (pw.Context context) {
  //         return pw.Center(
  //           child: pw.Text(
  //             _textController.text,
  //             style: pw.TextStyle(font: font, fontSize: 24),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  //
  //   try {
  //     // Get the external storage directory (downloads folder)
  //     final directory = await getExternalStorageDirectory();
  //     final path = '${directory?.path}/transcription.pdf';
  //     final file = File(path);
  //
  //     await file.writeAsBytes(await pdf.save());
  //
  //     print('PDF saved successfully: $path');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('PDF saved successfully to $path')),
  //     );
  //
  //   } catch (e) {
  //     print('Error saving PDF: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to save PDF')),
  //     );
  //   }
  // }
  //
  // void _openPDF() async {
  //   final filePath = '/data/user/0/org.samyarth.oscar/app_flutter/transcription.pdf';
  //   try {
  //     final result = await OpenFile.open(filePath);
  //     print(result.message);
  //   } catch (e) {
  //     print('Error opening file: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Failed to open PDF.')),
  //     );
  //   }
  // }
  //
  // void _previewPDF() async {
  //   final filePath = '/data/user/0/org.samyarth.oscar/app_flutter/transcription.pdf';
  //   final file = File(filePath);
  //   final bytes = await file.readAsBytes();
  //
  //   await Printing.layoutPdf(
  //     onLayout: (_) => bytes,
  //   );
  // }




  // void _testShare() async {
  //   final String testString = 'This is a test string for sharing!';
  //   try {
  //     await Printing.sharePdf(
  //       bytes: utf8.encode(testString),
  //       filename: 'test.txt',
  //     );
  //   } catch (e) {
  //     print('Error sharing text file: $e');
  //   }
  // }


  void _shareText() {
    try {
      Share.share(_textController.text);
      print('Text shared successfully');
    } catch (e) {
      print('Error sharing text: $e');
    }
  }


  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _deleteTranscription(BuildContext context) async {
    widget.onDelete(); // Perform the delete operation
    Navigator.pop(context, 'Transcription deleted');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Transcription deleted')),
    );
    // Pop the current screen with the message
  }


  // void _handleDeleteTranscription() {
  //   // Call the onDelete callback to handle deletion logic
  //   widget.onDelete();
  //
  //   // Navigate to the home page
  //   Navigator.of(context).pushAndRemoveUntil(
  //     MaterialPageRoute(builder: (context) => HomePage(
  //       transcribedata: '',
  //       profileName: '',
  //       profilePicUrl: '',
  //       tokenid: '',
  //     )),
  //         (Route<dynamic> route) => false,
  //   ).then((_) {
  //     // Use a delay to ensure the SnackBar is shown on the HomePage
  //     Future.delayed(Duration.zero, () {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Transcription ID deleted'),
  //           duration: Duration(seconds: 3),
  //         ),
  //       );
  //     });
  //   });
  // }


  void _copyText() {
    Clipboard.setData(ClipboardData(text: _textController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Text copied to clipboard')),
    );
  }

  Future<void> _sendTranscriptionToBackend() async {
    // if (_isTranscriptionSent) return; // Avoid duplicate posting
    final String apiUrl = 'https://dev-oscar.merakilearn.org/api/v1/transcriptions/add'; // Replace with your actual API URL
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer ${widget.tokenid}',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'transcribedText': _textController.text,
        }),
      );
      if (response.statusCode == 201) {
        print('Transcription successfully sent: ${response.statusCode}');
        Navigator.pop(context, 'Saved transcription');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved transcription')),
        );
        // Handle success response if needed
      } else {
        print('Failed to send transcription: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during sending transcription: $e');
    }
  }
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  // void _downloadPDF() async {
  //   final pdf = pw.Document();
  //   final font = await pdfWidgets.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
  //
  //   pdf.addPage(
  //     pw.Page(
  //       build: (pw.Context context) {
  //         return pw.Center(
  //           child: pw.Text(
  //             _textController.text,
  //             style: pw.TextStyle(font: font, fontSize: 24),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  //
  //   try {
  //     await Printing.sharePdf(
  //       bytes: await pdf.save(),
  //       filename: 'transcription.pdf',
  //     );
  //   } catch (e) {
  //     print('Error sharing PDF: $e');
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color.fromRGBO(220, 236, 235, 1.0),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: mq.width * 0.04),
          onPressed: _handleBack
          //     () {
          //   // Navigator.pop(context, _textController.text); // Indicate no updates
          //   // Navigator.popUntil(context, ModalRoute.withName('/home'));
          //
          //   // Navigator.popUntil(context, ModalRoute.withName('/home'));
          //
          // },
        ),
        title: Center(
          child: Text(
            'Your Transcripts',
            style: TextStyle(fontSize: mq.width * 0.05),
          ),
        ),
        backgroundColor: Color.fromRGBO(220, 236, 235, 1.0),
        toolbarHeight: mq.height * 0.1,
      ),
      body:
      Padding(
        padding: EdgeInsets.all(mq.width * 0.04),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isEditing
                  ? TextField(
                controller: _textController,
                maxLines: null,
                style: GoogleFonts.roboto(
                  fontSize: mq.width * 0.05,
                  fontWeight: FontWeight.normal,
                  color: Colors.black, // Change text color if needed
                ),
                decoration: InputDecoration(
                  border: InputBorder.none, // Remove the border
                  fillColor: Colors.transparent, // Make background transparent
                  filled: true, // Ensure the fillColor is applied
                  contentPadding: EdgeInsets.zero, // Remove padding if needed
                ),
                textAlign: TextAlign.center,
              )
                  : Text(
                _textController.text,
                style: GoogleFonts.roboto(
                  fontSize: mq.width * 0.05,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),

         /////////////////////////////////////////////////////////
    //   DraggableScrollableSheet(
    //   initialChildSize: 0.5, // Set initial size as per your preference
    // minChildSize: 0.25, // Set minimum size when minimized
    // maxChildSize: 1.0, // Set maximum size when expanded
    // builder: (BuildContext context, ScrollController scrollController) {
    // return Container(
    // padding: EdgeInsets.all(mq.width * 0.04),
    // color: Color.fromRGBO(220, 236, 235, 1.0),
    // child: SingleChildScrollView(
    // controller: scrollController,
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           _isEditing
    //               ? TextField(
    //                               controller: _textController,
    //                               maxLines: null,
    //                               style: GoogleFonts.roboto(
    //               fontSize: mq.width * 0.05,
    //               fontWeight: FontWeight.normal,
    //               color: Colors.black, // Change text color if needed
    //                               ),
    //                               decoration: InputDecoration(
    //               border: InputBorder.none, // Remove the border
    //               fillColor: Colors.transparent, // Make background transparent
    //               filled: true, // Ensure the fillColor is applied
    //               contentPadding: EdgeInsets.zero, // Remove padding if needed
    //                               ),
    //                               textAlign: TextAlign.center,
    //                             )
    //               : Text(
    //                               _textController.text,
    //                               style: GoogleFonts.roboto(
    //               fontSize: mq.width * 0.05,
    //               fontWeight: FontWeight.normal,
    //                               ),
    //                               textAlign: TextAlign.center,
    //                             ),
    //         ],
    //       ),
    //     ),
    //   );}),

      //////////////////////////////////////////////////
      bottomSheet: Container(
        color: Color.fromRGBO(220, 236, 235, 1.0),
        child: Padding(
          padding: EdgeInsets.only(bottom: mq.height * 0.02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,

            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(mq.width * 0.1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // IconButton(
                    //   icon: Icon(
                    //     _isEditing ? Icons.edit : Icons.edit,
                    //     color: Colors.white,
                    //   ),
                    //   onPressed: _toggleEditing,
                    //   iconSize: mq.width * 0.07,
                    // ),
                    IconButton(
                      icon: Icon(Icons.copy, color: AppColors.ButtonColor2),
                      onPressed: _copyText,
                      iconSize: mq.width * 0.07,
                    ),
                    IconButton(
                      icon: Icon(Icons.share, color: AppColors.ButtonColor2),
                      onPressed: _shareText,
                      iconSize: mq.width * 0.07,
                    ),
                    // IconButton(
                    //   icon: Icon(Icons.file_download_outlined, color: Colors.white),
                    //   onPressed: _downloadPDF,
                    //   iconSize: mq.width * 0.07,
                    //
                    // ),
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded, color: AppColors.ButtonColor2),
                      onPressed: () {
                        _deleteTranscription(context);
                        // _handleDeleteTranscription();
                        Navigator.pop(context);
                      },
                      iconSize: mq.width * 0.07,
                    ),
                  ],
                ),
              ),

        // Second Container: Save button
        GestureDetector(
          onTap: _sendTranscriptionToBackend,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05, vertical: mq.height * 0.015),
            decoration: BoxDecoration(
              color: AppColors.ButtonColor2,
              borderRadius: BorderRadius.circular(mq.width * 0.1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.save,
                  color: Colors.white,
                  size: mq.width * 0.07,
                ),
                SizedBox(width: mq.width * 0.02), // Space between icon and text
                Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: mq.width * 0.05,
                  ),
                ),
              ],
            ),
          ),
        )


            ],
          ),


        ),
      ),
//////////////////////////////////////////////////////

      // bottomSheet: Container(
      //   color: Color.fromRGBO(220, 236, 235, 1.0),
      //   child: Padding(
      //     padding: EdgeInsets.only(bottom: mq.height * 0.02),
      //     child: Wrap(
      //       spacing: mq.width * 0.04, // Horizontal spacing between items
      //       runSpacing: mq.height * 0.02, // Vertical spacing between lines
      //       alignment: WrapAlignment.center, // Center align the items
      //       children: [
      //         Container(
      //           padding: EdgeInsets.all(mq.width * 0.04),
      //           decoration: BoxDecoration(
      //             color: Colors.white,
      //             borderRadius: BorderRadius.circular(10),
      //           ),
      //           child: IconButton(
      //             icon: Icon(Icons.copy),
      //             onPressed: _copyText,
      //           ),
      //         ),
      //         Container(
      //           padding: EdgeInsets.all(mq.width * 0.04),
      //           decoration: BoxDecoration(
      //             color: Colors.white,
      //             borderRadius: BorderRadius.circular(10),
      //           ),
      //           child: IconButton(
      //             icon: Icon(Icons.share),
      //             onPressed: _shareText,
      //           ),
      //         ),
      //         Container(
      //           padding: EdgeInsets.all(mq.width * 0.04),
      //           decoration: BoxDecoration(
      //             color: Colors.white,
      //             borderRadius: BorderRadius.circular(10),
      //           ),
      //           child: IconButton(
      //             icon: Icon(Icons.delete),
      //             onPressed: () => _deleteTranscription(context),
      //           ),
      //         ),
      //         // Add more icons/buttons here as needed
      //       ],
      //     ),
      //   ),
      // ),


    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}



