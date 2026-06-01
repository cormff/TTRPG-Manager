import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/primary_button.dart';
import 'login_view.dart';
import 'package:ttrpg_manager/providers/language_manager.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Register')),
        actions: [
          TextButton.icon(
            onPressed: () {
              final langManager = context.read<LanguageManager>();
              final isTr = langManager.currentLocale.languageCode == 'tr';
              langManager.changeLanguage(isTr ? 'en' : 'tr');
            },
            icon: Icon(Icons.language, color: Colors.white),
            label: Text(
              context.watch<LanguageManager>().currentLocale.languageCode == 'tr' ? 'TR' : 'EN',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            CustomTextField(
              controller: _usernameController,
              labelText: context.tr('Username'),
            ),
            const SizedBox(height: 16.0),
            CustomTextField(
              controller: _emailController,
              labelText: context.tr('Email'),
            ),
            const SizedBox(height: 16.0),
            CustomTextField(
              controller: _passwordController,
              labelText: context.tr('Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            CustomTextField(
              controller: _confirmPasswordController,
              labelText: context.tr('Confirm Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24.0),

            authProvider.isLoading
                ? const CircularProgressIndicator(color: Colors.deepPurple)
                : PrimaryButton(
              onPressed: () { /* ... aynı kontroller ... */ },
              text: context.tr('Register'),
            ),

            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginView()),
                );
              },
              child: Text(
                context.tr("Already registered? Log in"),
                style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}