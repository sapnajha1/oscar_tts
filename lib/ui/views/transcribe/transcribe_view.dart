import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oscar_stt/core/constants/app_colors.dart';

class TranscribeResult extends StatelessWidget {
  final String transcribedText;
  final VoidCallback onDelete;
  const TranscribeResult({super.key, required this. transcribedText, required this.onDelete});

  Future<void> _deleteTranscription(BuildContext context) async {

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Transcription deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,size: 15),
          onPressed: () {
            Navigator.pop(context);
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
              Text( transcribedText,
                style: GoogleFonts.karla(
                  fontSize: mq.width * 0.05,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,)

            ],
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: EdgeInsets.only(bottom: mq.height * 0.02),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: mq.width * 0.02),
          decoration: BoxDecoration(
            color: AppColors.ButtonColor2,
            borderRadius: BorderRadius.circular(50),
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
                onPressed: () {
                  print('Copy icon tapped');
                },
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
                onPressed: () {
                  print('Download icon tapped');
                },
                iconSize: mq.width * 0.07,
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: Colors.white),
                onPressed: () {
                  print('Delete icon tapped');
                  _deleteTranscription(context);
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



