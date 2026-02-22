import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/athlete.dart';

class AthleteService {
  static const String baseUrl = "https://api.ejemplo.com";

  Future<List<Athlete>> searchAthletes(String query, int teamId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/athletes/search?name=$query&teamId=$teamId'),
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((item) => Athlete.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
