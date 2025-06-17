import 'package:http/http.dart' as http;
import 'dart:convert'; // For potential JSON parsing, if you serve JSON

class PolicyService {
  final String _baseUrl = 'https://your-backend.com/api/policies'; // Replace with your actual base URL

  Future<String> fetchPrivacyPolicy() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/privacy_policy.txt')); // Or .json, .html
      if (response.statusCode == 200) {
        // Assuming plain text content
        return utf8.decode(response.bodyBytes);
      } else {
        throw Exception('Failed to load privacy policy: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error or failed to parse privacy policy: $e');
    }
  }

  Future<String> fetchRulesAndRegulations() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/rules_and_regulations.txt'));
      if (response.statusCode == 200) {
        return utf8.decode(response.bodyBytes);
      } else {
        throw Exception('Failed to load rules and regulations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error or failed to parse rules and regulations: $e');
    }
  }
}