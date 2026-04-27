import 'package:flutter/material.dart';

enum UserRole {
  gameMaster,
  player,
}

class UserRoleProvider with ChangeNotifier {
  UserRole _userRole = UserRole.player;
  String _username = "";
  int? _userId; // Yeni eklenen alan

  UserRole get userRole => _userRole;
  String get username => _username;
  int? get userId => _userId; // ID'yi dışarı açıyoruz

  void setUserData(int id, String name, UserRole role) {
    _userId = id;
    _username = name;
    _userRole = role;
    notifyListeners();
  }

  // Yan menüden veya ayarlardan sadece rolü değiştirmek için kullanılan metot
  void setUserRole(UserRole role) {
    _userRole = role;
    notifyListeners();
  }

  bool get isGameMaster => _userRole == UserRole.gameMaster;
  bool get isPlayer => _userRole == UserRole.player;
}
