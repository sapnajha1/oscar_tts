import 'package:flutter/material.dart';
import 'package:oscar_stt/core/constants/app_colors.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

import '../transcribe/transcribe_view.dart';

class RecordView extends StatefulWidget {

  final Function(String) onRecordingComplete;
  RecordView({required this.onRecordingComplete});
  
  @override
  _RecordViewState createState() => _RecordViewState();
}

class _RecordViewState extends State<RecordView> {
  // late final RecorderController recorderController;
  late stt.SpeechToText _speech;
  String _speechText = '';
  // late String _recordFilePath;
  // late Directory _directory;
  Timer? _timer;
  bool _isRecording = false;
  int _seconds = 0;
  double containerHeight = 180.0;

  bool _isDiscardButtonActive = false;
  bool _isKeepRecordingButtonActive = true;

  // @override
  // void initState() {
  //   super.initState();
  //   _speech = stt.SpeechToText();
  // }

  @override
  void initState() {
    super.initState();
      _initializeSpeechToText();
      _startRecording(); // Start recording immediately after setting up the directory
  }

  // void _initializeControllers() {
  //   recorderController = RecorderController()
  //     ..androidEncoder = AndroidEncoder.aac
  //     ..androidOutputFormat = AndroidOutputFormat.mpeg4
  //     ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
  //     ..sampleRate = 16000;
  // }

  void _initializeSpeechToText() {
    _speech = stt.SpeechToText();
    _checkPermissionAndStartListening();
  }

  // Future<void> _setUpDirectory() async {
  //   _directory = await getApplicationDocumentsDirectory();
  //   _recordFilePath = '${_directory.path}/recording.aac';
  // }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _seconds = 0;
    });
    _startTimer();
    // await recorderController.record(path: _recordFilePath);
  }

  Future<void> _stopRecording() async {
    setState(() {
      _isRecording = false;
    });
    _timer?.cancel();

    try {
      // await recorderController.stop();
      print('Recording stopped, navigating to TranscribeResult');

      // Navigate to the TranscribeResult page with the transcribed text
      widget.onRecordingComplete(_speechText);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TranscribeResult(
            transcribedText: _speechText,
            onDelete: () {
              widget.onRecordingComplete(''); // In case you want to remove the transcription, pass an empty string
            },
          ),
        ),
      );
    } catch (e) {
      print('Error stopping the recording: $e');
    }
  }


  // Future<void> _stopRecording() async {
  //   setState(() {
  //     _isRecording = false;
  //   });
  //   _timer?.cancel();
  //   await recorderController.stop();
  //   print('Final speech result: $_speechText');
  //
  //   widget.onRecordingComplete(_speechText);  // Pass the transcribed text to HomePage
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => TranscribeResult(
  //           transcribedText: _speechText,
  //         onDelete: () {
  //           widget.onRecordingComplete(''); // In case you want to remove the transcription, pass an empty string
  //         },
  //       ),
  //     ),
  //   );
  // }

  void _navigateToTranscribeResult() {
    widget.onRecordingComplete(_speechText);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TranscribeResult(
          transcribedText: _speechText,
          onDelete: () {
            widget.onRecordingComplete(''); // Handle deletion
          },
        ),
      ),
    );
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
      // onStatus: (val) => print('onStatus: $val'),

      onError: (val){
        print('onError: $val');
        if (val.errorMsg == 'error_speech_timeout') {
          print('Speech recognition timeout');
        }
      },

    );

    if (available) {
      _speech.listen(
        onResult: (val) {
          setState(() {
            _speechText = val.recognizedWords;
          });
          if (val.finalResult) {
            print('Final speech result: $_speechText');
            // _speechText = val.recognizedWords;
            // _navigateToTranscriptionPage();
          }
        });
    } else {
      print('Speech recognition not available');
    }
  }

  // void _navigateToTranscriptionPage() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context)=> TranscriptionPage(text: _speechText))
  //   );
  // }

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
        });
  }

  @override
  void dispose() {
    _timer?.cancel();
    // recorderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.all(10.0),
              child:
              Container(
                width: double.infinity,
                height: 180.0,
                // color: AppColors.ButtonColor,
                decoration: BoxDecoration(
                  color: AppColors.ButtonColor,
                  borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.width * 0.03))

                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [


                    Text(
                      _isRecording ? _formatTime(_seconds) : "00:00",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Image.asset(
                      'assets1/audioWave.gif',
                      fit: BoxFit.cover,
                      height: containerHeight - 40,
                    )
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 80,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // crossAxisAlignment: CrossAxisAlignment.sp,
            children: [
              // ElevatedButton(
              //   onPressed: _stopRecording,
              //   child: Text('Stop'),
              // ),

              GestureDetector(
                onTap: () async {
                  if (_isRecording) {
                    await _stopRecording(); // Stop the current recording session
                  }
                  _startRecording(); // Start a new recording session
                },
                child: Image.asset('assets1/Frame 24.png'),
              ),

              // SizedBox(width: 1,),
              GestureDetector(
                onTap: _stopRecording,
                child: Image.asset('assets1/Vector.png'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// class TranscriptionPage extends StatelessWidget {
//   final String text;
//
//   TranscriptionPage({required this.text});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Transcription")),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Text(text, style: TextStyle(fontSize: 16)),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:oscar_stt/core/constants/app_colors.dart';
// import 'package:audio_waveforms/audio_waveforms.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
//
// class RecordView extends StatefulWidget {
//   @override
//   _RecordViewState createState() => _RecordViewState();
// }
//
// class _RecordViewState extends State<RecordView> {
//   late final RecorderController recorderController;
//   late final PlayerController playerController;
//   late stt.SpeechToText _speech;
//   String _speechText = '';
//   late String _audioPath;
//   late Directory _directory;
//   Stopwatch _stopwatch = Stopwatch();
//   bool _isRecording = false;
//
//   bool _isDiscardButtonActive = false;
//   bool _isKeepRecordingButtonActive = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeControllers();
//     _initializeSpeechToText();
//     _setUpDirectory();
//   }
//
//   void _initializeControllers() {
//     recorderController = RecorderController()
//       ..androidEncoder = AndroidEncoder.aac
//       ..androidOutputFormat = AndroidOutputFormat.mpeg4
//       ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
//       ..sampleRate = 16000;
//
//     playerController = PlayerController();
//   }
//
//   void _initializeSpeechToText() {
//     _speech = stt.SpeechToText();
//     _checkPermissionAndStartListening();
//   }
//
//   Future<void> _setUpDirectory() async {
//     _directory = await getApplicationDocumentsDirectory();
//     _audioPath = "${_directory.path}/test_audio.aac";
//   }
//
//   void _startRecording() async {
//     await recorderController.record(path: _audioPath);
//     _stopwatch.start();
//     setState(() {
//       _isRecording = true;
//     });
//   }
//
//   void _stopRecording() async {
//     await recorderController.stop();
//     _stopwatch.stop();
//     setState(() {
//       _isRecording = false;
//     });
//     // Navigate to the next screen with transcribed text
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TranscriptionPage(text: _speechText),
//       ),
//     );
//   }
//
//   void _checkPermissionAndStartListening() async {
//     bool available = await _speech.initialize(
//       onStatus: (val) => print('onStatus: $val'),
//       onError: (val) => print('onError: $val'),
//     );
//
//     if (available) {
//       _speech.listen(
//         onResult: (val) => setState(() {
//           if (val.finalResult) {
//             _speechText = val.recognizedWords;
//           }
//         }),
//       );
//     }
//   }
//
//   void _playAndPause() async {
//     if (playerController.playerState == PlayerState.playing) {
//       await playerController.pausePlayer();
//     } else {
//       await playerController.startPlayer(finishMode: FinishMode.loop);
//     }
//   }
//
//
//
//
//   void _showAlertBox() {
//     setState(() {
//       _isKeepRecordingButtonActive = true;
//       _isDiscardButtonActive = false;
//     });
//     showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           var mq = MediaQuery.of(context).size;
//           return AlertDialog(
//             title: Text(
//               'Sure you want to exit?',
//               style: TextStyle(
//                 fontSize: mq.width * 0.05,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             content: Text(
//               'You are exiting the recording. Recorded data will be lost.',
//               style: TextStyle(
//                 fontSize: mq.width * 0.04,
//               ),
//             ),
//             actions: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 mainAxisSize: MainAxisSize.max,
//                 children: [
//                   Expanded(
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 8.0),
//                       child: TextButton(
//                         onPressed: () {
//                           setState(() {
//                             _isDiscardButtonActive = true;
//                             _isKeepRecordingButtonActive = false;
//                           });
//                           Navigator.of(context).pop();
//                           Navigator.of(context).pop();
//                         },
//                         child: Text('Discard'),
//                         style: TextButton.styleFrom(
//                           foregroundColor: _isDiscardButtonActive
//                               ? Colors.white
//                               : AppColors.ButtonColor,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                             side: BorderSide(color: AppColors.ButtonColor),
//                           ),
//                           backgroundColor: _isDiscardButtonActive
//                               ? AppColors.ButtonColor
//                               : Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                   TextButton(
//                     child: Text('Keep Recording'),
//                     onPressed: () {
//                       setState(() {
//                         _isKeepRecordingButtonActive = true;
//                       });
//                       Navigator.of(context).pop();
//                     },
//                     style: TextButton.styleFrom(
//                       foregroundColor: _isKeepRecordingButtonActive
//                           ? Colors.white
//                           : AppColors.ButtonColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                         side: BorderSide(color: AppColors.ButtonColor),
//                       ),
//                       backgroundColor: _isKeepRecordingButtonActive
//                           ? AppColors.ButtonColor
//                           : Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           );
//         });
//   }
//
//   // @override
//   // void dispose() {
//   //   // _controller.dispose();
//   //   super.dispose();
//   // }
//   @override
//   void dispose() {
//     recorderController.dispose();
//     playerController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios),
//           onPressed: () {
//             _showAlertBox();          },
//         ),
//         title: Text('Record and Transcribe'),
//       ),
//       body: Column(
//         children: [
//           Center(
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Center(
//                     child: Container(
//                       width: double.infinity,
//                       height: 150.0,
//                       color: AppColors.ButtonColor,
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             _isRecording
//                                 ? "${_stopwatch.elapsed.inMinutes}:${_stopwatch.elapsed.inSeconds.remainder(60).toString().padLeft(2, '0')}"
//                                 : "00:00",
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black,
//                             ),
//                           ),
//                           SizedBox(height: 10),
//                           AudioWaveforms(
//                             enableGesture: true,
//                             size: Size(MediaQuery.of(context).size.width, 60.0),
//                             recorderController: recorderController,
//                             waveStyle: WaveStyle(
//                               waveColor: AppColors.ButtonColor2,
//                               extendWaveform: true,
//                               showMiddleLine: false,
//                               // waveThickness: 2.0,
//                               // scaleFactor: 1.5,
//                               // spacing: 1.0,
//                             ),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12.0),
//                               color: Colors.transparent,
//                             ),
//                             padding: const EdgeInsets.only(left: 5),
//                             margin: const EdgeInsets.symmetric(horizontal: 15),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 20),
//           // Text('Recognized Text: $_speechText'),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               ElevatedButton(
//                 onPressed: _isRecording ? _stopRecording : _startRecording,
//                 child: Text(_isRecording ? "Stop" : "Start"),
//               ),
//               ElevatedButton(
//                 onPressed: _isRecording ? null : _playAndPause,
//                 child: Text("Play/Pause"),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class TranscriptionPage extends StatelessWidget {
//   final String text;
//
//   TranscriptionPage({required this.text});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Transcription")),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Text(text, style: TextStyle(fontSize: 16)),
//       ),
//     );
//   }
// }
//

// //.................audiowave..........................
// import 'package:audio_waveforms/audio_waveforms.dart';
// import 'package:flutter/material.dart';
// import 'package:audio_wave/audio_wave.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
// import 'dart:async';
//
// // Make sure to import the necessary package for RecorderController
// // import 'package:audio_waveforms/audio_waveforms.dart'; // Uncomment and use the correct package if needed
//
// class RecordingScreen extends StatefulWidget {
//   @override
//   _RecordingScreenState createState() => _RecordingScreenState();
// }
//
// class _RecordingScreenState extends State<RecordingScreen> {
//   late RecorderController recorderController; // Define the recorder controller
//   late int _seconds;
//   late Timer _timer;
//   late bool _isRecording;
//   late String _recordFilePath;
//
//   @override
//   void initState() {
//     super.initState();
//     _seconds = 0;
//     _isRecording = false;
//
//     // Initialize the recorder controller
//     recorderController = RecorderController()
//       ..androidEncoder = AndroidEncoder.aac
//       ..androidOutputFormat = AndroidOutputFormat.mpeg4
//       ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
//       ..sampleRate = 16000;
//   }
//
//   Future<void> _startRecording() async {
//     Directory appDocDirectory = await getApplicationDocumentsDirectory();
//     _recordFilePath = '${appDocDirectory.path}/recording.aac';
//
//     setState(() {
//       _isRecording = true;
//       _seconds = 0;
//     });
//     _startTimer();
//
//     // Start recording with recorderController
//     await recorderController.record(path: _recordFilePath); // Ensure `record` expects a named parameter `path`
//   }
//
//   Future<void> _stopRecording() async {
//     setState(() {
//       _isRecording = false;
//     });
//     _timer.cancel();
//
//     // Stop recording with recorderController
//     await recorderController.stop();
//   }
//
//   void _startTimer() {
//     _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
//       setState(() {
//         _seconds++;
//       });
//     });
//   }
//
//   String _formatTime(int seconds) {
//     final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
//     final secs = (seconds % 60).toString().padLeft(2, '0');
//     return '$minutes:$secs';
//   }
//
//   @override
//   void dispose() {
//     _timer.cancel();
//     recorderController.dispose(); // Dispose of the controller when done
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             _formatTime(_seconds),
//             style: TextStyle(fontSize: 24, color: Colors.black),
//           ),
//           SizedBox(height: 20),
//           AudioWave(
//             height: 100, // Adjust height as needed
//             width: MediaQuery.of(context).size.width,
//             spacing: 1.0, // Adjust spacing as needed
//             bars: List.generate(
//               80,
//                   (index) => AudioWaveBar(
//                 heightFactor: (index % 2 == 0) ? 0.5 : 0.7,
//                 color: Colors.blue, // Customize colors
//               ),
//             ),
//           ),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: _isRecording ? _stopRecording : _startRecording,
//             child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
// // import 'package:flutter/material.dart';
// // import 'package:oscar_stt/core/constants/app_colors.dart';
// // import 'package:simple_waveform_progressbar/simple_waveform_progressbar.dart';
// // import 'package:speech_to_text/speech_to_text.dart' as stt;
// // import 'package:path_provider/path_provider.dart';
// // import 'package:audio_waveforms/audio_waveforms.dart';
// // import 'dart:io';
// //
// // class RecordView extends StatefulWidget {
// //   @override
// //   _RecordViewState createState() => _RecordViewState();
// // }
// //
// // class _RecordViewState extends State<RecordView> {
// //   late final RecorderController recorderController;
// //   late final PlayerController playerController;
// //   late stt.SpeechToText _speech;
// //   String _speechText = '';
// //   late String _audioPath;
// //   late Directory _directory;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializeControllers();
// //     _initializeSpeechToText();
// //     _setUpDirectory();
// //   }
// //
// //   void _initializeControllers() {
// //     recorderController = RecorderController()
// //       ..androidEncoder = AndroidEncoder.aac
// //       ..androidOutputFormat = AndroidOutputFormat.mpeg4
// //       ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
// //       ..sampleRate = 16000;
// //
// //     playerController = PlayerController();
// //   }
// //
// //   void _initializeSpeechToText() {
// //     _speech = stt.SpeechToText();
// //     _checkPermissionAndStartListening();
// //   }
// //
// //   Future<void> _setUpDirectory() async {
// //     _directory = await getApplicationDocumentsDirectory();
// //     _audioPath = "${_directory.path}/test_audio.aac";
// //   }
// //
// //   void _startRecording() async {
// //     await recorderController.record(path: _audioPath); // Ensure path is a named parameter
// //     setState(() {
// //       // Update state if necessary
// //     });
// //   }
// //
// //   void _stopRecording() async {
// //     await recorderController.stop();
// //     setState(() {
// //       // Update state if necessary
// //     });
// //   }
// //
// //   void _checkPermissionAndStartListening() async {
// //     bool available = await _speech.initialize(
// //       onStatus: (val) => print('onStatus: $val'),
// //       onError: (val) => print('onError: $val'),
// //     );
// //
// //     if (available) {
// //       _speech.listen(
// //         onResult: (val) => setState(() {
// //           if (val.finalResult) {
// //             _speechText = val.recognizedWords;
// //           }
// //         }),
// //       );
// //     }
// //   }
// //
// //   void _playAndPause() async {
// //     if (playerController.playerState == PlayerState.playing) {
// //       await playerController.pausePlayer();
// //     } else {
// //       await playerController.startPlayer(finishMode: FinishMode.loop);
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     recorderController.dispose();
// //     playerController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         leading: IconButton(
// //           icon: Icon(Icons.arrow_back_ios),
// //           onPressed: () {
// //             Navigator.pop(context);
// //           },
// //         ),      ),
// //       body: Column(
// //         children: [
// //           AudioWaveforms(
// //             enableGesture: true,
// //             size: Size(MediaQuery.of(context).size.width, 200.0),
// //             recorderController: recorderController,
// //             waveStyle: const WaveStyle(
// //               // waveColor: AppColors.ButtonColor2,
// //               waveColor: Colors.red,
// //               extendWaveform: true,
// //               showMiddleLine: false,
// //               waveThickness: 3.0,
// //               scaleFactor: 20,
// //               // waveAmplitude: 0.5,
// //             ),
// //             decoration: BoxDecoration(
// //               borderRadius: BorderRadius.circular(12.0),
// //               color:  AppColors.ButtonColor,
// //             ),
// //             padding: const EdgeInsets.only(left: 18),
// //             margin: const EdgeInsets.symmetric(horizontal: 15),
// //           ),
// //           SizedBox(height: 20),
// //           Text('Recognized Text: $_speechText'),
// //           IconButton(
// //             icon: Icon(Icons.play_arrow),
// //             tooltip: 'Play/Pause Audio',
// //             onPressed: _playAndPause,
// //           ),
// //         ],
// //       ),
// //       floatingActionButton: FloatingActionButton(
// //         child: Icon(Icons.mic),
// //         onPressed: _startRecording,
// //       ),
// //     );
// //   }
// // }
// //
