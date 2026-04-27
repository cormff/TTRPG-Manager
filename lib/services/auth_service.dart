import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  // Android Emülatör: http://10.0.2.2:8080 | iOS/Web: http://localhost:8080
  final String baseUrl = "http://10.0.2.2:8080/api/users";

  Future<bool> registerUser(UserModel user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(user.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Servis Hatası: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.trim(),
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null; // Başarısızsa null döndür
    } catch (e) {
      print("Bağlantı Hatası: $e");
      return null;
    }
  }
}