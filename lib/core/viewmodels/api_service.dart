
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  final String apiUrl = 'https://dev-oscar.merakilearn.org/api/v1/transcriptions';

  Future<List<Map<String, dynamic>>> fetchTranscriptions(String tokenid) async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer ${tokenid}',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return List<Map<String, dynamic>>.from(responseBody['data']);
      } else {
        throw Exception('Failed to load transcriptions');
      }
    } catch (e) {
      print('Error fetching transcriptions: $e');
      return [];
    }
  }
}