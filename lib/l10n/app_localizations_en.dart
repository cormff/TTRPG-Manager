// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TTRPG Manager';

  @override
  String get gameMaster => 'Game Master';

  @override
  String get player => 'Player';

  @override
  String get myGames => 'My Games';

  @override
  String get createGame => 'Create Game';

  @override
  String get myMaps => 'My Maps';

  @override
  String get npcs => 'NPC\'s';

  @override
  String get notes => 'Notes';

  @override
  String get ruleBooks => 'Rule Books';

  @override
  String get changeToPlayerView => 'Change to Player View';

  @override
  String get changeToGMView => 'Change to GM View';

  @override
  String get joinGame => 'Join Game';

  @override
  String get characters => 'Characters';

  @override
  String get logout => 'Logout';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get username => 'Username';

  @override
  String get welcome => 'Welcome';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match!';

  @override
  String get pleaseFillAllFields => 'Please fill all fields';

  @override
  String get alreadyRegisteredLogin => 'Already registered? Log in';

  @override
  String get dontHaveAccountRegister => 'Don\'t have an account? Register';

  @override
  String get selectRole => 'Select Role';

  @override
  String get invalidEmailPassword => 'Invalid email or password!';

  @override
  String get gmShort => 'GM';

  @override
  String get races => 'Races';

  @override
  String get racesSubtitle => 'Explore the diverse peoples of the world';

  @override
  String get classes => 'Classes';

  @override
  String get classesSubtitle => 'Choose your path and abilities';

  @override
  String get equipment => 'Equipment';

  @override
  String get equipmentSubtitle => 'Weapons, armor, tools, and adventuring gear';

  @override
  String get monsters => 'Monsters';

  @override
  String get monstersSubtitle =>
      'Creatures, stats, legendary actions, and beasts';

  @override
  String get spells => 'Spells';

  @override
  String get spellsSubtitle => 'Master the arcane and divine arts';

  @override
  String get games => 'Games';

  @override
  String get maps => 'Maps';

  @override
  String get players => 'Players';

  @override
  String get noMapsAdded => 'No maps has been added yet.';

  @override
  String get noNotesAdded => 'No notes has been added yet.';

  @override
  String get seeAllNotes => 'See all notes';

  @override
  String get noGamesJoined => 'You have not joined any games yet.';

  @override
  String get noCharactersCreated => 'No characters have been created yet.';

  @override
  String get myJoinedGames => 'My Joined Games';

  @override
  String get noAdventureNotes => 'No adventure notes yet.';

  @override
  String get tapToRecord => 'Tap + to record your journey!';

  @override
  String get newNote => 'New Note';

  @override
  String get editNote => 'Edit Note';

  @override
  String get newGMEntry => 'New GM Entry';

  @override
  String get newPlayerLog => 'New Player Log';

  @override
  String get deleteNote => 'Delete Note?';

  @override
  String get areYouSureDeleteNote =>
      'Are you sure you want to delete this note?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get back => 'Back';

  @override
  String get edit => 'Edit';

  @override
  String get title => 'Title';

  @override
  String get details => 'Details';

  @override
  String get category => 'Category';

  @override
  String get subCategoryOptional => 'Sub-Category (Optional)';

  @override
  String get titleExample => 'e.g. The Mysterious Stranger';

  @override
  String get writeWhatHappened => 'Write down what happened...';

  @override
  String get gmNotes => 'GM Notes';

  @override
  String get playerNotes => 'Player Notes';

  @override
  String get npc => 'NPC';

  @override
  String get quest => 'Quest';

  @override
  String get loot => 'Loot';

  @override
  String get location => 'Location';

  @override
  String get combat => 'Combat';

  @override
  String get other => 'Other';

  @override
  String get mapPool => 'Map Pool';

  @override
  String get addNewMap => 'Add New Map';

  @override
  String get mapName => 'Map Name';

  @override
  String get pickFromGallery => 'Pick from gallery';

  @override
  String get enterUrl => 'Enter URL';

  @override
  String get imageUrl => 'Image URL';

  @override
  String get openGallery => 'Open gallery';

  @override
  String get addMapToPool => 'Add map to pool';

  @override
  String get mapAddedSuccess => 'Map successfully added to database!';

  @override
  String get errorOccurred => 'An error occurred!';

  @override
  String get myCharacters => 'My Characters';

  @override
  String get addNpc => 'Add NPC';

  @override
  String get addCharacter => 'Add Character';

  @override
  String get characterImageOptional => 'Character Image (Optional)';

  @override
  String get nameWithAsterisk => 'Name *';

  @override
  String get nameExample => 'e.g. Gandalf, Aragorn';

  @override
  String get raceWithAsterisk => 'Race *';

  @override
  String get classWithAsterisk => 'Class *';

  @override
  String levelLabel(Object level) {
    return 'Level: $level';
  }

  @override
  String get background => 'Background';

  @override
  String get alignment => 'Alignment';

  @override
  String get gameOptional => 'Game (Optional)';

  @override
  String get noGameLink => 'No game link';

  @override
  String get abilityScores => 'Ability Scores';

  @override
  String get abilityScoresNote =>
      'Standard: 10 | Modifier calculated automatically';

  @override
  String get combatStats => 'Combat Stats';

  @override
  String speedLabel(Object speed) {
    return 'Speed: $speed ft';
  }

  @override
  String get backstory => 'Backstory';

  @override
  String get backstoryHint => 'Character\'s past, motivation...';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get nameRaceClassRequired =>
      'Name, Race, and Class are required fields.';

  @override
  String get npcAdded => 'NPC added!';

  @override
  String get characterAdded => 'Character added!';

  @override
  String get errorDuringSave => 'An error occurred during save.';

  @override
  String get noNpcAddedYet => 'No NPCs added yet.';

  @override
  String get noCharactersAddedYet => 'No characters added yet.';

  @override
  String get tapPlusToCreate => 'Tap + button to create one!';

  @override
  String get close => 'Close';

  @override
  String get race => 'Race';

  @override
  String get charClass => 'Class';

  @override
  String get level => 'Level';

  @override
  String get createNewCampaign => 'Create New Campaign';

  @override
  String get campaignTitle => 'Campaign Title';

  @override
  String get description => 'Description';

  @override
  String get maxPlayersLabel => 'Max Players:';

  @override
  String get publicGame => 'Public Game';

  @override
  String get visibleToEveryone => 'Visible to everyone in search results';

  @override
  String get createCampaign => 'Create Campaign';

  @override
  String get gameCreatedSuccess => 'Game Successfully Created!';

  @override
  String get findGames => 'Find Games';

  @override
  String get joinPrivateGame => 'Join to a Private Game';

  @override
  String get inviteCodeHint => 'Ex: A7X9BQ';

  @override
  String get join => 'Join';

  @override
  String get publicGames => 'Public Games';

  @override
  String get noPublicGames => 'No public games have been created yet.';

  @override
  String get yourGame => 'Your Game';

  @override
  String get alreadyJoined => 'Already Joined';

  @override
  String get worldIsFull => 'World is full';

  @override
  String get joinedSuccess => 'You have successfully joined the game!';

  @override
  String get editGame => 'Edit Game';

  @override
  String get gameUpdatedSuccess => 'Game successfully updated!';

  @override
  String get updateFailed => 'Update failed. Try again later.';

  @override
  String get invitationCode => 'Game invitation code';

  @override
  String invitationCodeCopied(Object code) {
    return 'Invitation code copied: $code';
  }

  @override
  String get copyCode => 'Copy code';

  @override
  String get gameName => 'Game Name';

  @override
  String get storyDescription => 'Story / Description';

  @override
  String get finishCampaign => 'Finish Campaign';

  @override
  String get finishCampaignConfirm =>
      'Are you sure you want to finish this campaign? This action cannot be undone!';

  @override
  String get yesEndGame => 'Yes, end the game';

  @override
  String get gameFinishedSuccess => 'Game successfully finished!';

  @override
  String get linkedMaps => 'Linked Maps';

  @override
  String get gameRecordsNotes => 'Game records & Notes';

  @override
  String get firstlyAddMapPool => 'Firstly a map has to be added to map pool!';

  @override
  String get firstlyAddNotePool =>
      'Firstly a note has to be added to note pool!';

  @override
  String get mapLinked => 'Map linked!';

  @override
  String get noMapsLinked => 'No maps has been linked to this game.';

  @override
  String get noNotesLinked => 'No notes has been added yet to this game.';

  @override
  String get added => 'Added';

  @override
  String get gameDetails => 'Game Details';

  @override
  String get noDescriptionYet => 'GM has not added a description yet...';

  @override
  String playersJoinedLabel(Object count, Object max) {
    return '$count / $max Players Joined';
  }

  @override
  String get activeMap => 'Active Map';

  @override
  String get namelessMap => 'Nameless Map';

  @override
  String get noMapYet => 'GM has not added a map to this game yet.';

  @override
  String get gameArchive => 'Game Archive';

  @override
  String get storyNotTold => 'Story has not been told...';

  @override
  String get adventurers => 'Adventurers';

  @override
  String get noPlayersJoined => 'No players have joined this game.';

  @override
  String get unknownHero => 'Unknown Hero';

  @override
  String get discoveredRealms => 'Discovered Realms';

  @override
  String get noMapsAddedForGame => 'No maps have been added for this game.';

  @override
  String get noNoteAddedForCampaign => 'No note added for this campaign!';

  @override
  String get noDescription => 'No description...';

  @override
  String playersCountLabel(Object count) {
    return '$count Players';
  }

  @override
  String get public => 'Public';

  @override
  String get private => 'Private';

  @override
  String get noGamesCreatedYet => 'No games have been created yet.';

  @override
  String get namelessNote => 'Nameless Note';
}
