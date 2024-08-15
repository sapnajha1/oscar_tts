// import 'dart:js';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oscar_stt/core/constants/app_colors.dart';
import 'package:oscar_stt/ui/views/home/home_view.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart' as pdfWidgets;

import '../../../core/viewmodels/api_service.dart';


class TranscribeResult extends StatefulWidget {
  final String transcribedText;
  final VoidCallback onDelete;
  final String tokenid;

  const TranscribeResult({Key? key, required this.transcribedText, required this.onDelete, required this.tokenid}) : super(key: key);

  @override
  State<TranscribeResult> createState() => _TranscribeResultState();
}

class _TranscribeResultState extends State<TranscribeResult> {
  late Future<List<Map<String, dynamic>>> _transcriptions;

  Future<void> _deleteTranscription(BuildContext context) async {
    // Call the onDelete callback
    widget.onDelete();

    // Show the SnackBar after deletion
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Transcription deleted')),
    );

    // Pop the current page after deletion
    Navigator.pop(context);
  }

  // Future<bool> _onWillPop(BuildContext context) async {
  void _copyText() {
    Clipboard.setData(ClipboardData(text: widget.transcribedText));
    ScaffoldMessenger.of(context ).showSnackBar(
      SnackBar(content: Text('Text copied to clipboard')),
    );
  }


  // void _downloadPDF() async {
  //   final pdf = pw.Document();
  //   pdf.addPage(
  //     pw.Page(
  //       build: (pw.Context context) {
  //         return pw.Center(
  //           child: pw.Text(widget.transcribedText, style: pw.TextStyle(fontSize: 24)),
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

  void _downloadPDF() async {
    final pdf = pw.Document();
    final font = await pdfWidgets.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text(
              widget.transcribedText,
              style: pw.TextStyle(font: font, fontSize: 24),
            ),
          );
        },
      ),
    );

    try {
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'transcription.pdf',
      );
    } catch (e) {
      print('Error sharing PDF: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _transcriptions = ApiService().fetchTranscriptions(widget.tokenid);
  }

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: mq.width * 0.04),
          onPressed: () {
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //     builder: (context) => HomePage( transcribedata: widget.transcribedText, profileName: '', profilePicUrl: '', tokenid: '',),
            // ),);
            Navigator.pop(context, widget.transcribedText);
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
      body:
      Padding(
        padding: EdgeInsets.all(mq.width * 0.04),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.transcribedText,
                style: GoogleFonts.karla(
                  fontSize: mq.width * 0.05,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),


      // FutureBuilder<List<Map<String, dynamic>>>(
      //   future: _transcriptions,
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return Center(child: CircularProgressIndicator());
      //     } else if (snapshot.hasError) {
      //       return Center(child: Text('Error: ${snapshot.error}'));
      //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      //       return Center(child: Text('No transcriptions found'));
      //     } else {
      //       return ListView.builder(
      //         itemCount: snapshot.data!.length,
      //         itemBuilder: (context, index) {
      //           final transcription = snapshot.data![index];
      //           return ListTile(
      //             title: Text(transcription['transcribedText']),
      //             subtitle: Text('Created at: ${transcription['createdAt']}'),
      //           );
      //         },
      //       );
      //     }
      //   },
      // ),
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
                icon: Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  print('Edit icon tapped');
                },
                iconSize: mq.width * 0.07,
              ),
              IconButton(
                icon: Icon(Icons.copy, color: Colors.white),
                onPressed:  _copyText,
                iconSize: mq.width * 0.07,
              ),
              IconButton(
                icon: Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  print('Share icon tapped');
                },
                iconSize: mq.width * 0.07,
              ),
              IconButton(
                icon: Icon(Icons.file_download_outlined, color: Colors.white),
                onPressed: _downloadPDF,
                iconSize: mq.width * 0.07,
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: Colors.white),
                onPressed: () {
                  print('Delete icon tapped');
                  // _deleteTranscription(context);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => HomePage(transcribedata: '', profileName: '', profilePicUrl: '', tokenid: ' ',)),
                        (route) => false,
                  );                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Transcription is deleted")),
                  );
                },
                iconSize: mq.width * 0.07,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:oscar_stt/core/constants/app_colors.dart';
// import 'package:oscar_stt/ui/views/home/home_view.dart';
//
// class TranscribeResult extends StatelessWidget {
//   final String transcribedText;
//   final VoidCallback onDelete;
//   const TranscribeResult({super.key, required this. transcribedText, required this.onDelete});
//
//   Future<void> _deleteTranscription(BuildContext context) async {
//     // Call the onDelete callback
//     onDelete();
//
//     // Show the SnackBar after deletion
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Transcription deleted')),
//     );
//
//     // Pop the current page after deletion
//     Navigator.pop(context);
//   }
//
//   Future<bool> _onWillPop(BuildContext context) async {
//     Navigator.of(context).popUntil((route) => route.isFirst); // Navigates back to the first route, which is the home page.
//     return true;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var mq = MediaQuery.of(context).size;
//
//     return  Scaffold(
//         backgroundColor: AppColors.backgroundColor,
//         appBar: AppBar(
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back_ios,size: 15),
//             onPressed: () {
//               // Navigator.pop(context);
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => HomePage(),
//                 ),
//               );
//             },
//           ),
//           title: Center(
//             child: Text(
//               'Your Transcription',
//               style: TextStyle(fontSize: mq.width * 0.05),
//             ),
//           ),
//           backgroundColor: AppColors.backgroundColor,
//           toolbarHeight: mq.height * 0.1,
//         ),
//         body: Padding(
//           padding: EdgeInsets.all(mq.width * 0.04),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text( transcribedText,
//                   style: GoogleFonts.karla(
//                     fontSize: mq.width * 0.05,
//                     fontWeight: FontWeight.normal,
//                   ),
//                   textAlign: TextAlign.center,)
//
//               ],
//             ),
//           ),
//         ),
//         bottomSheet: Padding(
//           padding: EdgeInsets.only(bottom: mq.height * 0.02),
//           child: Container(
//             margin: EdgeInsets.symmetric(horizontal: mq.width * 0.02),
//             decoration: BoxDecoration(
//               color: AppColors.ButtonColor2,
//               borderRadius: BorderRadius.circular(50),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.edit, color: Colors.white),
//                   onPressed: () {
//                     print('Edit icon tapped');
//                   },
//                   iconSize: mq.width * 0.07,
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.copy, color: Colors.white),
//                   onPressed: () {
//                     print('Copy icon tapped');
//                   },
//                   iconSize: mq.width * 0.07,
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.share, color: Colors.white),
//                   onPressed: () {
//                     print('Share icon tapped');
//                   },
//                   iconSize: mq.width * 0.07,
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.file_download_outlined, color: Colors.white),
//                   onPressed: () {
//                     print('Download icon tapped');
//                   },
//                   iconSize: mq.width * 0.07,
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.delete_outline_rounded, color: Colors.white),
//                   onPressed: () {
//                     print('Delete icon tapped');
//                     _deleteTranscription(context);
//                   },
//                   iconSize: mq.width * 0.07,
//                 ),
//               ],
//             ),
//           ),
//         ),
//
//     );
//   }
// }
//
//
//
