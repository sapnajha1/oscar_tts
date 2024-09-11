import 'package:flutter/material.dart';

import 'api_service.dart';

class TranscriptionsPage extends StatefulWidget {
  final String tokenid;

  TranscriptionsPage({required this.tokenid});

  @override
  _TranscriptionsPageState createState() => _TranscriptionsPageState();
}

class _TranscriptionsPageState extends State<TranscriptionsPage> {
  late Future<List<Map<String, dynamic>>> _transcriptions;

  @override
  void initState() {
    super.initState();
    _transcriptions = ApiService().fetchTranscriptions(widget.tokenid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transcriptions'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _transcriptions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No transcriptions found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final transcription = snapshot.data![index];
                return ListTile(
                  title: Text(transcription['transcribedText']),
                  subtitle: Text('Created at: ${transcription['createdAt']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}