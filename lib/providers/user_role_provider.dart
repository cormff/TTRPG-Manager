import 'package:flutter/material.dart';

enum UserRole {
  gameMaster,
  player,
}

class UserRoleProvider with ChangeNotifier {
  UserRole _userRole = UserRole.player; // Default role

  UserRole get userRole => _userRole;

  void setUserRole(UserRole role) {
    _userRole = role;
    notifyListeners();
  }

  bool get isGameMaster => _userRole == UserRole.gameMaster;
  bool get isPlayer => _userRole == UserRole.player;
}