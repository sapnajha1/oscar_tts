import 'dart:convert';
import 'package:http/http.dart' as http;

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

  const HomePage({
    Key? key,
    required this.transcribedata,
    required this.profileName,
    required this.profilePicUrl,
    required this.tokenid,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>> _transcriptionsFuture;
  List<Map<String, dynamic>> _currentTranscriptions = [];

  @override
  void initState() {
    super.initState();
    _transcriptionsFuture = ApiService().fetchTranscriptions(widget.tokenid);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)?.settings.arguments == true) {
        _showRefreshAlertDialog();
      }
    });
  }

  void _showRefreshAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notice'),
          content: Text('Refresh page for new Transcription'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshData() async {
    final newTranscriptions = await ApiService().fetchTranscriptions(widget.tokenid);

    setState(() {
      _transcriptionsFuture = Future.value(newTranscriptions);
    });

    if (_currentTranscriptions.length < newTranscriptions.length) {
      _showNewTranscriptionSnackBar();
    }

    _currentTranscriptions = newTranscriptions;
  }

  void _showNewTranscriptionSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New transcription added'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Future<void> _deleteTranscription(String transcriptionId) async {
  //   try {
  //     await DeleteApiService().deleteTranscriptionhome(transcriptionId, widget.tokenid);
  //     _refreshData();
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to delete transcription: ${e.toString()}')),
  //     );
  //   }
  // }

  void _deleteTranscription(String transcriptionId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://dev-oscar.merakilearn.org/api/v1/transcriptions/$transcriptionId'),
        headers: {'Authorization': 'Bearer ${widget.tokenid}'},
      );

      if (response.statusCode == 200) {
        // Successfully deleted, you may need to refresh the data
        print('deleted successfully');
        setState(() {
          _transcriptionsFuture = _fetchTranscriptions(); // Refresh the data
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transcription deleted'),
          ),
        );
      } else if(response.statusCode == 400){
        print('bad request');

      }
      else if(response.statusCode == 404){
        print('Transcription not found');

      }
      else {
        throw Exception('Failed to delete transcription');
      }
    } catch (e) {
      // Handle the error
      print('Error: $e');
    }
  }
  //
  Future<List<Map<String, dynamic>>> _fetchTranscriptions() async {
    final response = await http.get(
      Uri.parse('https://dev-oscar.merakilearn.org/api/v1/transcriptions'),
      headers: {'Authorization': 'Bearer ${widget.tokenid}'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Failed to load transcriptions');
    }
  }

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
        ),),
    // drawer: Container(
    //     color: Colors.lightBlue,
    //   ),

      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Padding(
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
                                  Icons.delete_outline_rounded,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  _deleteTranscription(transcription['id'].toString());
                                },
                              ),
                              onTap: () async {
                                bool? result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TranscribeResult(
                                      transcribedText: transcription['transcribedText'],
                                      onDelete: () {
                                        _deleteTranscription(transcription['id']);
                                      },
                                      tokenid: widget.tokenid,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  _refreshData(); // Refresh data if result indicates changes
                                }
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


      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () async {
          final newTranscription = await
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecordView(
                  onRecordingComplete: (transcribedText) {
                    _refreshData();
                    setState(() {
                      _transcriptionsFuture = _fetchTranscriptions();
                    });

                    // setState(() {
                    //   _transcriptionsFuture = ApiService().fetchTranscriptions(widget.tokenid);
                    // });

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
              )
          );
          if (newTranscription != null) {
            _refreshData();
          }
        },
        child: Image.asset(
          'assets1/mic.png',
          width: 40.0,
          height: 40.0,
        ),
        backgroundColor: AppColors.ButtonColor2,
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}


//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
// class HomePage extends StatefulWidget {
//   final String profileName;
//   final String profilePicUrl;
//   final String transcribedata;
//   final String tokenid;
//
//   const HomePage( {Key? key, required this.transcribedata, required this.profileName, required this.profilePicUrl, required this.tokenid}) : super(key: key);
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   late Future<List<Map<String, dynamic>>> _transcriptionsFuture;
//
//
//   List<String> transcriptions = [];
//   bool isListening = false;
//   String currentTranscription = '';
//
//   // void initState() {
//   //   super.initState();
//   //   final String token = widget.tokenid;
//   // }
//
//
//   @override
//   void initState() {
//     super.initState();
//     _transcriptionsFuture = ApiService().fetchTranscriptions(widget.tokenid);
//   }
//
//   void _refreshData() {
//     setState(() {
//       _transcriptionsFuture = ApiService().fetchTranscriptions(widget.tokenid);
//     });
//   }
//
//
//   //  _deleteTranscription(String transcriptionId) {
//   //   setState(() {
//   //     // Remove the transcription locally
//   //     _transcriptionsFuture = _transcriptionsFuture.then((transcriptions) {
//   //       return transcriptions.where((transcription) => transcription['id'] != transcriptionId).toList();
//   //     });
//   //   });
//   //
//   //   // Optionally, call API to delete from backend
//   // }
//   Future<void> _deleteTranscription(String transcriptionId) async {
//     try {
//       await DeleteApiService().deleteTranscriptionhome(transcriptionId, widget.tokenid);
//       _refreshData();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to delete transcription: ${e.toString()}')),
//       );
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     var mq = MediaQuery.of(context).size;
//     var isPortrait = mq.height > mq.width;
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
//                     builder: (context) => SettingsScreen(
//                       profileName: widget.profileName,
//                       profilePicUrl: widget.profilePicUrl,
//                     ),
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
//       body:
//
//       Padding(
//         padding: EdgeInsets.all(mq.width * 0.05),
//         child: FutureBuilder<List<Map<String, dynamic>>>(
//           future: _transcriptionsFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             } else if (snapshot.hasError) {
//               return Center(child: Text('Error: ${snapshot.error}'));
//             } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return Center(child: Text(
//                 "Start recording your first thoughts...",
//                 textAlign: TextAlign.center,
//                 style: TextStyles.defaultTextStyle(
//                   fontSize: mq.width * 0.08,
//                   fontWeight: FontWeight.normal,
//                 ),
//               ));
//             } else {
//               List<Map<String, dynamic>> transcriptions = snapshot.data!;
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "MY Transcribe (${transcriptions.length})",
//                     style: TextStyles.defaultTextStyle(
//                       fontSize: mq.width * 0.06,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: mq.height * 0.05),
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: transcriptions.length,
//                       itemBuilder: (context, index) {
//                         final transcription = transcriptions[index];
//                         return Card(
//                           color: AppColors.ButtonColor,
//                           margin: EdgeInsets.symmetric(vertical: mq.height * 0.01),
//                           child: ListTile(
//                             contentPadding: EdgeInsets.all(10.0),
//                             title: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   transcription['transcribedText'],
//                                   style: TextStyles.defaultTextStyle(
//                                     fontSize: mq.width * 0.05,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 SizedBox(height: 5.0),
//                                 Text(
//                                   transcription['transcribedText'], // Summary or shortened text can be added here
//                                   style: GoogleFonts.karla(
//                                     fontSize: mq.width * 0.04,
//                                     fontWeight: FontWeight.normal,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             trailing: IconButton(
//                               icon: Icon(
//                                 Icons.delete_outline_outlined,
//                                 color: Colors.black,
//                                 size: mq.width * 0.06,
//                               ),
//                               onPressed: () async {
//
//                                 // _deleteTranscription(transcriptions[index]['id'].toString());
//                                await _deleteTranscription(transcription['id'].toString(),);
//                                _refreshData();
//
//                                 // setState(() {
//                                 //   transcriptions.removeAt(index);
//                                 //   // Optionally, call API to delete from backend
//                                 // });
//                               },
//                             ),
//                             onTap: () async {
//                               final updatedTranscription = await
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => TranscribeResult(
//                                     transcribedText: transcription['transcribedText'],
//                                     onDelete: () {
//                                       _deleteTranscription(transcription['id'].toString());
//
//                                       // setState(() {
//                                       //   transcriptions.removeAt(index);
//                                       // });
//                                     },
//                                     tokenid: widget.tokenid,
//                                   ),
//                                 ),
//                               );
//                               if (updatedTranscription != null) {
//                                 _refreshData();
//                               }
//                             },
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               );
//             }
//           },
//         ),
//       ),
//
//       floatingActionButton: FloatingActionButton(
//         shape: const CircleBorder(),
//         onPressed: () async {
//           final newTranscription = await
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => RecordView(
//                 onRecordingComplete: (transcribedText) {
//                   _refreshData();
//
//                   // setState(() {
//                   //   _transcriptionsFuture = ApiService().fetchTranscriptions(widget.tokenid);
//                   // });
//
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => TranscribeResult(
//                         transcribedText: transcribedText,
//                         onDelete: () => _deleteTranscription(transcribedText),
//                         tokenid: widget.tokenid,
//                       ),
//                     ),
//                   );
//                 },
//                 tokenid: widget.tokenid,
//               ),
//             )
//           );
//           if (newTranscription != null) {
//             _refreshData();
//           }
//         },
//         child: Image.asset(
//           'assets1/mic.png',
//           width: 40.0,
//           height: 40.0,
//         ),
//         backgroundColor: AppColors.ButtonColor2,
//       ),
//
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }
// }
//
