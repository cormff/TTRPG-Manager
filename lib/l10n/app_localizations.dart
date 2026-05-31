import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'TTRPG Manager'**
  String get appTitle;

  /// No description provided for @gameMaster.
  ///
  /// In en, this message translates to:
  /// **'Game Master'**
  String get gameMaster;

  /// No description provided for @player.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get player;

  /// No description provided for @myGames.
  ///
  /// In en, this message translates to:
  /// **'My Games'**
  String get myGames;

  /// No description provided for @createGame.
  ///
  /// In en, this message translates to:
  /// **'Create Game'**
  String get createGame;

  /// No description provided for @myMaps.
  ///
  /// In en, this message translates to:
  /// **'My Maps'**
  String get myMaps;

  /// No description provided for @npcs.
  ///
  /// In en, this message translates to:
  /// **'NPC\'s'**
  String get npcs;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @ruleBooks.
  ///
  /// In en, this message translates to:
  /// **'Rule Books'**
  String get ruleBooks;

  /// No description provided for @changeToPlayerView.
  ///
  /// In en, this message translates to:
  /// **'Change to Player View'**
  String get changeToPlayerView;

  /// No description provided for @changeToGMView.
  ///
  /// In en, this message translates to:
  /// **'Change to GM View'**
  String get changeToGMView;

  /// No description provided for @joinGame.
  ///
  /// In en, this message translates to:
  /// **'Join Game'**
  String get joinGame;

  /// No description provided for @characters.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get characters;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match!'**
  String get passwordsDoNotMatch;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @alreadyRegisteredLogin.
  ///
  /// In en, this message translates to:
  /// **'Already registered? Log in'**
  String get alreadyRegisteredLogin;

  /// No description provided for @dontHaveAccountRegister.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get dontHaveAccountRegister;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Select Role'**
  String get selectRole;

  /// No description provided for @invalidEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password!'**
  String get invalidEmailPassword;

  /// No description provided for @gmShort.
  ///
  /// In en, this message translates to:
  /// **'GM'**
  String get gmShort;

  /// No description provided for @races.
  ///
  /// In en, this message translates to:
  /// **'Races'**
  String get races;

  /// No description provided for @racesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore the diverse peoples of the world'**
  String get racesSubtitle;

  /// No description provided for @classes.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get classes;

  /// No description provided for @classesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your path and abilities'**
  String get classesSubtitle;

  /// No description provided for @equipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipment;

  /// No description provided for @equipmentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Weapons, armor, tools, and adventuring gear'**
  String get equipmentSubtitle;

  /// No description provided for @monsters.
  ///
  /// In en, this message translates to:
  /// **'Monsters'**
  String get monsters;

  /// No description provided for @monstersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Creatures, stats, legendary actions, and beasts'**
  String get monstersSubtitle;

  /// No description provided for @spells.
  ///
  /// In en, this message translates to:
  /// **'Spells'**
  String get spells;

  /// No description provided for @spellsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Master the arcane and divine arts'**
  String get spellsSubtitle;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// No description provided for @maps.
  ///
  /// In en, this message translates to:
  /// **'Maps'**
  String get maps;

  /// No description provided for @players.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// No description provided for @noMapsAdded.
  ///
  /// In en, this message translates to:
  /// **'No maps has been added yet.'**
  String get noMapsAdded;

  /// No description provided for @noNotesAdded.
  ///
  /// In en, this message translates to:
  /// **'No notes has been added yet.'**
  String get noNotesAdded;

  /// No description provided for @seeAllNotes.
  ///
  /// In en, this message translates to:
  /// **'See all notes'**
  String get seeAllNotes;

  /// No description provided for @noGamesJoined.
  ///
  /// In en, this message translates to:
  /// **'You have not joined any games yet.'**
  String get noGamesJoined;

  /// No description provided for @noCharactersCreated.
  ///
  /// In en, this message translates to:
  /// **'No characters have been created yet.'**
  String get noCharactersCreated;

  /// No description provided for @myJoinedGames.
  ///
  /// In en, this message translates to:
  /// **'My Joined Games'**
  String get myJoinedGames;

  /// No description provided for @noAdventureNotes.
  ///
  /// In en, this message translates to:
  /// **'No adventure notes yet.'**
  String get noAdventureNotes;

  /// No description provided for @tapToRecord.
  ///
  /// In en, this message translates to:
  /// **'Tap + to record your journey!'**
  String get tapToRecord;

  /// No description provided for @newNote.
  ///
  /// In en, this message translates to:
  /// **'New Note'**
  String get newNote;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit Note'**
  String get editNote;

  /// No description provided for @newGMEntry.
  ///
  /// In en, this message translates to:
  /// **'New GM Entry'**
  String get newGMEntry;

  /// No description provided for @newPlayerLog.
  ///
  /// In en, this message translates to:
  /// **'New Player Log'**
  String get newPlayerLog;

  /// No description provided for @deleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete Note?'**
  String get deleteNote;

  /// No description provided for @areYouSureDeleteNote.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this note?'**
  String get areYouSureDeleteNote;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @subCategoryOptional.
  ///
  /// In en, this message translates to:
  /// **'Sub-Category (Optional)'**
  String get subCategoryOptional;

  /// No description provided for @titleExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. The Mysterious Stranger'**
  String get titleExample;

  /// No description provided for @writeWhatHappened.
  ///
  /// In en, this message translates to:
  /// **'Write down what happened...'**
  String get writeWhatHappened;

  /// No description provided for @gmNotes.
  ///
  /// In en, this message translates to:
  /// **'GM Notes'**
  String get gmNotes;

  /// No description provided for @playerNotes.
  ///
  /// In en, this message translates to:
  /// **'Player Notes'**
  String get playerNotes;

  /// No description provided for @npc.
  ///
  /// In en, this message translates to:
  /// **'NPC'**
  String get npc;

  /// No description provided for @quest.
  ///
  /// In en, this message translates to:
  /// **'Quest'**
  String get quest;

  /// No description provided for @loot.
  ///
  /// In en, this message translates to:
  /// **'Loot'**
  String get loot;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @combat.
  ///
  /// In en, this message translates to:
  /// **'Combat'**
  String get combat;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @mapPool.
  ///
  /// In en, this message translates to:
  /// **'Map Pool'**
  String get mapPool;

  /// No description provided for @addNewMap.
  ///
  /// In en, this message translates to:
  /// **'Add New Map'**
  String get addNewMap;

  /// No description provided for @mapName.
  ///
  /// In en, this message translates to:
  /// **'Map Name'**
  String get mapName;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from gallery'**
  String get pickFromGallery;

  /// No description provided for @enterUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter URL'**
  String get enterUrl;

  /// No description provided for @imageUrl.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get imageUrl;

  /// No description provided for @openGallery.
  ///
  /// In en, this message translates to:
  /// **'Open gallery'**
  String get openGallery;

  /// No description provided for @addMapToPool.
  ///
  /// In en, this message translates to:
  /// **'Add map to pool'**
  String get addMapToPool;

  /// No description provided for @mapAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Map successfully added to database!'**
  String get mapAddedSuccess;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred!'**
  String get errorOccurred;

  /// No description provided for @myCharacters.
  ///
  /// In en, this message translates to:
  /// **'My Characters'**
  String get myCharacters;

  /// No description provided for @addNpc.
  ///
  /// In en, this message translates to:
  /// **'Add NPC'**
  String get addNpc;

  /// No description provided for @addCharacter.
  ///
  /// In en, this message translates to:
  /// **'Add Character'**
  String get addCharacter;

  /// No description provided for @characterImageOptional.
  ///
  /// In en, this message translates to:
  /// **'Character Image (Optional)'**
  String get characterImageOptional;

  /// No description provided for @nameWithAsterisk.
  ///
  /// In en, this message translates to:
  /// **'Name *'**
  String get nameWithAsterisk;

  /// No description provided for @nameExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. Gandalf, Aragorn'**
  String get nameExample;

  /// No description provided for @raceWithAsterisk.
  ///
  /// In en, this message translates to:
  /// **'Race *'**
  String get raceWithAsterisk;

  /// No description provided for @classWithAsterisk.
  ///
  /// In en, this message translates to:
  /// **'Class *'**
  String get classWithAsterisk;

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level: {level}'**
  String levelLabel(Object level);

  /// No description provided for @background.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get background;

  /// No description provided for @alignment.
  ///
  /// In en, this message translates to:
  /// **'Alignment'**
  String get alignment;

  /// No description provided for @gameOptional.
  ///
  /// In en, this message translates to:
  /// **'Game (Optional)'**
  String get gameOptional;

  /// No description provided for @noGameLink.
  ///
  /// In en, this message translates to:
  /// **'No game link'**
  String get noGameLink;

  /// No description provided for @abilityScores.
  ///
  /// In en, this message translates to:
  /// **'Ability Scores'**
  String get abilityScores;

  /// No description provided for @abilityScoresNote.
  ///
  /// In en, this message translates to:
  /// **'Standard: 10 | Modifier calculated automatically'**
  String get abilityScoresNote;

  /// No description provided for @combatStats.
  ///
  /// In en, this message translates to:
  /// **'Combat Stats'**
  String get combatStats;

  /// No description provided for @speedLabel.
  ///
  /// In en, this message translates to:
  /// **'Speed: {speed} ft'**
  String speedLabel(Object speed);

  /// No description provided for @backstory.
  ///
  /// In en, this message translates to:
  /// **'Backstory'**
  String get backstory;

  /// No description provided for @backstoryHint.
  ///
  /// In en, this message translates to:
  /// **'Character\'s past, motivation...'**
  String get backstoryHint;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @nameRaceClassRequired.
  ///
  /// In en, this message translates to:
  /// **'Name, Race, and Class are required fields.'**
  String get nameRaceClassRequired;

  /// No description provided for @npcAdded.
  ///
  /// In en, this message translates to:
  /// **'NPC added!'**
  String get npcAdded;

  /// No description provided for @characterAdded.
  ///
  /// In en, this message translates to:
  /// **'Character added!'**
  String get characterAdded;

  /// No description provided for @errorDuringSave.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during save.'**
  String get errorDuringSave;

  /// No description provided for @noNpcAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No NPCs added yet.'**
  String get noNpcAddedYet;

  /// No description provided for @noCharactersAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No characters added yet.'**
  String get noCharactersAddedYet;

  /// No description provided for @tapPlusToCreate.
  ///
  /// In en, this message translates to:
  /// **'Tap + button to create one!'**
  String get tapPlusToCreate;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @race.
  ///
  /// In en, this message translates to:
  /// **'Race'**
  String get race;

  /// No description provided for @charClass.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get charClass;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @createNewCampaign.
  ///
  /// In en, this message translates to:
  /// **'Create New Campaign'**
  String get createNewCampaign;

  /// No description provided for @campaignTitle.
  ///
  /// In en, this message translates to:
  /// **'Campaign Title'**
  String get campaignTitle;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @maxPlayersLabel.
  ///
  /// In en, this message translates to:
  /// **'Max Players:'**
  String get maxPlayersLabel;

  /// No description provided for @publicGame.
  ///
  /// In en, this message translates to:
  /// **'Public Game'**
  String get publicGame;

  /// No description provided for @visibleToEveryone.
  ///
  /// In en, this message translates to:
  /// **'Visible to everyone in search results'**
  String get visibleToEveryone;

  /// No description provided for @createCampaign.
  ///
  /// In en, this message translates to:
  /// **'Create Campaign'**
  String get createCampaign;

  /// No description provided for @gameCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Game Successfully Created!'**
  String get gameCreatedSuccess;

  /// No description provided for @findGames.
  ///
  /// In en, this message translates to:
  /// **'Find Games'**
  String get findGames;

  /// No description provided for @joinPrivateGame.
  ///
  /// In en, this message translates to:
  /// **'Join to a Private Game'**
  String get joinPrivateGame;

  /// No description provided for @inviteCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: A7X9BQ'**
  String get inviteCodeHint;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @publicGames.
  ///
  /// In en, this message translates to:
  /// **'Public Games'**
  String get publicGames;

  /// No description provided for @noPublicGames.
  ///
  /// In en, this message translates to:
  /// **'No public games have been created yet.'**
  String get noPublicGames;

  /// No description provided for @yourGame.
  ///
  /// In en, this message translates to:
  /// **'Your Game'**
  String get yourGame;

  /// No description provided for @alreadyJoined.
  ///
  /// In en, this message translates to:
  /// **'Already Joined'**
  String get alreadyJoined;

  /// No description provided for @worldIsFull.
  ///
  /// In en, this message translates to:
  /// **'World is full'**
  String get worldIsFull;

  /// No description provided for @joinedSuccess.
  ///
  /// In en, this message translates to:
  /// **'You have successfully joined the game!'**
  String get joinedSuccess;

  /// No description provided for @editGame.
  ///
  /// In en, this message translates to:
  /// **'Edit Game'**
  String get editGame;

  /// No description provided for @gameUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Game successfully updated!'**
  String get gameUpdatedSuccess;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed. Try again later.'**
  String get updateFailed;

  /// No description provided for @invitationCode.
  ///
  /// In en, this message translates to:
  /// **'Game invitation code'**
  String get invitationCode;

  /// No description provided for @invitationCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Invitation code copied: {code}'**
  String invitationCodeCopied(Object code);

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get copyCode;

  /// No description provided for @gameName.
  ///
  /// In en, this message translates to:
  /// **'Game Name'**
  String get gameName;

  /// No description provided for @storyDescription.
  ///
  /// In en, this message translates to:
  /// **'Story / Description'**
  String get storyDescription;

  /// No description provided for @finishCampaign.
  ///
  /// In en, this message translates to:
  /// **'Finish Campaign'**
  String get finishCampaign;

  /// No description provided for @finishCampaignConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to finish this campaign? This action cannot be undone!'**
  String get finishCampaignConfirm;

  /// No description provided for @yesEndGame.
  ///
  /// In en, this message translates to:
  /// **'Yes, end the game'**
  String get yesEndGame;

  /// No description provided for @gameFinishedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Game successfully finished!'**
  String get gameFinishedSuccess;

  /// No description provided for @linkedMaps.
  ///
  /// In en, this message translates to:
  /// **'Linked Maps'**
  String get linkedMaps;

  /// No description provided for @gameRecordsNotes.
  ///
  /// In en, this message translates to:
  /// **'Game records & Notes'**
  String get gameRecordsNotes;

  /// No description provided for @firstlyAddMapPool.
  ///
  /// In en, this message translates to:
  /// **'Firstly a map has to be added to map pool!'**
  String get firstlyAddMapPool;

  /// No description provided for @firstlyAddNotePool.
  ///
  /// In en, this message translates to:
  /// **'Firstly a note has to be added to note pool!'**
  String get firstlyAddNotePool;

  /// No description provided for @mapLinked.
  ///
  /// In en, this message translates to:
  /// **'Map linked!'**
  String get mapLinked;

  /// No description provided for @noMapsLinked.
  ///
  /// In en, this message translates to:
  /// **'No maps has been linked to this game.'**
  String get noMapsLinked;

  /// No description provided for @noNotesLinked.
  ///
  /// In en, this message translates to:
  /// **'No notes has been added yet to this game.'**
  String get noNotesLinked;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// No description provided for @gameDetails.
  ///
  /// In en, this message translates to:
  /// **'Game Details'**
  String get gameDetails;

  /// No description provided for @noDescriptionYet.
  ///
  /// In en, this message translates to:
  /// **'GM has not added a description yet...'**
  String get noDescriptionYet;

  /// No description provided for @playersJoinedLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} / {max} Players Joined'**
  String playersJoinedLabel(Object count, Object max);

  /// No description provided for @activeMap.
  ///
  /// In en, this message translates to:
  /// **'Active Map'**
  String get activeMap;

  /// No description provided for @namelessMap.
  ///
  /// In en, this message translates to:
  /// **'Nameless Map'**
  String get namelessMap;

  /// No description provided for @noMapYet.
  ///
  /// In en, this message translates to:
  /// **'GM has not added a map to this game yet.'**
  String get noMapYet;

  /// No description provided for @gameArchive.
  ///
  /// In en, this message translates to:
  /// **'Game Archive'**
  String get gameArchive;

  /// No description provided for @storyNotTold.
  ///
  /// In en, this message translates to:
  /// **'Story has not been told...'**
  String get storyNotTold;

  /// No description provided for @adventurers.
  ///
  /// In en, this message translates to:
  /// **'Adventurers'**
  String get adventurers;

  /// No description provided for @noPlayersJoined.
  ///
  /// In en, this message translates to:
  /// **'No players have joined this game.'**
  String get noPlayersJoined;

  /// No description provided for @unknownHero.
  ///
  /// In en, this message translates to:
  /// **'Unknown Hero'**
  String get unknownHero;

  /// No description provided for @discoveredRealms.
  ///
  /// In en, this message translates to:
  /// **'Discovered Realms'**
  String get discoveredRealms;

  /// No description provided for @noMapsAddedForGame.
  ///
  /// In en, this message translates to:
  /// **'No maps have been added for this game.'**
  String get noMapsAddedForGame;

  /// No description provided for @noNoteAddedForCampaign.
  ///
  /// In en, this message translates to:
  /// **'No note added for this campaign!'**
  String get noNoteAddedForCampaign;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description...'**
  String get noDescription;

  /// No description provided for @playersCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} Players'**
  String playersCountLabel(Object count);

  /// No description provided for @public.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get public;

  /// No description provided for @private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get private;

  /// No description provided for @noGamesCreatedYet.
  ///
  /// In en, this message translates to:
  /// **'No games have been created yet.'**
  String get noGamesCreatedYet;

  /// No description provided for @namelessNote.
  ///
  /// In en, this message translates to:
  /// **'Nameless Note'**
  String get namelessNote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
