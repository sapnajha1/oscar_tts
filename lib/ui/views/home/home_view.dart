import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:oscar_stt/core/constants/app_colors.dart';
import 'package:oscar_stt/ui/views/transcribe/transcribe_view.dart';
import '../../shared/styles/text_style.dart';
import '../profile/profile_view.dart';
import '../record/record_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> transcriptions = [];
  bool isListening = false;
  // late stt.SpeechToText _speech;
  String currentTranscription = '';

  // @override
  // void initState() {
  //   super.initState();
  //   _speech = stt.SpeechToText();
  // }


  Future<void> _toggleRecording() async {
    // if (!isListening) {
    //   bool available = await _speech.initialize(
    //     onStatus: (val) {
    //       if (val == 'done') {
    //         setState(() {
    //           isListening = false;
    //           transcriptions.add(currentTranscription);
    //         });
            Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => RecordView(
              onRecordingComplete: (transcribedText)
            {
              setState(() {
                transcriptions.add(transcribedText);
              });

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TranscribeResult(
                        transcribedText: currentTranscription,
                        onDelete: () =>
                            _deleteTranscription(currentTranscription),
                      ),
                ),
              );
            })));
          }
    //     },
    //     onError: (val) {
    //       setState(() {
    //         isListening = false;
    //       });
    //       print('onError: $val');
    //     },
    //   );
    //
    //   if (available) {
    //     setState(() {
    //       isListening = true;
    //     });
    //     _speech.listen(
    //       onResult: (val) {
    //         setState(() {
    //           currentTranscription = val.recognizedWords;
    //         });
    //       },
    //     );
    //   } else {
    //     setState(() {
    //       isListening = false;
    //     });
    //     print('Speech recognition not available');
    //   }
    // } else {
    //   _speech.stop();
    //   setState(() {
    //     isListening = false;
    //   });
    // }
  // }




  void _deleteTranscription(String transcription) {
    setState(() {
      transcriptions.remove(transcription);
    });
  }
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
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(),
                  ),
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
                    margin: EdgeInsets.symmetric(vertical: mq.height * 0.01),
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
                              fontWeight: FontWeight.normal, // Smaller font size for body
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TranscribeResult(
                              transcribedText: transcriptions[index],
                              onDelete: () {
                                setState(() {
                                  transcriptions.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed:
        _toggleRecording,
        child:
        Image.asset(
          'assets1/mic.png',
          width: 40.0,
          height: 40.0,
        ),
        // Icon(
        //   isListening ? Icons.circle : Icons.mic,
        //   color: Colors.white,
        // ),
        backgroundColor: AppColors.ButtonColor2,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

