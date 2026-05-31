import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttrpg_manager/main.dart';
import 'package:ttrpg_manager/providers/auth_provider.dart';
import 'package:ttrpg_manager/providers/characters_provider.dart';
import 'package:ttrpg_manager/providers/games_provider.dart';
import 'package:ttrpg_manager/providers/locale_provider.dart';
import 'package:ttrpg_manager/providers/maps_provider.dart';
import 'package:ttrpg_manager/providers/notes_provider.dart';
import 'package:ttrpg_manager/providers/user_role_provider.dart';

void main() {
  testWidgets('app starts on login screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'selected_language_code': 'en'});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => UserRoleProvider()),
          ChangeNotifierProvider(create: (_) => GamesProvider()),
          ChangeNotifierProvider(create: (_) => NotesProvider()),
          ChangeNotifierProvider(create: (_) => MapsProvider()),
          ChangeNotifierProvider(create: (_) => CharactersProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
