import 'package:google_fonts/google_fonts.dart';
import 'package:oscar_stt/core/constants/app_colors.dart';
import 'package:oscar_stt/ui/views/profile/profile_view.dart';
import 'package:flutter/material.dart';

import '../../shared/styles/text_style.dart';
import '../record/record_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> transcriptions = [
    "Hello, this is the first transcription.",
    "Here's another transcription example.",
    "Hello, this is the first transcription.",
    "Here's another transcription example.",
    "Hello, this is the first transcription.",
    "Here's another transcription example.",
    "Hello, this is the first transcription.",
    "Here's another transcription example.",
    "Hello, this is the first transcription.",
    "Here's another transcription example.",
    "Hello, this is the first transcription.",
    "Here's another transcription example.",
  ];

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  'Oscar',
                  style: TextStyles.defaultTextStyle(
                    fontSize: mq.width * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Image.asset(
                "assets1/tips_and_updates.png",
                width: mq.width * 0.08,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfile()),
                );
              },
            ),
          ],
        ),
      ),
      drawer: Container(
        color: Colors.lightBlue,
      ),
      body: Padding(
        padding: EdgeInsets.all(mq.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "MY Transcribe (${transcriptions.length})",
              style: TextStyles.defaultTextStyle(
                fontSize: mq.width * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: mq.height * 0.05),
            Expanded(
              child: transcriptions.isEmpty
                  ? Center(
                child: Text(
                  "Start recording your first thoughts...",
                  textAlign: TextAlign.center,
                  style: TextStyles.defaultTextStyle(
                    fontSize: mq.width * 0.08,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: transcriptions.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: AppColors.ButtonColor,
                    margin: EdgeInsets.symmetric(
                        vertical: mq.height * 0.01),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10.0),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transcriptions[index],
                            style: TextStyles.defaultTextStyle(
                              fontSize: mq.width * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5.0),
                          Text(
                            transcriptions[index], // Body text
                            style: GoogleFonts.karla(
                              fontSize: mq.width * 0.04,
                              fontWeight: FontWeight.normal// Smaller font size for body
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete_outline_outlined,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            transcriptions.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          print("Mic icon tapped");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RecordingView()),
          );
        },
        child: Image.asset(
          'assets1/mic.png',
          width: mq.width * 0.15,
          height: mq.width * 0.15,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}




