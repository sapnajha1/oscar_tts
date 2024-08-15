import 'dart:convert';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeSpeechToText();
    _startRecording();
  }

  void _initializeSpeechToText() {
    _speech = stt.SpeechToText();
    _checkPermissionAndStartListening();
  }

  void _restartRecordingSession() async {
    setState(() {
      _seconds = 0; // Reset timer
    });
    await _stopCurrentRecording();
    _startRecording(); // Start a new recording session
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _seconds = 0;
    });
    _startTimer();
  }

  Future<void> _stopRecording() async {
    setState(() {
      _isRecording = false;
    });
    _timer?.cancel();

    try {
      // _speech.stop();

      await _sendTranscriptionToBackend(_speechText);

      // Check if the transcribed text is not empty
      // if (_speechText.isEmpty) {
      //   print('No speech was recognized.');
      //   return;
      // }
      //
      // // Debugging: Print the transcribed text before sending it
      // print('Transcribing text: $_speechText');
      //
      // final response = await http.post(
      //   Uri.parse('https://dev-oscar.merakilearn.org/api/v1/transcriptions/add'),
      //   headers:<String, String> {
      //     'Authorization': 'Bearer ${widget.tokenid}',
      //     'Content-Type': 'application/json',
      //   },
      //   body: jsonEncode(<String, String>{'transcribedText': _speechText}),
      // );
      //
      // // Debugging: Print the request body and the status code
      // print('Request body: ${jsonEncode({'transcribedText': _speechText})}');
      // print('Response status code: ${response.statusCode}');
      //
      // if (response.statusCode == 201) {
      //   print('Transcription posted successfully.');
      // } else {
      //   print("Failed to post transcription. Status code: ${response.statusCode}");
      // }

      widget.onRecordingComplete(_speechText);

      // if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TranscribeResult(
            transcribedText: _speechText,
            onDelete: () {
              widget.onRecordingComplete('');
            }, tokenid:widget.tokenid
          ),
        ),
      );
    } catch (e) {
      print('Error stopping the recording: $e');
    }
  }

  void _restartRecording() async {
    if (_isRecording) {
      await _stopCurrentRecording(); // Stop the current recording session
    }
    _startRecording();
    _startTimer(); // Start a new recording session
  }

  Future<void> _stopCurrentRecording() async {
    setState(() {
      _isRecording = false;
    });
    _timer?.cancel();

    // Keep the recorded text and stop recording without navigating
    widget.onRecordingComplete(_speechText);
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




