// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class DeleteApiService {
//   static const String baseUrl = 'https://dev-oscar.merakilearn.org/api/v1/transcriptions/$transcriptionId';
//
//   Future<void> deleteTranscriptionhome(String id, String token) async {
//     final url = '$baseUrl/transcriptions/$id';
//
//     final response = await http.delete(
//       Uri.parse(url),
//       headers: {
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode != 200) {
//       throw Exception('Failed to delete transcription');
//     }
//   }
//
//   Future<List<Map<String, dynamic>>> fetchTranscriptions(String token) async {
//     final url = '$baseUrl/transcriptions';
//
//     final response = await http.get(
//       Uri.parse(url),
//       headers: {
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       List<dynamic> data = jsonDecode(response.body);
//       return List<Map<String, dynamic>>.from(data);
//     } else {
//       throw Exception('Failed to load transcriptions');
//     }
//   }
// }


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
