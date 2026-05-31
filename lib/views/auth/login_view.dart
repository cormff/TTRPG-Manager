import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart'; // Bu importu ekle
import '../../providers/user_role_provider.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/primary_button.dart';
import 'register_view.dart';
// En üste bu importu eklemeyi unutma:
import '../../providers/notes_provider.dart';
import '../../providers/games_provider.dart';
import '../../providers/maps_provider.dart';
import 'package:ttrpg_manager/providers/language_manager.dart';

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

    final userData = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    if (userData != null) {
      final int newUserId = userData['id']; // Yeni kullanıcının ID'sini alıyoruz

      userRoleProvider.setUserData(newUserId, userData['username'], _selectedRole);

      if (mounted) {
        // ÇÖZÜM BURASI: Yeni hesaba geçer geçmez TÜM verileri çekiyoruz!

        // 1. Notları Çek
        Provider.of<NotesProvider>(context, listen: false).fetchAllNotes(newUserId);

        // 2. Rolüne göre Oyunları ve Haritaları Çek
        final gamesProvider = Provider.of<GamesProvider>(context, listen: false);
        if (_selectedRole == UserRole.gameMaster) {
          // GM ise kendi oyunlarını ve haritalarını getir
          gamesProvider.fetchGMGames(newUserId);
          Provider.of<MapsProvider>(context, listen: false).fetchAllMaps();
        } else {
          // Oyuncu ise katıldığı oyunları getir
          // Not: Kendi provider'ındaki metoda göre ismi fetchJoinedGames veya fetchPlayerGames olabilir
          gamesProvider.fetchPlayerGames(newUserId);
        }

        Navigator.of(context).pushReplacementNamed('/main_scaffold');
      }
    } else {
      // Giriş başarısız durumu
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('Hatalı email veya şifre!')),
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
      appBar: AppBar(title: Text(context.tr('Login'))),
      // ÇÖZÜM BURADA BAŞLIYOR: Center ve SingleChildScrollView eklendi
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0), // Padding'i direkt buraya verdik
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
                items: [
                  DropdownMenuItem(value: UserRole.gameMaster, child: Text(context.tr('Game Master'))),
                  DropdownMenuItem(value: UserRole.player, child: Text(context.tr('Player'))),
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
      ),
    );
  }
}