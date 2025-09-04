import 'dart:convert';
import 'package:http/http.dart' as http;

class NominatimService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org/search';

  Future<List<Map<String, dynamic>>> search(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final uri = Uri.parse('$_baseUrl?q=$query&format=json&addressdetails=1&limit=5');
    final response = await http.get(uri, headers: {'User-Agent': 'TeamMatesApp'});

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load suggestions: ${response.statusCode}');
    }
  }
}
