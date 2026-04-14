import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ttrpg_manager/providers/user_role_provider.dart';
import 'package:ttrpg_manager/widgets/custom_textfield.dart';
import 'package:ttrpg_manager/widgets/primary_button.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.player; // Default selection

  void _login() {
    final userRoleProvider = Provider.of<UserRoleProvider>(context, listen: false);
    userRoleProvider.setUserRole(_selectedRole);

    // Rol ne olursa olsun BÜTÜN navigasyon artık MainScaffold üzerinden dönmeli
    Navigator.of(context).pushReplacementNamed('/main_scaffold');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              controller: _usernameController,
              labelText: 'Username',
            ),
            const SizedBox(height: 16.0),
            CustomTextField(
              controller: _passwordController,
              labelText: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<UserRole>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Select Role',
              ),
              items: const [
                DropdownMenuItem(
                  value: UserRole.gameMaster,
                  child: Text('Game Master'),
                ),
                DropdownMenuItem(
                  value: UserRole.player,
                  child: Text('Player'),
                ),
              ],
              onChanged: (UserRole? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedRole = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 24.0),
            PrimaryButton(
              onPressed: _login,
              text: 'Login',
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterView()),
                );
              },
              child: Text(
                "Don't have an account? Register",
                style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}