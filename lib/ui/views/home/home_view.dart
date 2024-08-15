import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oscar_stt/core/constants/app_colors.dart';
import 'package:oscar_stt/ui/views/transcribe/transcribe_view.dart';
import '../../../core/viewmodels/api_service.dart';
import '../../shared/styles/text_style.dart';
import '../profile/profile_view.dart';
import '../record/record_view.dart';
import 'package:oscar_stt/core/viewmodels/delete_api_service.dart';


class HomePage extends StatefulWidget {
  final String profileName;
  final String profilePicUrl;
  final String transcribedata;
  final String tokenid;

  const HomePage( {Key? key, required this.transcribedata, required this.profileName, required this.profilePicUrl, required this.tokenid}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>> _transcriptionsFuture;


  List<String> transcriptions = [];
  bool isListening = false;
  String currentTranscription = '';

  // void initState() {
  //   super.initState();
  //   final String token = widget.tokenid;
  // }

  @override
  void initState() {
    super.initState();
    // Initialize the future to fetch transcriptions
    _transcriptionsFuture = ApiService().fetchTranscriptions(widget.tokenid);
  }

  // Future<void> _toggleRecording() async {
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => RecordView(onRecordingComplete: (transcribedText) {
  //             setState(() {
  //               transcriptions.add(transcribedText);
  //             });
  //
  //             Navigator.pushReplacement(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => TranscribeResult(
  //                   transcribedText: currentTranscription,
  //                   onDelete: () => _deleteTranscription(currentTranscription),
  //                 tokenid: widget.tokenid
  //                 ),
  //               ),
  //                   // (Route<dynamic> route) => route.settings.name == '/HomePage',
  //             );
  //           },tokenid: widget.tokenid,
  //           )),
  //         // (Route<dynamic> route) => false, // This clears the entire stack
  //
  //   );
  // }

  void _deleteTranscription(String transcription) {
    setState(() {
      transcriptions.remove(transcription);
    });
  }
  // void _deleteTranscription(String transcriptionId) async {
  //   try {
  //     print('Attempting to delete transcription with ID: $transcriptionId');
  //     String id = transcriptionId.toString();
  //
  //     await DeleteApiService().deleteTranscriptionhome(id, widget.tokenid);
  //
  //     setState(() {
  //       _transcriptionsFuture = ApiService().fetchTranscriptions(widget.tokenid);
  //     });
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Transcription deleted successfully')),
  //     );
  //   } catch (e) {
  //     print('Error occurred: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to delete transcription: ${e.toString()}')),
  //     );
  //   }
  // }



  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;
    var isPortrait = mq.height > mq.width;

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
                    builder: (context) => SettingsScreen(
                      profileName: widget.profileName,
                      profilePicUrl: widget.profilePicUrl,
                    ),
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
      body:
      // Padding(
      //   padding: EdgeInsets.all(mq.width * 0.05),
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       Text(
      //         "MY Transcribe (${transcriptions.length})",
      //         style: TextStyles.defaultTextStyle(
      //           fontSize: mq.width * 0.06,
      //           fontWeight: FontWeight.bold,
      //         ),
      //       ),
      //       SizedBox(height: mq.height * 0.05),
      //       Expanded(
      //         child: transcriptions.isEmpty
      //             ? Center(
      //           child: Text(
      //             "Start recording your first thoughts...",
      //             textAlign: TextAlign.center,
      //             style: TextStyles.defaultTextStyle(
      //               fontSize: mq.width * 0.08,
      //               fontWeight: FontWeight.normal,
      //             ),
      //           ),
      //         )
      //             : ListView.builder(
      //           itemCount: transcriptions.length,
      //           itemBuilder: (context, index) {
      //             return Card(
      //               color: AppColors.ButtonColor,
      //               margin: EdgeInsets.symmetric(vertical: mq.height * 0.01),
      //               child: ListTile(
      //                 contentPadding: EdgeInsets.all(mq.width * 0.03),
      //                 title: Column(
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   children: [
      //                     Text(
      //                       transcriptions[index],
      //                       style: TextStyles.defaultTextStyle(
      //                         fontSize: mq.width * 0.05,
      //                         fontWeight: FontWeight.bold,
      //                       ),
      //                     ),
      //                     SizedBox(height: mq.height * 0.005),
      //                     Text(
      //                       transcriptions[index],
      //                       style: GoogleFonts.karla(
      //                         fontSize: mq.width * 0.04,
      //                         fontWeight: FontWeight.normal,
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //                 trailing: IconButton(
      //                   icon: Icon(
      //                     Icons.delete_outline_outlined,
      //                     color: Colors.black,
      //                     size: mq.width * 0.06,
      //                   ),
      //                   onPressed: () {
      //                     setState(() {
      //                       transcriptions.removeAt(index);
      //                     });
      //                   },
      //                 ),
      //                 onTap: () async {
      //                   final updatedTranscription = await
      //                   Navigator.push(
      //                     context,
      //                     MaterialPageRoute(
      //                       builder: (context) => TranscribeResult(
      //                         transcribedText: transcriptions[index],
      //                         onDelete: () {
      //                           setState(() {
      //                             transcriptions.removeAt(index);
      //                           });
      //                         } , tokenid:widget.tokenid ,
      //                       ),
      //                     ),
      //                   );
      //
      //                   if (updatedTranscription != null) {
      //                     setState(() {
      //                       transcriptions[index] = updatedTranscription;
      //                     });
      //                   }
      //                 },
      //               ),
      //             );
      //           },
      //         ),
      //       ),
      //     ],
      //   ),
      // ),


      Padding(
        padding: EdgeInsets.all(mq.width * 0.05),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _transcriptionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text(
                "Start recording your first thoughts...",
                textAlign: TextAlign.center,
                style: TextStyles.defaultTextStyle(
                  fontSize: mq.width * 0.08,
                  fontWeight: FontWeight.normal,
                ),
              ));
            } else {
              List<Map<String, dynamic>> transcriptions = snapshot.data!;
              return Column(
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
                    child: ListView.builder(
                      itemCount: transcriptions.length,
                      itemBuilder: (context, index) {
                        final transcription = transcriptions[index];
                        return Card(
                          color: AppColors.ButtonColor,
                          margin: EdgeInsets.symmetric(vertical: mq.height * 0.01),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(10.0),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transcription['transcribedText'],
                                  style: TextStyles.defaultTextStyle(
                                    fontSize: mq.width * 0.05,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  transcription['transcribedText'], // Summary or shortened text can be added here
                                  style: GoogleFonts.karla(
                                    fontSize: mq.width * 0.04,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete_outline_outlined,
                                color: Colors.black,
                                size: mq.width * 0.06,
                              ),
                              onPressed: () {

                                // _deleteTranscription(transcriptions[index]['id'].toString());

                                setState(() {
                                  transcriptions.removeAt(index);
                                  // Optionally, call API to delete from backend
                                });
                              },
                            ),
                            onTap: () async {
                              final updatedTranscription = await
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TranscribeResult(
                                    transcribedText: transcription['transcribedText'],
                                    onDelete: () {
                                      setState(() {
                                        transcriptions.removeAt(index);
                                      });
                                    },
                                    tokenid: widget.tokenid,
                                  ),
                                ),
                              );
                              // if (updatedTranscription != null) {
                              //   setState(() {
                              //     transcriptions[index] = updatedTranscription;
                              //   });
                              // }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecordView(
                onRecordingComplete: (transcribedText) {
                  setState(() {
                    _transcriptionsFuture = ApiService().fetchTranscriptions(widget.tokenid);
                  });

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TranscribeResult(
                        transcribedText: transcribedText,
                        onDelete: () => _deleteTranscription(transcribedText),
                        tokenid: widget.tokenid,
                      ),
                    ),
                  );
                },
                tokenid: widget.tokenid,
              ),
            ),
          );
        },
        child: Image.asset(
          'assets1/mic.png',
          width: 40.0,
          height: 40.0,
        ),
        backgroundColor: AppColors.ButtonColor2,
      ),
      // floatingActionButton: FloatingActionButton(
      //   shape: const CircleBorder(),
      //   onPressed: _toggleRecording,
      //   child: Image.asset(
      //     'assets1/mic.png',
      //     width: mq.width * 0.1,
      //     height: mq.width * 0.1,
      //   ),
      //   backgroundColor: AppColors.ButtonColor2,
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}



// import 'package:avatar_glow/avatar_glow.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:oscar_stt/core/constants/app_colors.dart';
// import 'package:oscar_stt/ui/views/transcribe/transcribe_view.dart';
// import '../../shared/styles/text_style.dart';
// import '../profile/profile_view.dart';
// import '../record/record_view.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   List<String> transcriptions = [];
//   bool isListening = false;
//   // late stt.SpeechToText _speech;
//   String currentTranscription = '';
//
//   // @override
//   // void initState() {
//   //   super.initState();
//   //   _speech = stt.SpeechToText();
//   // }
//
//
//   Future<void> _toggleRecording() async {
//     // if (!isListening) {
//     //   bool available = await _speech.initialize(
//     //     onStatus: (val) {
//     //       if (val == 'done') {
//     //         setState(() {
//     //           isListening = false;
//     //           transcriptions.add(currentTranscription);
//     //         });
//             Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                 builder: (context) => RecordView(
//               onRecordingComplete: (transcribedText)
//             {
//               setState(() {
//                 transcriptions.add(transcribedText);
//               });
//
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>
//                       TranscribeResult(
//                         transcribedText: currentTranscription,
//                         onDelete: () =>
//                             _deleteTranscription(currentTranscription),
//                       ),
//                 ),
//               );
//             })));
//           }
//     //     },
//     //     onError: (val) {
//     //       setState(() {
//     //         isListening = false;
//     //       });
//     //       print('onError: $val');
//     //     },
//     //   );
//     //
//     //   if (available) {
//     //     setState(() {
//     //       isListening = true;
//     //     });
//     //     _speech.listen(
//     //       onResult: (val) {
//     //         setState(() {
//     //           currentTranscription = val.recognizedWords;
//     //         });
//     //       },
//     //     );
//     //   } else {
//     //     setState(() {
//     //       isListening = false;
//     //     });
//     //     print('Speech recognition not available');
//     //   }
//     // } else {
//     //   _speech.stop();
//     //   setState(() {
//     //     isListening = false;
//     //   });
//     // }
//   // }
//
//
//
//
//   void _deleteTranscription(String transcription) {
//     setState(() {
//       transcriptions.remove(transcription);
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     var mq = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         title: Row(
//           children: [
//             Expanded(
//               child: Center(
//                 child: Text(
//                   'Oscar',
//                   style: TextStyles.defaultTextStyle(
//                     fontSize: mq.width * 0.08,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             ),
//             IconButton(
//               icon: Image.asset(
//                 "assets1/tips_and_updates.png",
//                 width: mq.width * 0.08,
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => SettingsScreen(),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//       drawer: Container(
//         color: Colors.lightBlue,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(mq.width * 0.05),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "MY Transcribe (${transcriptions.length})",
//               style: TextStyles.defaultTextStyle(
//                 fontSize: mq.width * 0.06,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: mq.height * 0.05),
//             Expanded(
//               child: transcriptions.isEmpty
//                   ? Center(
//                 child: Text(
//                   "Start recording your first thoughts...",
//                   textAlign: TextAlign.center,
//                   style: TextStyles.defaultTextStyle(
//                     fontSize: mq.width * 0.08,
//                     fontWeight: FontWeight.normal,
//                   ),
//                 ),
//               )
//                   : ListView.builder(
//                 itemCount: transcriptions.length,
//                 itemBuilder: (context, index) {
//                   return Card(
//                     color: AppColors.ButtonColor,
//                     margin: EdgeInsets.symmetric(vertical: mq.height * 0.01),
//                     child: ListTile(
//                       contentPadding: EdgeInsets.all(10.0),
//                       title: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             transcriptions[index],
//                             style: TextStyles.defaultTextStyle(
//                               fontSize: mq.width * 0.05,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 5.0),
//                           Text(
//                             transcriptions[index], // Body text
//                             style: GoogleFonts.karla(
//                               fontSize: mq.width * 0.04,
//                               fontWeight: FontWeight.normal, // Smaller font size for body
//                             ),
//                           ),
//                         ],
//                       ),
//                       trailing: IconButton(
//                         icon: Icon(
//                           Icons.delete_outline_outlined,
//                           color: Colors.black,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             transcriptions.removeAt(index);
//                           });
//                         },
//                       ),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => TranscribeResult(
//                               transcribedText: transcriptions[index],
//                               onDelete: () {
//                                 setState(() {
//                                   transcriptions.removeAt(index);
//                                 });
//                               },
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         shape: const CircleBorder(),
//         onPressed:
//         _toggleRecording,
//         child:
//         Image.asset(
//           'assets1/mic.png',
//           width: 40.0,
//           height: 40.0,
//         ),
//         // Icon(
//         //   isListening ? Icons.circle : Icons.mic,
//         //   color: Colors.white,
//         // ),
//         backgroundColor: AppColors.ButtonColor2,
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }
// }
//
