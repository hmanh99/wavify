import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('vi'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Wavify'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navFavourite.
  ///
  /// In en, this message translates to:
  /// **'Favourite'**
  String get navFavourite;

  /// No description provided for @navListen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get navListen;

  /// No description provided for @navUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get navUpload;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @createNew.
  ///
  /// In en, this message translates to:
  /// **'Create new'**
  String get createNew;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back to Wavify.'**
  String get signInSubtitle;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account to continue.'**
  String get signUpSubtitle;

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

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search songs, artists, albums...'**
  String get searchPlaceholder;

  /// No description provided for @recentSongs.
  ///
  /// In en, this message translates to:
  /// **'Recently Played'**
  String get recentSongs;

  /// No description provided for @allSongs.
  ///
  /// In en, this message translates to:
  /// **'All Songs'**
  String get allSongs;

  /// No description provided for @loadSongsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load songs'**
  String get loadSongsFailed;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results ({count})'**
  String searchResults(int count);

  /// No description provided for @allSongsWithCount.
  ///
  /// In en, this message translates to:
  /// **'All Songs ({count})'**
  String allSongsWithCount(int count);

  /// No description provided for @readyToPlay.
  ///
  /// In en, this message translates to:
  /// **'Ready to play'**
  String get readyToPlay;

  /// No description provided for @noSongsFound.
  ///
  /// In en, this message translates to:
  /// **'No songs found'**
  String get noSongsFound;

  /// No description provided for @noSongsFoundDesc.
  ///
  /// In en, this message translates to:
  /// **'Try searching with another title, artist or album'**
  String get noSongsFoundDesc;

  /// No description provided for @noSongsOnServer.
  ///
  /// In en, this message translates to:
  /// **'No songs on the server yet'**
  String get noSongsOnServer;

  /// No description provided for @noSongsOnServerDesc.
  ///
  /// In en, this message translates to:
  /// **'Be the first to upload your favorite song!'**
  String get noSongsOnServerDesc;

  /// No description provided for @uploadNow.
  ///
  /// In en, this message translates to:
  /// **'Upload music now'**
  String get uploadNow;

  /// No description provided for @noSongSelected.
  ///
  /// In en, this message translates to:
  /// **'No song selected'**
  String get noSongSelected;

  /// No description provided for @noSongSelectedDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose a song from Home or Favourite to start enjoying music.'**
  String get noSongSelectedDesc;

  /// No description provided for @exploreSongs.
  ///
  /// In en, this message translates to:
  /// **'Explore Songs'**
  String get exploreSongs;

  /// No description provided for @queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queue;

  /// No description provided for @playingQueue.
  ///
  /// In en, this message translates to:
  /// **'Playing Queue'**
  String get playingQueue;

  /// No description provided for @tracksCount.
  ///
  /// In en, this message translates to:
  /// **'{count} tracks'**
  String tracksCount(int count);

  /// No description provided for @queueWithCount.
  ///
  /// In en, this message translates to:
  /// **'Queue ({count} tracks)'**
  String queueWithCount(int count);

  /// No description provided for @favoriteArtists.
  ///
  /// In en, this message translates to:
  /// **'Favorite Artists'**
  String get favoriteArtists;

  /// No description provided for @noArtistsYet.
  ///
  /// In en, this message translates to:
  /// **'No artists yet'**
  String get noArtistsYet;

  /// No description provided for @playlists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlists;

  /// No description provided for @noPlaylistsYet.
  ///
  /// In en, this message translates to:
  /// **'No playlists yet'**
  String get noPlaylistsYet;

  /// No description provided for @noPlaylistsYetDesc.
  ///
  /// In en, this message translates to:
  /// **'Create a playlist to save your favorite songs'**
  String get noPlaylistsYetDesc;

  /// No description provided for @favoriteSongs.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get favoriteSongs;

  /// No description provided for @noFavoriteSongs.
  ///
  /// In en, this message translates to:
  /// **'No songs yet'**
  String get noFavoriteSongs;

  /// No description provided for @noFavoriteSongsDesc.
  ///
  /// In en, this message translates to:
  /// **'Your favorite songs will appear here'**
  String get noFavoriteSongsDesc;

  /// No description provided for @createPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Create Playlist'**
  String get createPlaylist;

  /// No description provided for @editPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Edit Playlist'**
  String get editPlaylist;

  /// No description provided for @deletePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Delete Playlist'**
  String get deletePlaylist;

  /// No description provided for @playlistName.
  ///
  /// In en, this message translates to:
  /// **'Playlist name'**
  String get playlistName;

  /// No description provided for @playlistNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Playlist name *'**
  String get playlistNameRequired;

  /// No description provided for @playlistNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter playlist name...'**
  String get playlistNameHint;

  /// No description provided for @playlistNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Playlist name cannot be empty'**
  String get playlistNameRequiredError;

  /// No description provided for @playlistDesc.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get playlistDesc;

  /// No description provided for @playlistDescOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get playlistDescOptional;

  /// No description provided for @playlistDescHint.
  ///
  /// In en, this message translates to:
  /// **'Add a short description...'**
  String get playlistDescHint;

  /// No description provided for @playAll.
  ///
  /// In en, this message translates to:
  /// **'Play All'**
  String get playAll;

  /// No description provided for @addSongs.
  ///
  /// In en, this message translates to:
  /// **'Add Songs'**
  String get addSongs;

  /// No description provided for @emptyPlaylist.
  ///
  /// In en, this message translates to:
  /// **'This playlist is empty'**
  String get emptyPlaylist;

  /// No description provided for @emptyPlaylistHint.
  ///
  /// In en, this message translates to:
  /// **'Tap \'Add Songs\' above to choose your favorite songs.'**
  String get emptyPlaylistHint;

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

  /// No description provided for @publicVisibility.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get publicVisibility;

  /// No description provided for @privateVisibility.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get privateVisibility;

  /// No description provided for @playlistNotFound.
  ///
  /// In en, this message translates to:
  /// **'Playlist not found'**
  String get playlistNotFound;

  /// No description provided for @playlistEmptyToPlay.
  ///
  /// In en, this message translates to:
  /// **'This playlist has no songs to play'**
  String get playlistEmptyToPlay;

  /// No description provided for @reorderSongs.
  ///
  /// In en, this message translates to:
  /// **'Reorder songs'**
  String get reorderSongs;

  /// No description provided for @doneReordering.
  ///
  /// In en, this message translates to:
  /// **'Done reordering'**
  String get doneReordering;

  /// No description provided for @reorderDragHint.
  ///
  /// In en, this message translates to:
  /// **'Hold and drag songs to reorder playback.'**
  String get reorderDragHint;

  /// No description provided for @removeFromPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Remove from playlist'**
  String get removeFromPlaylist;

  /// No description provided for @addToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to playlist'**
  String get addToPlaylist;

  /// No description provided for @addSongsToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add songs to playlist'**
  String get addSongsToPlaylist;

  /// No description provided for @createNewPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Create new playlist'**
  String get createNewPlaylist;

  /// No description provided for @selectPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Select playlist'**
  String get selectPlaylist;

  /// No description provided for @songAlreadyInPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Song is already in this playlist'**
  String get songAlreadyInPlaylist;

  /// No description provided for @tapToAddToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Tap to add to playlist'**
  String get tapToAddToPlaylist;

  /// No description provided for @deletePlaylistConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete playlist \"{name}\"? This action cannot be undone.'**
  String deletePlaylistConfirm(String name);

  /// No description provided for @selectedSongsCount.
  ///
  /// In en, this message translates to:
  /// **'Selected {selected}/{max} songs'**
  String selectedSongsCount(int selected, int max);

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get deselectAll;

  /// No description provided for @searchInLibrary.
  ///
  /// In en, this message translates to:
  /// **'Search library...'**
  String get searchInLibrary;

  /// No description provided for @noSongsToAdd.
  ///
  /// In en, this message translates to:
  /// **'No songs to add'**
  String get noSongsToAdd;

  /// No description provided for @allSongsAlreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'All songs from library have already been added to this playlist.'**
  String get allSongsAlreadyAdded;

  /// No description provided for @noMatchingSongsFound.
  ///
  /// In en, this message translates to:
  /// **'No matching songs found'**
  String get noMatchingSongsFound;

  /// No description provided for @addSelectedSongs.
  ///
  /// In en, this message translates to:
  /// **'Add {count} songs to playlist'**
  String addSelectedSongs(int count);

  /// No description provided for @minutesSeconds.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min {seconds} sec'**
  String minutesSeconds(int minutes, int seconds);

  /// No description provided for @uploadMusic.
  ///
  /// In en, this message translates to:
  /// **'Upload Music'**
  String get uploadMusic;

  /// No description provided for @uploadNewSong.
  ///
  /// In en, this message translates to:
  /// **'Upload Song'**
  String get uploadNewSong;

  /// No description provided for @myUploadedSongs.
  ///
  /// In en, this message translates to:
  /// **'My Songs'**
  String get myUploadedSongs;

  /// No description provided for @audioFile.
  ///
  /// In en, this message translates to:
  /// **'Audio File'**
  String get audioFile;

  /// No description provided for @chooseAudioFile.
  ///
  /// In en, this message translates to:
  /// **'Click to choose file'**
  String get chooseAudioFile;

  /// No description provided for @coverImage.
  ///
  /// In en, this message translates to:
  /// **'Cover Image'**
  String get coverImage;

  /// No description provided for @chooseCoverImage.
  ///
  /// In en, this message translates to:
  /// **'Choose cover image'**
  String get chooseCoverImage;

  /// No description provided for @changeCoverImage.
  ///
  /// In en, this message translates to:
  /// **'Change image'**
  String get changeCoverImage;

  /// No description provided for @supportedAudioFormats.
  ///
  /// In en, this message translates to:
  /// **'Supports MP3, WAV, AAC, FLAC (max 50MB)'**
  String get supportedAudioFormats;

  /// No description provided for @fileSize.
  ///
  /// In en, this message translates to:
  /// **'File size: {size}'**
  String fileSize(String size);

  /// No description provided for @songInfo.
  ///
  /// In en, this message translates to:
  /// **'Song Information'**
  String get songInfo;

  /// No description provided for @songTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get songTitle;

  /// No description provided for @artist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get artist;

  /// No description provided for @albumOptional.
  ///
  /// In en, this message translates to:
  /// **'Album (optional)'**
  String get albumOptional;

  /// No description provided for @visibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get visibility;

  /// No description provided for @submitUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload Song'**
  String get submitUpload;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @uploadingWithPercent.
  ///
  /// In en, this message translates to:
  /// **'Uploading... {percent}%'**
  String uploadingWithPercent(int percent);

  /// No description provided for @noUploadedSongs.
  ///
  /// In en, this message translates to:
  /// **'No songs uploaded yet'**
  String get noUploadedSongs;

  /// No description provided for @noUploadedSongsDesc.
  ///
  /// In en, this message translates to:
  /// **'Switch to the \'Upload Song\' tab to upload your first song.'**
  String get noUploadedSongsDesc;

  /// No description provided for @editSong.
  ///
  /// In en, this message translates to:
  /// **'Edit Song'**
  String get editSong;

  /// No description provided for @deleteSong.
  ///
  /// In en, this message translates to:
  /// **'Delete Song'**
  String get deleteSong;

  /// No description provided for @deleteSongConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete song \"{title}\"? This will permanently delete the file.'**
  String deleteSongConfirm(String title);

  /// No description provided for @pleaseSelectAudioFile.
  ///
  /// In en, this message translates to:
  /// **'Please select an audio file'**
  String get pleaseSelectAudioFile;

  /// No description provided for @pleaseEnterSongTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter song title'**
  String get pleaseEnterSongTitle;

  /// No description provided for @pleaseEnterArtist.
  ///
  /// In en, this message translates to:
  /// **'Please enter artist name'**
  String get pleaseEnterArtist;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Personal Info'**
  String get editProfile;

  /// No description provided for @editProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change name, email, password'**
  String get editProfileSubtitle;

  /// No description provided for @playbackHistory.
  ///
  /// In en, this message translates to:
  /// **'Playback History'**
  String get playbackHistory;

  /// No description provided for @playbackHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'See songs you have listened to'**
  String get playbackHistorySubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageSubtitle;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @logoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log out from this device'**
  String get logoutSubtitle;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out from your account?'**
  String get logoutConfirmMessage;

  /// No description provided for @loggedOutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get loggedOutSuccess;

  /// No description provided for @newPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'New password (leave blank to keep current)'**
  String get newPasswordHint;

  /// No description provided for @usernameEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Username and email cannot be empty'**
  String get usernameEmailRequired;

  /// No description provided for @usernameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 4 characters'**
  String get usernameMinLength;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'New password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Playback History'**
  String get historyTitle;

  /// No description provided for @emptyHistory.
  ///
  /// In en, this message translates to:
  /// **'No playback history yet'**
  String get emptyHistory;

  /// No description provided for @emptyHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Songs you listen to for at least 15 seconds will be recorded here.'**
  String get emptyHistoryDesc;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @clearHistoryConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear playback history?'**
  String get clearHistoryConfirmTitle;

  /// No description provided for @clearHistoryConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'All your playback history will be deleted. Are you sure you want to proceed?'**
  String get clearHistoryConfirmMessage;
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
