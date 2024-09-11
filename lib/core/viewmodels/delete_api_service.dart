

import 'package:http/http.dart' as http;

class DeleteApiService {
  Future<void> deleteTranscriptionhome(String id, String tokenId) async {
    final url = Uri.parse('https://yourapiurl.com/api/v1/transcriptions/$id');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $tokenId',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete transcription');
    }
  }
}
