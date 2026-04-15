import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart'; // Bu importu ekle
import '../../providers/user_role_provider.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/primary_button.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.player;

  Future<void> _login() async {
    final authProvider = context.read<AuthProvider>();
    final userRoleProvider = context.read<UserRoleProvider>();

    // 1. Java API üzerinden giriş kontrolü yapıyoruz
    // Backend'de yazdığımız metot email beklediği için ilk parametreye email veriyoruz
    final bool success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    if (success) {
      // 2. Giriş başarılıysa rolü set et ve ana ekrana geç
      userRoleProvider.setUserRole(_selectedRole);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/main_scaffold');
      }
    } else {
      // 3. Giriş başarısızsa kullanıcıya hata göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hatalı email veya şifre!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              controller: _emailController,
              labelText: 'Email',
              keyboardType: TextInputType.emailAddress,
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
              decoration: const InputDecoration(labelText: 'Select Role'),
              items: const [
                DropdownMenuItem(value: UserRole.gameMaster, child: Text('Game Master')),
                DropdownMenuItem(value: UserRole.player, child: Text('Player')),
              ],
              onChanged: (UserRole? newValue) {
                if (newValue != null) setState(() => _selectedRole = newValue);
              },
            ),
            const SizedBox(height: 24.0),

            isLoading
                ? const CircularProgressIndicator()
                : PrimaryButton(
              onPressed: _login,
              text: 'Login',
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterView()),
                );
              },
              child: const Text(
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