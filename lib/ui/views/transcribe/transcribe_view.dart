import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oscar_stt/core/constants/app_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart' as pdfWidgets;
// import 'package:share/share.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';

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

  //  _shareText() {
  //   Share.share(_textController.text);
  // }

  void _downloadPDF() async {
    final pdf = pw.Document();
    final font = await pdfWidgets.Font.ttf(await rootBundle.load('assets1/fonts/Roboto-Regular.ttf'));

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text(
              _textController.text,
              style: pw.TextStyle(font: font, fontSize: 24),
            ),
          );
        },
      ),
    );

    try {
      // Get the external storage directory (downloads folder)
      final directory = await getExternalStorageDirectory();
      final path = '${directory?.path}/transcription.pdf';
      final file = File(path);

      await file.writeAsBytes(await pdf.save());

      print('PDF saved successfully: $path');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved successfully to $path')),
      );

    } catch (e) {
      print('Error saving PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save PDF')),
      );
    }
  }

  void _openPDF() async {
    final filePath = '/data/user/0/com.example.oscar_stt/app_flutter/transcription.pdf';
    try {
      final result = await OpenFile.open(filePath);
      print(result.message);
    } catch (e) {
      print('Error opening file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to open PDF.')),
      );
    }
  }

  void _previewPDF() async {
    final filePath = '/data/user/0/com.example.oscar_stt/app_flutter/transcription.pdf';
    final file = File(filePath);
    final bytes = await file.readAsBytes();

    await Printing.layoutPdf(
      onLayout: (_) => bytes,
    );
  }




  void _testShare() async {
    final String testString = 'This is a test string for sharing!';
    try {
      await Printing.sharePdf(
        bytes: utf8.encode(testString),
        filename: 'test.txt',
      );
    } catch (e) {
      print('Error sharing text file: $e');
    }
  }


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

  Future<void> _deleteTranscriptiononnewdata(BuildContext context) async {
    widget.onDelete(); // Perform the delete operation
    Navigator.pop(context, 'transcription deleted'); // Pop the current screen with the message
  }


  void _copyText() {
    Clipboard.setData(ClipboardData(text: _textController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Text copied to clipboard')),
    );
  }

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
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: mq.width * 0.04),
          onPressed: () {
            Navigator.pop(context, true); // Indicate no updates
          },
        ),
        title: Center(
          child: Text(
            'Your Transcription',
            style: TextStyle(fontSize: mq.width * 0.05),
          ),
        ),
        backgroundColor: AppColors.backgroundColor,
        toolbarHeight: mq.height * 0.1,
      ),
      body: Padding(
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
      bottomSheet: Padding(
        padding: EdgeInsets.only(bottom: mq.height * 0.02),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04),
          decoration: BoxDecoration(
            color: AppColors.ButtonColor2,
            borderRadius: BorderRadius.circular(mq.width * 0.1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  _isEditing ? Icons.edit : Icons.edit,
                  color: Colors.white,
                ),
                onPressed: _toggleEditing,
                iconSize: mq.width * 0.07,
              ),
              IconButton(
                icon: Icon(Icons.copy, color: Colors.white),
                onPressed: _copyText,
                iconSize: mq.width * 0.07,
              ),
              IconButton(
                icon: Icon(Icons.share, color: Colors.white),
                onPressed: _shareText,
                iconSize: mq.width * 0.07,
              ),
              // IconButton(
              //   icon: Icon(Icons.file_download_outlined, color: Colors.white),
              //   onPressed: _downloadPDF,
              //   iconSize: mq.width * 0.07,
              //
              // ),
              // IconButton(
              //   icon: Icon(Icons.delete_outline_rounded, color: Colors.white),
              //   onPressed: () {
              //     // _deleteTranscriptiononnewdata(context);
              //     Navigator.pop(context);
              //   },
              //   iconSize: mq.width * 0.07,
              // ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}



//
// class TranscribeResult extends StatefulWidget {
//   final String transcribedText;
//   final VoidCallback onDelete;
//   final String tokenid;
//
//   const TranscribeResult({
//     Key? key,
//     required this.transcribedText,
//     required this.onDelete,
//     required this.tokenid,
//   }) : super(key: key);
//
//   @override
//   State<TranscribeResult> createState() => _TranscribeResultState();
// }
//
// class _TranscribeResultState extends State<TranscribeResult> {
//   late TextEditingController _textController;
//
//   @override
//   void initState() {
//     super.initState();
//     _textController = TextEditingController(text: widget.transcribedText);
//   }
//
//   @override
//   void dispose() {
//     _textController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _deleteTranscription(BuildContext context) async {
//     widget.onDelete();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Transcription deleted')),
//     );
//     Navigator.pop(context, true); // Indicate that deletion occurred
//   }
//
//   void _copyText() {
//     Clipboard.setData(ClipboardData(text: _textController.text));
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Text copied to clipboard')),
//     );
//   }
//
//   void _downloadPDF() async {
//     final pdf = pw.Document();
//     final font = await pdfWidgets.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
//
//     pdf.addPage(
//       pw.Page(
//         build: (pw.Context context) {
//           return pw.Center(
//             child: pw.Text(
//               _textController.text,
//               style: pw.TextStyle(font: font, fontSize: 24),
//             ),
//           );
//         },
//       ),
//     );
//
//     try {
//       await Printing.sharePdf(
//         bytes: await pdf.save(),
//         filename: 'transcription.pdf',
//       );
//     } catch (e) {
//       print('Error sharing PDF: $e');
//     }
//   }
//
//   void _saveTranscription() {
//     String savedupdatedTranscription = _textController.text;
//     // Logic to save the updated transcription to the database
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Transcription saved')),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var mq = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios, size: mq.width * 0.04),
//           onPressed: () {
//             Navigator.pop(context, true); // Indicate no updates
//           },
//         ),
//         title: Center(
//           child: Text(
//             'Your Transcription',
//             style: TextStyle(fontSize: mq.width * 0.05),
//           ),
//         ),
//         backgroundColor: AppColors.backgroundColor,
//         toolbarHeight: mq.height * 0.1,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.save),
//             onPressed: _saveTranscription,
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(mq.width * 0.04),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextField(
//                 controller: _textController,
//                 maxLines: null,
//                 style: GoogleFonts.karla(
//                   fontSize: mq.width * 0.05,
//                   fontWeight: FontWeight.normal,
//                 ),
//                 decoration: InputDecoration(
//                   border: InputBorder.none,
//                   hintText: 'Edit your transcription here',
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomSheet: Padding(
//         padding: EdgeInsets.only(bottom: mq.height * 0.02),
//         child: Container(
//           margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04),
//           decoration: BoxDecoration(
//             color: AppColors.ButtonColor2,
//             borderRadius: BorderRadius.circular(mq.width * 0.1),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               IconButton(
//                 icon: Icon(Icons.edit, color: Colors.white),
//                 onPressed: () {
//                   // Logic to enter edit mode is now unnecessary since the text is always editable
//                 },
//                 iconSize: mq.width * 0.07,
//               ),
//               IconButton(
//                 icon: Icon(Icons.copy, color: Colors.white),
//                 onPressed: _copyText,
//                 iconSize: mq.width * 0.07,
//               ),
//               IconButton(
//                 icon: Icon(Icons.share, color: Colors.white),
//                 onPressed: () {
//                   print('Share icon tapped');
//                 },
//                 iconSize: mq.width * 0.07,
//               ),
//               IconButton(
//                 icon: Icon(Icons.file_download_outlined, color: Colors.white),
//                 onPressed: _downloadPDF,
//                 iconSize: mq.width * 0.07,
//               ),
//               IconButton(
//                 icon: Icon(Icons.delete_outline_rounded, color: Colors.white),
//                 onPressed: () {
//                   _deleteTranscription(context);
//                 },
//                 iconSize: mq.width * 0.07,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
//
// // ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//
//
// // // import 'dart:js';
// //
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:oscar_stt/core/constants/app_colors.dart';
// // import 'package:oscar_stt/ui/views/home/home_view.dart';
// // import 'package:printing/printing.dart';
// // import 'package:pdf/pdf.dart';
// // import 'package:pdf/widgets.dart' as pw;
// // import 'package:pdf/widgets.dart' as pdfWidgets;
// //
// // import '../../../core/viewmodels/api_service.dart';
// //
// //
// // class TranscribeResult extends StatefulWidget {
// //   final String transcribedText;
// //   final VoidCallback onDelete;
// //   final String tokenid;
// //
// //   const TranscribeResult({
// //     Key? key,
// //     required this.transcribedText,
// //     required this.onDelete,
// //     required this.tokenid,
// //   }) : super(key: key);
// //
// //   @override
// //   State<TranscribeResult> createState() => _TranscribeResultState();
// // }
// //
// // class _TranscribeResultState extends State<TranscribeResult> {
// //   Future<void> _deleteTranscription(BuildContext context) async {
// //     widget.onDelete();
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text('Transcription deleted')),
// //     );
// //     Navigator.pop(context, true); // Indicate that deletion occurred
// //   }
// //
// //   void _copyText() {
// //     Clipboard.setData(ClipboardData(text: widget.transcribedText));
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text('Text copied to clipboard')),
// //     );
// //   }
// //
// //   void _downloadPDF() async {
// //     final pdf = pw.Document();
// //     final font = await pdfWidgets.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
// //
// //     pdf.addPage(
// //       pw.Page(
// //         build: (pw.Context context) {
// //           return pw.Center(
// //             child: pw.Text(
// //               widget.transcribedText,
// //               style: pw.TextStyle(font: font, fontSize: 24),
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //
// //     try {
// //       await Printing.sharePdf(
// //         bytes: await pdf.save(),
// //         filename: 'transcription.pdf',
// //       );
// //     } catch (e) {
// //       print('Error sharing PDF: $e');
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     var mq = MediaQuery.of(context).size;
// //
// //     return Scaffold(
// //       backgroundColor: AppColors.backgroundColor,
// //       appBar: AppBar(
// //         leading: IconButton(
// //           icon: Icon(Icons.arrow_back_ios, size: mq.width * 0.04),
// //           onPressed: () {
// //             Navigator.pop(context, true
// //             ); // Indicate no updates
// //           },
// //         ),
// //         title: Center(
// //           child: Text(
// //             'Your Transcription',
// //             style: TextStyle(fontSize: mq.width * 0.05),
// //           ),
// //         ),
// //         backgroundColor: AppColors.backgroundColor,
// //         toolbarHeight: mq.height * 0.1,
// //       ),
// //       body: Padding(
// //         padding: EdgeInsets.all(mq.width * 0.04),
// //         child: SingleChildScrollView(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text(
// //                 widget.transcribedText,
// //                 style: GoogleFonts.karla(
// //                   fontSize: mq.width * 0.05,
// //                   fontWeight: FontWeight.normal,
// //                 ),
// //                 textAlign: TextAlign.center,
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //       bottomSheet: Padding(
// //         padding: EdgeInsets.only(bottom: mq.height * 0.02),
// //         child: Container(
// //           margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04),
// //           decoration: BoxDecoration(
// //             color: AppColors.ButtonColor2,
// //             borderRadius: BorderRadius.circular(mq.width * 0.1),
// //           ),
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //             children: [
// //               IconButton(
// //                 icon: Icon(Icons.edit, color: Colors.white),
// //                 onPressed: () {
// //                   print('Edit icon tapped');
// //                 },
// //                 iconSize: mq.width * 0.07,
// //               ),
// //               IconButton(
// //                 icon: Icon(Icons.copy, color: Colors.white),
// //                 onPressed: _copyText,
// //                 iconSize: mq.width * 0.07,
// //               ),
// //               IconButton(
// //                 icon: Icon(Icons.share, color: Colors.white),
// //                 onPressed: () {
// //                   print('Share icon tapped');
// //                 },
// //                 iconSize: mq.width * 0.07,
// //               ),
// //               IconButton(
// //                 icon: Icon(Icons.file_download_outlined, color: Colors.white),
// //                 onPressed: _downloadPDF,
// //                 iconSize: mq.width * 0.07,
// //               ),
// //               IconButton(
// //                 icon: Icon(Icons.delete_outline_rounded, color: Colors.white),
// //                 onPressed: () {
// //                   _deleteTranscription(context);
// //                 },
// //                 iconSize: mq.width * 0.07,
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// //
// //
// //
// // // ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
// // // class TranscribeResult extends StatefulWidget {
// // //   final String transcribedText;
// // //   final VoidCallback onDelete;
// // //   final String tokenid;
// // //
// // //   const TranscribeResult({Key? key, required this.transcribedText, required this.onDelete, required this.tokenid}) : super(key: key);
// // //
// // //   @override
// // //   State<TranscribeResult> createState() => _TranscribeResultState();
// // // }
// // //
// // // class _TranscribeResultState extends State<TranscribeResult> {
// // //   late Future<List<Map<String, dynamic>>> _transcriptions;
// // //
// // //   Future<void> _deleteTranscription(BuildContext context) async {
// // //     // Call the onDelete callback
// // //     widget.onDelete();
// // //
// // //     // Show the SnackBar after deletion
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(content: Text('Transcription deleted')),
// // //     );
// // //
// // //     // Pop the current page after deletion
// // //     Navigator.pop(context,true);
// // //   }
// // //
// // //   // Future<bool> _onWillPop(BuildContext context) async {
// // //   void _copyText() {
// // //     Clipboard.setData(ClipboardData(text: widget.transcribedText));
// // //     ScaffoldMessenger.of(context ).showSnackBar(
// // //       SnackBar(content: Text('Text copied to clipboard')),
// // //     );
// // //   }
// // //
// // //
// // //   // void _downloadPDF() async {
// // //   //   final pdf = pw.Document();
// // //   //   pdf.addPage(
// // //   //     pw.Page(
// // //   //       build: (pw.Context context) {
// // //   //         return pw.Center(
// // //   //           child: pw.Text(widget.transcribedText, style: pw.TextStyle(fontSize: 24)),
// // //   //         );
// // //   //       },
// // //   //     ),
// // //   //   );
// // //   //
// // //   //   try {
// // //   //     await Printing.sharePdf(
// // //   //       bytes: await pdf.save(),
// // //   //       filename: 'transcription.pdf',
// // //   //     );
// // //   //   } catch (e) {
// // //   //     print('Error sharing PDF: $e');
// // //   //   }
// // //   // }
// // //
// // //   void _downloadPDF() async {
// // //     final pdf = pw.Document();
// // //     final font = await pdfWidgets.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
// // //
// // //     pdf.addPage(
// // //       pw.Page(
// // //         build: (pw.Context context) {
// // //           return pw.Center(
// // //             child: pw.Text(
// // //               widget.transcribedText,
// // //               style: pw.TextStyle(font: font, fontSize: 24),
// // //             ),
// // //           );
// // //         },
// // //       ),
// // //     );
// // //
// // //     try {
// // //       await Printing.sharePdf(
// // //         bytes: await pdf.save(),
// // //         filename: 'transcription.pdf',
// // //       );
// // //     } catch (e) {
// // //       print('Error sharing PDF: $e');
// // //     }
// // //   }
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _transcriptions = ApiService().fetchTranscriptions(widget.tokenid);
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     var mq = MediaQuery.of(context).size;
// // //
// // //     return Scaffold(
// // //       backgroundColor: AppColors.backgroundColor,
// // //       appBar: AppBar(
// // //         leading: IconButton(
// // //           icon: Icon(Icons.arrow_back_ios, size: mq.width * 0.04),
// // //           onPressed: () {
// // //             // Navigator.push(
// // //             //     context,
// // //             //     MaterialPageRoute(
// // //             //     builder: (context) => HomePage( transcribedata: widget.transcribedText, profileName: '', profilePicUrl: '', tokenid: '',),
// // //             // ),);
// // //             // Navigator.pop(context, widget.transcribedText);
// // //             Navigator.pop(context, false);
// // //           },
// // //         ),
// // //         title: Center(
// // //           child: Text(
// // //             'Your Transcription',
// // //             style: TextStyle(fontSize: mq.width * 0.05),
// // //           ),
// // //         ),
// // //         backgroundColor: AppColors.backgroundColor,
// // //         toolbarHeight: mq.height * 0.1,
// // //       ),
// // //       body:
// // //       Padding(
// // //         padding: EdgeInsets.all(mq.width * 0.04),
// // //         child: SingleChildScrollView(
// // //           child: Column(
// // //             crossAxisAlignment: CrossAxisAlignment.start,
// // //             children: [
// // //               Text(
// // //                 widget.transcribedText,
// // //                 style: GoogleFonts.karla(
// // //                   fontSize: mq.width * 0.05,
// // //                   fontWeight: FontWeight.normal,
// // //                 ),
// // //                 textAlign: TextAlign.center,
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //
// // //
// // //       bottomSheet: Padding(
// // //         padding: EdgeInsets.only(bottom: mq.height * 0.02),
// // //         child: Container(
// // //           margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04),
// // //           decoration: BoxDecoration(
// // //             color: AppColors.ButtonColor2,
// // //             borderRadius: BorderRadius.circular(mq.width * 0.1),
// // //           ),
// // //           child: Row(
// // //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// // //             children: [
// // //               IconButton(
// // //                 icon: Icon(Icons.edit, color: Colors.white),
// // //                 onPressed: () {
// // //                   print('Edit icon tapped');
// // //                 },
// // //                 iconSize: mq.width * 0.07,
// // //               ),
// // //               IconButton(
// // //                 icon: Icon(Icons.copy, color: Colors.white),
// // //                 onPressed:  _copyText,
// // //                 iconSize: mq.width * 0.07,
// // //               ),
// // //               IconButton(
// // //                 icon: Icon(Icons.share, color: Colors.white),
// // //                 onPressed: () {
// // //                   print('Share icon tapped');
// // //                 },
// // //                 iconSize: mq.width * 0.07,
// // //               ),
// // //               IconButton(
// // //                 icon: Icon(Icons.file_download_outlined, color: Colors.white),
// // //                 onPressed: _downloadPDF,
// // //                 iconSize: mq.width * 0.07,
// // //               ),
// // //               IconButton(
// // //                 icon: Icon(Icons.delete_outline_rounded, color: Colors.white),
// // //                 onPressed: () {
// // //                   print('Delete icon tapped');
// // //                   // _deleteTranscription(context);
// // //                   Navigator.of(context).pushAndRemoveUntil(
// // //                     MaterialPageRoute(builder: (context) => HomePage(transcribedata: '', profileName: '', profilePicUrl: '', tokenid: ' ',)),
// // //                         (route) => false,
// // //                   );                  ScaffoldMessenger.of(context).showSnackBar(
// // //                     SnackBar(content: Text("Transcription is deleted")),
// // //                   );
// // //                 },
// // //                 iconSize: mq.width * 0.07,
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // //
// // //
