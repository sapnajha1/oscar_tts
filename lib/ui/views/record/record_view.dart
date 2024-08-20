

// .......................................................................................

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:oscar_stt/core/constants/app_colors.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';
import 'package:http/http.dart' as http;
import '../transcribe/transcribe_view.dart';

class RecordView extends StatefulWidget {
  final Function(String) onRecordingComplete;
  final String tokenid;

  RecordView({required this.onRecordingComplete,required this.tokenid});

  @override
  _RecordViewState createState() => _RecordViewState();
}

class _RecordViewState extends State<RecordView> {
  late stt.SpeechToText _speech;
  String _speechText = '';
  Timer? _timer;
  bool _isRecording = false;
  int _seconds = 0;
  bool _isDiscardButtonActive = false;
  bool _isKeepRecordingButtonActive = true;
  bool _isRestarted = false;

late final GenerativeModel _model;
final String geminiApiUrl =
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyD2-74-Ol3Yw29b0aG31o9yUnukrW2aHqo"; // Replace with your API key

final Map<String, String> headers = {'Content-Type': 'application/json'};
String _formattedText = "";


@override
void initState() {
  super.initState();
  _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: 'AIzaSyD2-74-Ol3Yw29b0aG31o9yUnukrW2aHqo'); // Replace 'YOUR_API_KEY' with your actual API key
  _initializeSpeechToText();
  _startRecording();
}

// Future<String?> _formatText(String originalText) async {
//   try {
//     final content = [Content.text('Please correct any grammatical errors in the following sentence: "$originalText"')];
//     final response = await _model.generateContent(content);
//
//     print("API Response: ${response.text}");
//
//     if (response.text == null || response.text!.isEmpty) {
//       print("Generated text was blocked or empty.");
//       return originalText; // Fallback to the original text if the generated one is blocked
//     }
//
//     return response.text;
//   } catch (e) {
//     print("Error using Gemini API: $e");
//     return originalText; // Return the original text if an error occurs
//   }
// }

  Future<String?> _formatText(String originalText) async {
    try {
      final content = [Content.text('Please correct any grammatical errors in the following sentence: "$originalText"')];
      final response = await _model.generateContent(content);

      // Print the full response for debugging purposes
      print("API Response: ${response.text}");

      if (response.text == null || response.text!.isEmpty) {
        print("Generated text was blocked or empty.");
        return originalText; // Fallback to the original text if the generated one is blocked
      }

      // Extract only the formatted text from the response
      final formattedText = _extractFormattedText(response.text!);

      return formattedText;
    } catch (e) {
      print("Error using Gemini API: $e");
      return originalText; // Return the original text if an error occurs
    }
  }


// Helper function to extract only the formatted text from the API response
  String _extractFormattedText(String apiResponse) {
    // Look for the corrected sentence within the API response
    final startIndex = apiResponse.indexOf('**');
    if (startIndex == -1) {
      return apiResponse; // Return the full response if the expected pattern is not found
    }

    final endIndex = apiResponse.indexOf('**', startIndex + 2);
    if (endIndex == -1) {
      return apiResponse; // Return the full response if the end pattern is not found
    }

    // Extract the text within the first pair of asterisks

    String formattedText = apiResponse.substring(startIndex + 2, endIndex).trim();
    formattedText = formattedText.replaceAll('"', '');


    return formattedText;
  }


  Future<void> _sendTranscriptionToBackend(String transcribedText , ) async {
    final String apiUrl = 'https://dev-oscar.merakilearn.org/api/v1/transcriptions/add'; // Replace with your actual API URL
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer ${widget.tokenid}',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'transcribedText': _speechText,
        }),
      );
      if (response.statusCode == 201) {
        print('Transcription successfully sent: ${response.statusCode}');
        // Handle success response if needed
      } else {
        print('Failed to send transcription: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during sending transcription: $e');
    }
  }


  void _initializeSpeechToText() {
    _speech = stt.SpeechToText();
    _checkPermissionAndStartListening();
  }

  void _restartRecordingSession() async {
    await _stopCurrentRecording(isRestarting: true);

    setState(() {
      _seconds = 0;
      _speechText = '';// Reset timer
      _isRestarted = true;
    });

    _initializeSpeechToText();

    // await _stopCurrentRecording();
    _startRecording(); // Start a new recording session
  }

  // void _restartRecordingSession() async {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("Do you want to restart again?"),
  //         actions: [
  //           TextButton(
  //             onPressed: () async {
  //               Navigator.of(context).pop(); // Close the dialog
  //
  //               // Stop the current recording and reset states
  //               await _stopCurrentRecording(isRestarting: true);
  //
  //               setState(() {
  //                 _seconds = 0;
  //                 _speechText = ''; // Reset timer and transcription text
  //                 _isRestarted = true;
  //               });
  //
  //               _initializeSpeechToText();
  //               _startRecording(); // Start a new recording session
  //
  //               // Post data to the Meraki POST API
  //               await _sendTranscriptionToBackend(_speechText);
  //             },
  //             child: Text("Restart"),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Close the dialog
  //             },
  //             child: Text("Discard"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }


  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _seconds = 0;
    });
    _startTimer();
  }

  Future<void> _stopCurrentRecording({bool isRestarting = false}) async {
    setState(() {
      _isRecording = false;
    });

    _timer?.cancel(); // Stop the timer

    // Stop the speech recognition
    await _speech.stop();

    if (!isRestarting) {
      // Ensure that the latest transcription data is what gets sent
      if (_speechText.isNotEmpty) {
        // Format the text
        String? formattedText = await _formatText(_speechText);

        if (formattedText != null) {
          // Send the formatted transcription to the backend
          await _sendTranscriptionToBackend(formattedText);

          // Navigate to the transcription result page with the latest transcription
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TranscribeResult(
                transcribedText: formattedText,
                onDelete: () {
                  widget.onRecordingComplete('');
                },
                tokenid: widget.tokenid,
              ),
            ),
          );
        } else {
          print('No formatted text available.');
        }
      } else {
        print('No new speech was recognized.');
      }
    }
  }

  Future<void> _stopRecording() async {
    await _stopCurrentRecording();

    try {
      final transcriptionToSend = _isRestarted ? _speechText : _speechText;

      String? formattedText = await _formatText(transcriptionToSend);

      if (formattedText != null) {
        await _sendTranscriptionToBackend(formattedText);
        _isRestarted = false;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TranscribeResult(
              transcribedText: formattedText,
              onDelete: () {
                widget.onRecordingComplete('');
              },
              tokenid: widget.tokenid,
            ),
          ),
        );
      } else {
        print('No formatted text available.');
      }
    } catch (e) {
      print('Error stopping the recording: $e');
    }
  }



  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  void _checkPermissionAndStartListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) {
        print('onError: $val');
        if (val.errorMsg == 'error_speech_timeout') {
          print('Speech recognition timeout');
        }
      },
    );

    if (available) {
      _speech.listen(onResult: (val) {
        setState(() {
          _speechText = val.recognizedWords;
        });
        if (val.finalResult) {
          print('Final speech result: $_speechText');
        }
      });
    } else {
      print('Speech recognition not available');
    }
  }

  void _showAlertBox() {
    setState(() {
      _isKeepRecordingButtonActive = true;
      _isDiscardButtonActive = false;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var mq = MediaQuery.of(context).size;
        return AlertDialog(
          title: Text(
            'Sure you want to exit?',
            style: TextStyle(
              fontSize: mq.width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'You are exiting the recording. Recorded data will be lost.',
            style: TextStyle(
              fontSize: mq.width * 0.04,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isDiscardButtonActive = true;
                          _isKeepRecordingButtonActive = false;
                        });
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text('Discard'),
                      style: TextButton.styleFrom(
                        foregroundColor: _isDiscardButtonActive
                            ? Colors.white
                            : AppColors.ButtonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: AppColors.ButtonColor),
                        ),
                        backgroundColor: _isDiscardButtonActive
                            ? AppColors.ButtonColor
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  child: Text('Keep Recording'),
                  onPressed: () {
                    setState(() {
                      _isKeepRecordingButtonActive = true;
                    });
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: _isKeepRecordingButtonActive
                        ? Colors.white
                        : AppColors.ButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: AppColors.ButtonColor),
                    ),
                    backgroundColor: _isKeepRecordingButtonActive
                        ? AppColors.ButtonColor
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            _showAlertBox();
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.all(mq.width * 0.025),
              child: Container(
                width: double.infinity,
                height: mq.height * 0.2,
                decoration: BoxDecoration(
                  color: AppColors.ButtonColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(mq.width * 0.03),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isRecording ? _formatTime(_seconds) : "00:00",
                      style: TextStyle(
                        fontSize: mq.width * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: mq.height * 0.015),
                    Image.asset(
                      'assets1/audioWave.gif',
                      fit: BoxFit.cover,
                      height: mq.height * 0.12,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: mq.height * 0.1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: _restartRecordingSession,
                child: Image.asset(
                  'assets1/Frame 24.png',
                  width: mq.width * 0.15,
                ),
              ),
              GestureDetector(
                onTap: _stopRecording,
                child: Image.asset(
                  'assets1/Vector.png',
                  width: mq.width * 0.15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


