import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/primary_button.dart';
import 'login_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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
      appBar: AppBar(title: Text(context.tr('register'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            CustomTextField(
              controller: _usernameController,
              labelText: context.tr('username'),
            ),
            const SizedBox(height: 16.0),
            CustomTextField(
              controller: _emailController,
              labelText: context.tr('email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            CustomTextField(
              controller: _passwordController,
              labelText: context.tr('password'),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            CustomTextField(
              controller: _confirmPasswordController,
              labelText: context.tr('confirmPassword'),
              obscureText: true,
            ),
            const SizedBox(height: 24.0),

            authProvider.isLoading
                ? const CircularProgressIndicator(
                    color: Colors.deepPurple,
                  ) // Yükleniyorsa simge çıkar
                : PrimaryButton(
                    onPressed: () {
                      // Şifre kontrolü (confirm password)
                      if (_passwordController.text !=
                          _confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.tr('passwordsDoNotMatch')),
                          ),
                        );
                        return;
                      }

                      // Boş alan kontrolü
                      if (_usernameController.text.isEmpty ||
                          _emailController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.tr('pleaseFillAllFields')),
                          ),
                        );
                        return;
                      }

                      // Provider üzerinden API'ye gönderiyoruz
                      context.read<AuthProvider>().register(
                        _usernameController.text,
                        _emailController.text,
                        _passwordController.text,
                        context,
                      );
                    },
                    text: context.tr('register'),
                  ),

            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginView()),
                );
              },
              child: Text(
                context.tr('alreadyRegisteredLogin'),
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
