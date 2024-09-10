import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:oscar_stt/core/constants/app_colors.dart';
import 'package:oscar_stt/ui/views/record/recording2.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../loadingData/loadingData_view.dart';
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
  double _progressValue = 0.0;
  bool _isPaused = false;
  bool _isTimerRunning = false;
  int _start = 0;
  bool _isLoading = false;





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



  void _startTimer() {
    _isTimerRunning = true;
    // _isPaused = false;
    _timer = Timer.periodic(Duration(seconds: 1), ( Timer timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _pauseTimer() {
    _isTimerRunning = false;
    // _isPaused = true;
    _timer?.cancel();
  }

  void _resumeTimer() {
    if (!_isPaused) return;
    _isTimerRunning = true;
    _isPaused = false;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _start++;
      });
    });
  }

  void _stopTimer() {
    _isTimerRunning = false;
    _timer?.cancel();
    // setState(() {
    //   _start = 0; // Reset the timer
    // });
  }

  void _showRestartAlert() {
    _pauseTimer(); // Pause the timer when the alert is shown

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Do you want to restart again?'),
          actions: <Widget>[
            TextButton(
              child: Text('Restart'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetRecording();
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
                _resumeTimer(); // Resume the timer if it was paused
              },
            ),
          ],
        );
      },
    );
  }

  void _resetRecording() {
    _start = 0;
    _startTimer(); // Restart the timer

    // Restart recording
    setState(() {
      _isRecording = true;
    });
    // Add your code to start recording here
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Stop recording if needed
    super.dispose();
  }


  Future<String?> _formatText(String originalText) async {
    setState(() {
      _isLoading = true; // Start loading
    });


    try {
      final content = [
        Content.text(
          'You are an advanced AI language model with the ability to understand and transcribe spoken inputs in multiple languages, including Hindi, English, and mixed-language phrases. Your tasks are as follows:1. **Transcribe Accurately:** Transcribe the spoken input accurately, retaining the original meaning and context, even if the input contains a mix of languages (e.g., Hindi and English) or is poorly structured.2. **Language Detection and Selective Translation:** Identify any non-English segments in the input. Translate these segments into English **without altering the original meaning**. Ensure that the translation is contextually appropriate.3**Error Correction with Context Preservation:** Correct any grammatical errors, spelling mistakes, or idiomatic inaccuracies **without changing the intended meaning** of the input. Your goal is to maintain the original messages intent while improving readability and correctness.4. **Final Output:** Provide the final output in clear, correct English. Ensure that the output preserves the original meaning of the input, with proper grammar, spelling, and punctuation.\n: "$originalText"',
            // "Please correct the following text for any spelling and grammatical errors, and slightly paraphrase it while keeping the original language:\n: $originalText"
            // 'Please translate correct any grammatical errors in the following sentence and return only the corrected text: "$originalText"'
        )            // 'Please correct any grammatical errors in the following sentence and return only the corrected text: "$originalText"'

      ];
      final response = await _model.generateContent(content);

      print("API Response: ${response.text}");

      if (response.text == null || response.text!.isEmpty) {
        print("Generated text was blocked or empty.");
        return originalText; // Return the original text if the generated one is blocked
      }

      // Extract only the formatted text from the response
      final formattedText = _extractFormattedText(response.text!);

      // Return the original text if formatted text is empty or identical to the original
      return formattedText.isEmpty || formattedText == originalText
          ? originalText
          : formattedText;
    } catch (e) {
      print("Error using Gemini API: $e");
      return originalText; // Return the original text if an error occurs
    } finally {
      setState(() {
        _isLoading = false; // End loading
      });
    }
  }


  String _extractFormattedText(String apiResponse) {
    // This pattern assumes that the core text is within double quotes and ignores the rest
    final formattedTextPattern = RegExp(r'The sentence \"(.*?)\" is grammatically correct\.', caseSensitive: false);

    final match = formattedTextPattern.firstMatch(apiResponse);
    if (match != null && match.group(1) != null) {
      // Extract the text within the double quotes
      return match.group(1)!.trim();
    }

    // Return the original response if no specific pattern is found
    return apiResponse.trim();
  }

  // ///////////////////////////////////////////////////////////////////////////////////////////////////////////

  bool _hasTranscriptionBeenSent = false;
  bool _isProcessing = false;


  Future<void> _stopCurrentRecording({bool isRestarting = false}) async {
    if (!_isRecording) return; // Avoid multiple stops

    setState(() {
      _isRecording = false;
      // _isProcessing = true; // Set loading indicator to true

    });

    _timer?.cancel(); // Stop the timer

    // Stop the speech recognition
    await _speech.stop();

    if (!isRestarting && !_hasTranscriptionBeenSent) {
      if (_speechText.isNotEmpty) {
        // Check if formatting is needed
        final bool needsFormatting = _checkIfFormattingNeeded(_speechText);

        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => LoadingPage()),
        // );

        String? formattedText = needsFormatting ? await _formatText(_speechText) : _speechText;

        if (formattedText != null) {
          // await _sendTranscriptionToBackend(formattedText);
          _hasTranscriptionBeenSent = true; // Mark as sent

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TranscribeResult(
                transcribedText: formattedText,
                onDelete: () {
                  widget.onRecordingComplete('');
                  _hasTranscriptionBeenSent = false; // Reset flag on deletion
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
    // setState(() {
    //   _isProcessing = false; // Set loading indicator to false when done
    // });
  }

  Future<void> _stopRecording() async {
    await _stopCurrentRecording();

    try {
      final transcriptionToSend = _isRestarted ? _speechText : _speechText;

      // Only send transcription if it hasn't been sent yet
      if (!_hasTranscriptionBeenSent) {
        String? formattedText = await _formatText(transcriptionToSend);

        if (formattedText != null) {
          // await _sendTranscriptionToBackend(formattedText);
          _isRestarted = false;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TranscribeResult(
                transcribedText: formattedText,
                onDelete: () {
                  widget.onRecordingComplete('');
                  _hasTranscriptionBeenSent = false; // Reset flag on deletion
                },
                tokenid: widget.tokenid,
              ),
            ),
          );
        } else {
          print('No formatted text available.');
        }
      }
    } catch (e) {
      print('Error stopping the recording: $e');
    }
  }

  // Future<void> _stopRecording() async {
  //   if (!_isRecording) return; // Avoid multiple stops
  //
  //   setState(() {
  //     _isRecording = false;
  //   });
  //
  //   _stopTimer();
  //   await _speech.stop();
  //
  //   if (_speechText.isNotEmpty) {
  //     String? formattedText = await _formatText(_speechText);
  //     if (formattedText != null) {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => TranscribeResult(
  //             transcribedText: formattedText,
  //             onDelete: () {
  //               widget.onRecordingComplete('');
  //               _hasTranscriptionBeenSent = false;
  //             },
  //             tokenid: widget.tokenid,
  //           ),
  //         ),
  //       );
  //     }
  //   } else {
  //     print('No speech recognized.');
  //   }
  // }



  // //////////////////////////////////////////////////////////////////////////////////////////////////////////

  bool _isTranscriptionSent = false;

  // Future<void> _sendTranscriptionToBackend(String transcribedText , ) async {
  //   if (_isTranscriptionSent) return; // Avoid duplicate posting
  //   final String apiUrl = 'https://dev-oscar.merakilearn.org/api/v1/transcriptions/add'; // Replace with your actual API URL
  //   try {
  //     final response = await http.post(
  //       Uri.parse(apiUrl),
  //       headers: <String, String>{
  //         'Authorization': 'Bearer ${widget.tokenid}',
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode(<String, String>{
  //         'transcribedText': transcribedText,
  //       }),
  //     );
  //     if (response.statusCode == 201) {
  //       print('Transcription successfully sent: ${response.statusCode}');
  //       // Handle success response if needed
  //     } else {
  //       print('Failed to send transcription: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error during sending transcription: $e');
  //   }
  // }

//???????????????????????????????????????????????????????????????????????????????????????????????????
  void _initializeSpeechToText() {
    _speech = stt.SpeechToText();
    _checkPermissionAndStartListening();
  }


  // void _showRestartConfirmationDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return
  //
  //       //   AlertDialog(
  //       //   title: Text("Restart recording"),
  //       //   // actions: [
  //       //   //   TextButton(
  //       //   //     onPressed: () {
  //       //   //       Navigator.of(context).pop();
  //       //   //       _restartRecordingSession();
  //       //   //     },
  //       //   //     child: Text("Yes"),
  //       //   //   ),
  //       //   //   TextButton(
  //       //   //     onPressed: () {
  //       //   //       Navigator.of(context).pop();
  //       //   //       _resumeRecording();
  //       //   //     },
  //       //   //     child: Text("No"),
  //       //   //   ),
  //       //   // ],
  //       // );
  //     },
  //   );
  // }

  void _restartRecordingSession() async {
    await _stopCurrentRecording(isRestarting: true);

    setState(() {
      _isRestarted = true;
      _seconds = 0;
      _speechText = '';// Reset timer
      // _isRestarted = true;
    });

    _initializeSpeechToText();

    // await _stopCurrentRecording();
    _startRecording(); // Start a new recording session
  }

  Future<void> _resumeRecording() async {
    if (_isPaused) {
      setState(() {
        _isPaused = false;
      });
      _startTimer();
      _speech.listen(onResult: (val) {
        setState(() {
          _speechText = val.recognizedWords;
        });
        if (val.finalResult) {
          print('Final speech result: $_speechText');
        }
      });
    }
  }


  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _seconds = 0;
    });
    _startTimer();
  }


  // Future<void> _stopCurrentRecording({bool isRestarting = false}) async {
  //   if (!_isRecording) return; // Avoid multiple stops
  //
  //   setState(() {
  //     _isRecording = false;
  //   });
  //
  //   _timer?.cancel(); // Stop the timer
  //
  //   // Stop the speech recognition
  //   await _speech.stop();
  //
  //   if (!isRestarting) {
  //     // Ensure that the latest transcription data is what gets sent
  //     if (_speechText.isNotEmpty) {
  //       // Check if formatting is needed
  //       final bool needsFormatting = _checkIfFormattingNeeded(_speechText);
  //
  //       String? formattedText = needsFormatting ? await _formatText(_speechText) : _speechText;
  //
  //       if (formattedText != null) {
  //         // Send the formatted transcription to the backend
  //         await _sendTranscriptionToBackend(formattedText);
  //
  //         // Navigate to the transcription result page with the latest transcription
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => TranscribeResult(
  //               transcribedText: formattedText,
  //               onDelete: () {
  //                 widget.onRecordingComplete('');
  //               },
  //               tokenid: widget.tokenid,
  //             ),
  //           ),
  //         );
  //       } else {
  //         print('No formatted text available.');
  //       }
  //     } else {
  //       print('No new speech was recognized.');
  //     }
  //   }
  // }



  bool _checkIfFormattingNeeded(String text) {
    // Implement your logic to check if formatting is needed
    // For example, check if the text contains known errors or patterns
    return true; // Return true if formatting is needed, false otherwise
  }

  // Future<void> _stopRecording() async {
  //   await _stopCurrentRecording();
  //
  //   try {
  //     final transcriptionToSend = _isRestarted ? _speechText : _speechText;
  //
  //     String? formattedText = await _formatText(transcriptionToSend);
  //
  //     if (formattedText != null) {
  //       await _sendTranscriptionToBackend(formattedText);
  //       _isRestarted = false;
  //
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => TranscribeResult(
  //             transcribedText: formattedText,
  //             onDelete: () {
  //               widget.onRecordingComplete('');
  //             },
  //             tokenid: widget.tokenid,
  //           ),
  //         ),
  //       );
  //     } else {
  //       print('No formatted text available.');
  //     }
  //   } catch (e) {
  //     print('Error stopping the recording: $e');
  //   }
  // }



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
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,),
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
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color.fromRGBO(220, 236, 235, 1.0),

      appBar: AppBar(
        backgroundColor: Colors.transparent,

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
          if (_isProcessing) // Show LinearProgressIndicator when processing
            Padding(
              padding: EdgeInsets.symmetric(vertical: mq.height * 0.02),
              child: LinearProgressIndicator(),
            ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(mq.width * 0.025),
              child: Container(
                width: double.infinity,
                height: mq.height * 0.2,
                decoration: BoxDecoration(
                  color: AppColors.ButtonColor,
                  // color: Colors.red,
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
                onTap:
                    () {
                  if (_isRecording) {
                    // _showRestartConfirmationDialog();
                    _restartRecordingSession();
                  }
                },
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
          if (_isLoading)

            // Show loading indicator if _isLoading is true
            if (_isLoading)
                Stack(
                  children: [
                    // Blurred background
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Adjust the blur strength as needed
                      child: Container(
                        color: Colors.black.withOpacity(0.2), // Slightly tinted background to improve readability
                      ),
                    ),
                    // Custom loading UI
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: mq.height * 0.1),
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // Adjusts Column height to fit its children
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center, // Aligns children horizontally
                          children: [

                            SizedBox(height: mq.height * 0.03),
                            LinearProgressIndicator(
                              color: Color.fromRGBO(81, 160, 155, 1.0),
                              backgroundColor: Colors.grey[200],
                              minHeight: 30,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            SizedBox(height: mq.height * 0.03),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
                              child: Text(
                                'Please wait a moment while we prepare the text for you',
                                style: TextStyle(
                                  fontSize: mq.width * 0.04,
                                  fontWeight: FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

        ],
      ),
    );
  }
}

