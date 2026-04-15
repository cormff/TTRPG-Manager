import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // --- KAYIT METODU ---
  Future<void> register(String username, String email, String password, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final success = await _authService.registerUser(
      UserModel(username: username, email: email, password: password),
    );

    _isLoading = false;
    notifyListeners();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kayıt Başarılı!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kayıt Başarısız! Sunucuyu kontrol edin.")),
      );
    }
  }

  // --- GİRİŞ METODU (EKSİK OLAN KISIM) ---
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners(); // Ekranı "Yükleniyor" durumuna sokar

    // AuthService üzerinden Java API'sine istek atıyoruz
    final success = await _authService.loginUser(email, password);

    _isLoading = false;
    notifyListeners(); // Yükleme bittiğinde ekranı günceller

    return success; // Sonucu LoginView'a döndürür
  }
}