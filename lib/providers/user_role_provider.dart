import 'package:flutter/material.dart';

enum UserRole {
  gameMaster,
  player,
}

class UserRoleProvider with ChangeNotifier {
  UserRole _userRole = UserRole.player;
  String _username = "Ozi1308";

  UserRole get userRole => _userRole;
  String get username => _username;

  void setUsername(String name) {
    _username = name;
    notifyListeners();
  }

  void setUserRole(UserRole role) {
    _userRole = role;
    notifyListeners();
  }

  bool get isGameMaster => _userRole == UserRole.gameMaster;
  bool get isPlayer => _userRole == UserRole.player;
}
