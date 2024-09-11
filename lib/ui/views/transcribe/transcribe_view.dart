import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oscar_stt/core/constants/app_colors.dart';
import 'package:share_plus/share_plus.dart';

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



  void _handleBack() {
    Navigator.pop(context, 'show_popup'); // Pass a specific result
  }



  void _shareText() {
    try {
      Share.share(_textController.text);
      print('Text shared successfully');
    } catch (e) {
      print('Error sharing text: $e');
    }
  }




  Future<void> _deleteTranscription(BuildContext context) async {
    widget.onDelete(); // Perform the delete operation
    Navigator.pop(context, 'Transcription deleted');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Transcription deleted')),
    );
    // Pop the current screen with the message
  }


  void _copyText() {
    Clipboard.setData(ClipboardData(text: _textController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Text copied to clipboard')),
    );
  }

  Future<void> _sendTranscriptionToBackend() async {
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
      } else {
        print('Failed to send transcription: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during sending transcription: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color.fromRGBO(220, 236, 235, 1.0),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: mq.width * 0.04),
          onPressed: _handleBack

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
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: true,
                  contentPadding: EdgeInsets.zero,
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

    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}



