import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ttrpg_manager/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_role_provider.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/primary_button.dart';
import 'register_view.dart';
import '../../providers/notes_provider.dart';
import '../../providers/games_provider.dart';
import '../../providers/maps_provider.dart';

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
    final l10n = AppLocalizations.of(context)!;

    final userData = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    if (userData != null) {
      final int newUserId = userData['id'];

      userRoleProvider.setUserData(newUserId, userData['username'], _selectedRole);

      if (mounted) {
        Provider.of<NotesProvider>(context, listen: false).fetchAllNotes(newUserId);

        final gamesProvider = Provider.of<GamesProvider>(context, listen: false);
        if (_selectedRole == UserRole.gameMaster) {
          gamesProvider.fetchGMGames(newUserId);
          Provider.of<MapsProvider>(context, listen: false).fetchAllMaps();
        } else {
          gamesProvider.fetchPlayerGames(newUserId);
        }

        Navigator.of(context).pushReplacementNamed('/main_scaffold');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.language == 'Dil' ? 'Hatalı email veya şifre!' : 'Invalid email or password!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.login)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextField(
                controller: _emailController,
                labelText: l10n.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16.0),
              CustomTextField(
                controller: _passwordController,
                labelText: l10n.password,
                obscureText: true,
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                decoration: InputDecoration(labelText: l10n.language == 'Dil' ? 'Rol Seçin' : 'Select Role'),
                items: [
                  DropdownMenuItem(value: UserRole.gameMaster, child: Text(l10n.gameMaster)),
                  DropdownMenuItem(value: UserRole.player, child: Text(l10n.player)),
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
                text: l10n.login,
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterView()),
                  );
                },
                child: Text(
                  l10n.language == 'Dil' ? "Hesabınız yok mu? Kayıt Ol" : "Don't have an account? Register",
                  style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

