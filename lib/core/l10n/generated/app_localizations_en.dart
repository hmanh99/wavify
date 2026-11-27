// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Wavify';

  @override
  String get navHome => 'Home';

  @override
  String get navFavourite => 'Favourite';

  @override
  String get navListen => 'Listen';

  @override
  String get navUpload => 'Upload';

  @override
  String get navProfile => 'Profile';

  @override
  String get search => 'Search';

  @override
  String get retry => 'Try again';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get loading => 'Loading...';

  @override
  String get refresh => 'Refresh';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get goBack => 'Go back';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get createNew => 'Create new';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '$count minutes ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count hours ago';
  }

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get signIn => 'Sign In';

  @override
  String get signInSubtitle => 'Welcome back to Wavify.';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signUpSubtitle => 'Create an account to continue.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get username => 'Username';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get or => 'Or';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get pleaseFillAllFields => 'Please fill in all fields';

  @override
  String get searchPlaceholder => 'Search songs, artists, albums...';

  @override
  String get recentSongs => 'Recently Played';

  @override
  String get allSongs => 'All Songs';

  @override
  String get loadSongsFailed => 'Could not load songs';

  @override
  String searchResults(int count) {
    return 'Search Results ($count)';
  }

  @override
  String allSongsWithCount(int count) {
    return 'All Songs ($count)';
  }

  @override
  String get readyToPlay => 'Ready to play';

  @override
  String get noSongsFound => 'No songs found';

  @override
  String get noSongsFoundDesc =>
      'Try searching with another title, artist or album';

  @override
  String get noSongsOnServer => 'No songs on the server yet';

  @override
  String get noSongsOnServerDesc =>
      'Be the first to upload your favorite song!';

  @override
  String get uploadNow => 'Upload music now';

  @override
  String get noSongSelected => 'No song selected';

  @override
  String get noSongSelectedDesc =>
      'Choose a song from Home or Favourite to start enjoying music.';

  @override
  String get exploreSongs => 'Explore Songs';

  @override
  String get queue => 'Queue';

  @override
  String get playingQueue => 'Playing Queue';

  @override
  String tracksCount(int count) {
    return '$count tracks';
  }

  @override
  String queueWithCount(int count) {
    return 'Queue ($count tracks)';
  }

  @override
  String get favoriteArtists => 'Favorite Artists';

  @override
  String get noArtistsYet => 'No artists yet';

  @override
  String get playlists => 'Playlists';

  @override
  String get noPlaylistsYet => 'No playlists yet';

  @override
  String get noPlaylistsYetDesc =>
      'Create a playlist to save your favorite songs';

  @override
  String get favoriteSongs => 'Songs';

  @override
  String get noFavoriteSongs => 'No songs yet';

  @override
  String get noFavoriteSongsDesc => 'Your favorite songs will appear here';

  @override
  String get createPlaylist => 'Create Playlist';

  @override
  String get editPlaylist => 'Edit Playlist';

  @override
  String get deletePlaylist => 'Delete Playlist';

  @override
  String get playlistName => 'Playlist name';

  @override
  String get playlistNameRequired => 'Playlist name *';

  @override
  String get playlistNameHint => 'Enter playlist name...';

  @override
  String get playlistNameRequiredError => 'Playlist name cannot be empty';

  @override
  String get playlistDesc => 'Description';

  @override
  String get playlistDescOptional => 'Description (optional)';

  @override
  String get playlistDescHint => 'Add a short description...';

  @override
  String get playAll => 'Play All';

  @override
  String get addSongs => 'Add Songs';

  @override
  String get emptyPlaylist => 'This playlist is empty';

  @override
  String get emptyPlaylistHint =>
      'Tap \'Add Songs\' above to choose your favorite songs.';

  @override
  String get public => 'Public';

  @override
  String get private => 'Private';

  @override
  String get publicVisibility => 'Public';

  @override
  String get privateVisibility => 'Private';

  @override
  String get playlistNotFound => 'Playlist not found';

  @override
  String get playlistEmptyToPlay => 'This playlist has no songs to play';

  @override
  String get reorderSongs => 'Reorder songs';

  @override
  String get doneReordering => 'Done reordering';

  @override
  String get reorderDragHint => 'Hold and drag songs to reorder playback.';

  @override
  String get removeFromPlaylist => 'Remove from playlist';

  @override
  String get addToPlaylist => 'Add to playlist';

  @override
  String get addSongsToPlaylist => 'Add songs to playlist';

  @override
  String get createNewPlaylist => 'Create new playlist';

  @override
  String get selectPlaylist => 'Select playlist';

  @override
  String get songAlreadyInPlaylist => 'Song is already in this playlist';

  @override
  String get tapToAddToPlaylist => 'Tap to add to playlist';

  @override
  String deletePlaylistConfirm(String name) {
    return 'Are you sure you want to delete playlist \"$name\"? This action cannot be undone.';
  }

  @override
  String selectedSongsCount(int selected, int max) {
    return 'Selected $selected/$max songs';
  }

  @override
  String get selectAll => 'Select all';

  @override
  String get deselectAll => 'Deselect all';

  @override
  String get searchInLibrary => 'Search library...';

  @override
  String get noSongsToAdd => 'No songs to add';

  @override
  String get allSongsAlreadyAdded =>
      'All songs from library have already been added to this playlist.';

  @override
  String get noMatchingSongsFound => 'No matching songs found';

  @override
  String addSelectedSongs(int count) {
    return 'Add $count songs to playlist';
  }

  @override
  String minutesSeconds(int minutes, int seconds) {
    return '$minutes min $seconds sec';
  }

  @override
  String get uploadMusic => 'Upload Music';

  @override
  String get uploadNewSong => 'Upload Song';

  @override
  String get myUploadedSongs => 'My Songs';

  @override
  String get audioFile => 'Audio File';

  @override
  String get chooseAudioFile => 'Click to choose file';

  @override
  String get coverImage => 'Cover Image';

  @override
  String get chooseCoverImage => 'Choose cover image';

  @override
  String get changeCoverImage => 'Change image';

  @override
  String get supportedAudioFormats => 'Supports MP3, WAV, AAC, FLAC (max 50MB)';

  @override
  String fileSize(String size) {
    return 'File size: $size';
  }

  @override
  String get songInfo => 'Song Information';

  @override
  String get songTitle => 'Title';

  @override
  String get artist => 'Artist';

  @override
  String get albumOptional => 'Album (optional)';

  @override
  String get visibility => 'Visibility';

  @override
  String get submitUpload => 'Upload Song';

  @override
  String get uploading => 'Uploading...';

  @override
  String uploadingWithPercent(int percent) {
    return 'Uploading... $percent%';
  }

  @override
  String get noUploadedSongs => 'No songs uploaded yet';

  @override
  String get noUploadedSongsDesc =>
      'Switch to the \'Upload Song\' tab to upload your first song.';

  @override
  String get editSong => 'Edit Song';

  @override
  String get deleteSong => 'Delete Song';

  @override
  String deleteSongConfirm(String title) {
    return 'Are you sure you want to delete song \"$title\"? This will permanently delete the file.';
  }

  @override
  String get pleaseSelectAudioFile => 'Please select an audio file';

  @override
  String get pleaseEnterSongTitle => 'Please enter song title';

  @override
  String get pleaseEnterArtist => 'Please enter artist name';

  @override
  String get myProfile => 'My Profile';

  @override
  String get editProfile => 'Edit Personal Info';

  @override
  String get editProfileSubtitle => 'Change name, email, password';

  @override
  String get playbackHistory => 'Playback History';

  @override
  String get playbackHistorySubtitle => 'See songs you have listened to';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'English';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get selectThemeMode => 'Appearance';

  @override
  String get themeModeSystem => 'System default';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get themeModeLight => 'Light';

  @override
  String get logout => 'Log Out';

  @override
  String get logoutSubtitle => 'Log out from this device';

  @override
  String get logoutConfirmTitle => 'Log Out';

  @override
  String get logoutConfirmMessage =>
      'Are you sure you want to log out from your account?';

  @override
  String get loggedOutSuccess => 'Logged out successfully';

  @override
  String get newPasswordHint => 'New password (leave blank to keep current)';

  @override
  String get usernameEmailRequired => 'Username and email cannot be empty';

  @override
  String get usernameMinLength => 'Username must be at least 4 characters';

  @override
  String get passwordMinLength => 'New password must be at least 8 characters';

  @override
  String get historyTitle => 'Playback History';

  @override
  String get emptyHistory => 'No playback history yet';

  @override
  String get emptyHistoryDesc =>
      'Songs you listen to for at least 15 seconds will be recorded here.';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get clearHistoryConfirmTitle => 'Clear playback history?';

  @override
  String get clearHistoryConfirmMessage =>
      'All your playback history will be deleted. Are you sure you want to proceed?';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get favoritePlaylists => 'Favorite Playlists';

  @override
  String get noFavoritePlaylists => 'No favorite playlists yet';

  @override
  String get noFavoritePlaylistsDesc => 'Heart any playlist to save it here';

  @override
  String get discoverPlaylists => 'Discover';

  @override
  String get discoverPublicPlaylists => 'Discover Public Playlists';

  @override
  String get searchPlaylistsHint => 'Search playlists by name...';

  @override
  String get noPublicPlaylistsFound => 'No public playlists found';

  @override
  String get addedToFavorites => 'Added to favorites';

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String get recommendedSongs => 'Recommended for you';

  @override
  String get shuffleRecommendations => 'Shuffle';

  @override
  String get seeMore => 'See more';

  @override
  String get allFavoritesTitle => 'All Favorites';

  @override
  String get searchFavoritesHint => 'Search favorite songs or playlists...';

  @override
  String get previousPage => 'Previous page';

  @override
  String get nextPage => 'Next page';

  @override
  String showingSongsRange(int start, int end, int total) {
    return '$start-$end of $total songs';
  }
}
