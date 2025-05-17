import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gold/model/model.dart';

class ApiService {
  static const String apiUrl = 'https://brsapi.ir/Api/Market/Gold_Currency.php';
  static const String apiKey = 'FreeCVZOzEEHqTeTpT2r99EqygebOB9L';

  static Future<Gold?> fetchGoldData() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        // Print response for debugging
        print('API Response: ${response.body}');

        // Try parsing with null safety
        try {
          return goldFromJson(response.body);
        } catch (parseError) {
          print('Error parsing JSON: $parseError');

          // Try manual parsing as fallback
          final jsonData = json.decode(response.body);
          return Gold.fromJson(jsonData);
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching gold data: $e');
      return null;
    }
  }
}
