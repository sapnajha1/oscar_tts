// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:oscar_stt/core/constants/app_colors.dart';
// import 'package:oscar_stt/ui/shared/styles/text_style.dart';
// import 'package:oscar_stt/ui/views/profile/profile_view.dart';
// // import 'package:oscar_stt/shared/styles/text_style.dart';
// import 'package:oscar_stt/ui/views/transcribe/api_service.dart';
// import 'package:oscar_stt/ui/views/transcribe/post_transcribe.dart';
// import 'package:oscar_stt/ui/views/transcribe/transcribe_view.dart';
// // import 'package:oscar_stt/ui/views/transcribe/transcribe_result.dart';
//
// class HomePage1 extends StatefulWidget {
//   final String tokenid;
//   const HomePage1({Key? key, required this.tokenid}) : super(key: key);
//
//   @override
//   State<HomePage1> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage1> {
//   late Future<List<Map<String, dynamic>>> _transcriptionsFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize the future to fetch transcriptions
//     _transcriptionsFuture = ApiService().fetchTranscriptions(widget.tokenid);
//   }
//
//   void _deleteTranscription(String transcription) {
//     setState(() {
//       // transcriptions.remove(transcription);
//       // Optionally, you could also call an API to delete the transcription from the backend
//     });
//   }
//
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
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   transcriptions.removeAt(index);
//                                   // Optionally, call API to delete from backend
//                                 });
//                               },
//                             ),
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => TranscribeResult(
//                                     transcribedText: transcription['transcribedText'],
//                                     onDelete: () {
//                                       setState(() {
//                                         transcriptions.removeAt(index);
//                                       });
//                                     },
//                                     tokenid: widget.tokenid,
//                                   ),
//                                 ),
//                               );
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
//       floatingActionButton: FloatingActionButton(
//         shape: const CircleBorder(),
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => RecordView1(
//                 onRecordingComplete: (transcribedText) {
//                   setState(() {
//                     _transcriptionsFuture = ApiService().fetchTranscriptions(widget.tokenid);
//                   });
//
//                   Navigator.push(
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
//             ),
//           );
//         },
//         child: Image.asset(
//           'assets1/mic.png',
//           width: 40.0,
//           height: 40.0,
//         ),
//         backgroundColor: AppColors.ButtonColor2,
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }
// }