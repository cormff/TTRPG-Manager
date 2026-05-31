import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:ttrpg_manager/l10n/app_localizations.dart';
import 'package:ttrpg_manager/providers/auth_provider.dart';
import 'package:ttrpg_manager/providers/locale_provider.dart';
import 'package:ttrpg_manager/providers/user_role_provider.dart';
import 'package:ttrpg_manager/views/auth/login_view.dart';
import 'package:ttrpg_manager/views/auth/register_view.dart';
import 'package:ttrpg_manager/views/main_scaffold.dart';
import 'package:ttrpg_manager/utils/app_theme.dart';
import 'package:ttrpg_manager/views/gm/my_games_gm_view.dart';
import 'package:ttrpg_manager/views/player/my_games_player_view.dart';
import 'package:ttrpg_manager/views/gm/create_game_view.dart';
import 'package:ttrpg_manager/views/gm/my_maps_view.dart';
import 'package:ttrpg_manager/views/player/join_game_view.dart';
import 'package:ttrpg_manager/views/game/notes_view.dart';
import 'package:ttrpg_manager/views/rulebook/rule_books_view.dart';
import 'package:ttrpg_manager/views/game/characters_view.dart';

import 'package:ttrpg_manager/providers/notes_provider.dart';
import 'package:ttrpg_manager/providers/games_provider.dart';
import 'package:ttrpg_manager/providers/maps_provider.dart';
import 'package:ttrpg_manager/providers/characters_provider.dart';

void main() {
  runApp(
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
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => context.tr('app.title'),
      theme: AppTheme.darkTheme,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/main_scaffold': (context) => const MainScaffold(),
        '/my_games_player_view': (context) => const MyGamesPlayerView(),
        '/my_games_gm_view': (context) => const MyGamesGMView(),
        '/create_game': (context) => const CreateGameView(),
        '/my_maps': (context) => const MyMapsView(),
        '/notes': (context) => const NotesView(),
        '/rule_books': (context) => const RuleBooksView(),
        '/join_game': (context) => const JoinGameView(),
        '/characters': (context) => const CharactersView(),
      },
    );
  }
}
