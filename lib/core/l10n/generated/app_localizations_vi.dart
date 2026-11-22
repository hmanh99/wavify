// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Wavify';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navFavourite => 'Yêu thích';

  @override
  String get navListen => 'Nghe nhạc';

  @override
  String get navUpload => 'Đăng tải';

  @override
  String get navProfile => 'Cá nhân';

  @override
  String get search => 'Tìm kiếm';

  @override
  String get retry => 'Thử lại';

  @override
  String get cancel => 'Hủy';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get delete => 'Xóa';

  @override
  String get save => 'Lưu';

  @override
  String get success => 'Thành công';

  @override
  String get error => 'Lỗi';

  @override
  String get loading => 'Đang tải...';

  @override
  String get refresh => 'Làm mới';

  @override
  String get selectLanguage => 'Chọn ngôn ngữ';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get errorOccurred => 'Có lỗi xảy ra';

  @override
  String get goBack => 'Quay lại';

  @override
  String get saveChanges => 'Lưu thay đổi';

  @override
  String get createNew => 'Tạo mới';

  @override
  String get justNow => 'Vừa xong';

  @override
  String minutesAgo(int count) {
    return '$count phút trước';
  }

  @override
  String hoursAgo(int count) {
    return '$count giờ trước';
  }

  @override
  String daysAgo(int count) {
    return '$count ngày trước';
  }

  @override
  String get signIn => 'Đăng nhập';

  @override
  String get signInSubtitle => 'Chào mừng trở lại với Wavify.';

  @override
  String get signUp => 'Đăng ký';

  @override
  String get signUpSubtitle => 'Tạo tài khoản để tiếp tục trải nghiệm âm nhạc.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get username => 'Tên người dùng';

  @override
  String get forgotPassword => 'Quên mật khẩu?';

  @override
  String get or => 'Hoặc';

  @override
  String get noAccount => 'Chưa có tài khoản?';

  @override
  String get haveAccount => 'Đã có tài khoản?';

  @override
  String get pleaseFillAllFields => 'Vui lòng nhập đầy đủ thông tin';

  @override
  String get searchPlaceholder => 'Tìm kiếm bài hát...';

  @override
  String get recentSongs => 'Vừa phát gần đây';

  @override
  String get allSongs => 'Tất cả bài hát';

  @override
  String get loadSongsFailed => 'Không thể tải bài hát';

  @override
  String searchResults(int count) {
    return 'Kết quả tìm kiếm ($count)';
  }

  @override
  String allSongsWithCount(int count) {
    return 'Tất cả bài hát ($count)';
  }

  @override
  String get readyToPlay => 'Sẵn sàng phát';

  @override
  String get noSongsFound => 'Không tìm thấy bài hát nào';

  @override
  String get noSongsFoundDesc =>
      'Thử tìm kiếm với tiêu đề, nghệ sĩ hoặc album khác';

  @override
  String get noSongsOnServer => 'Chưa có bài hát nào trên máy chủ';

  @override
  String get noSongsOnServerDesc =>
      'Hãy là người đầu tiên tải lên bài hát yêu thích của bạn!';

  @override
  String get uploadNow => 'Tải nhạc lên ngay';

  @override
  String get noSongSelected => 'Chưa có bài hát nào được chọn';

  @override
  String get noSongSelectedDesc =>
      'Hãy chọn một bài hát từ Trang chủ hoặc Yêu thích để bắt đầu thưởng thức âm nhạc.';

  @override
  String get exploreSongs => 'Khám phá bài hát';

  @override
  String get queue => 'Danh sách chờ';

  @override
  String get playingQueue => 'Playing Queue';

  @override
  String tracksCount(int count) {
    return '$count bài hát';
  }

  @override
  String queueWithCount(int count) {
    return 'Queue ($count tracks)';
  }

  @override
  String get favoriteArtists => 'Favorite Artists';

  @override
  String get noArtistsYet => 'Chưa có nghệ sĩ nào';

  @override
  String get playlists => 'Playlists';

  @override
  String get noPlaylistsYet => 'Chưa có playlist nào';

  @override
  String get noPlaylistsYetDesc => 'Tạo playlist để lưu các bài hát yêu thích';

  @override
  String get favoriteSongs => 'Songs';

  @override
  String get noFavoriteSongs => 'Chưa có bài hát nào';

  @override
  String get noFavoriteSongsDesc =>
      'Các bài hát bạn yêu thích sẽ xuất hiện ở đây';

  @override
  String get createPlaylist => 'Tạo Playlist mới';

  @override
  String get editPlaylist => 'Sửa Playlist';

  @override
  String get deletePlaylist => 'Xóa playlist';

  @override
  String get playlistName => 'Tên playlist';

  @override
  String get playlistNameRequired => 'Tên playlist *';

  @override
  String get playlistNameHint => 'Nhập tên playlist...';

  @override
  String get playlistNameRequiredError => 'Tên playlist không được để trống';

  @override
  String get playlistDesc => 'Mô tả';

  @override
  String get playlistDescOptional => 'Mô tả (tùy chọn)';

  @override
  String get playlistDescHint => 'Thêm vài dòng mô tả...';

  @override
  String get playAll => 'Phát tất cả';

  @override
  String get addSongs => 'Thêm bài';

  @override
  String get emptyPlaylist => 'Playlist này chưa có bài hát nào';

  @override
  String get emptyPlaylistHint =>
      'Nhấn \"Thêm bài\" ở trên để chọn các bài hát yêu thích của bạn.';

  @override
  String get public => 'Public';

  @override
  String get private => 'Private';

  @override
  String get publicVisibility => 'Công khai (Public)';

  @override
  String get privateVisibility => 'Riêng tư (Private)';

  @override
  String get playlistNotFound => 'Không tìm thấy playlist';

  @override
  String get playlistEmptyToPlay => 'Playlist chưa có bài hát nào để phát';

  @override
  String get reorderSongs => 'Sắp xếp bài hát';

  @override
  String get doneReordering => 'Hoàn tất sắp xếp';

  @override
  String get reorderDragHint =>
      'Giữ và kéo bài hát để sắp xếp lại thứ tự phát.';

  @override
  String get removeFromPlaylist => 'Xóa khỏi playlist';

  @override
  String get addToPlaylist => 'Thêm vào playlist';

  @override
  String get addSongsToPlaylist => 'Thêm bài hát vào playlist';

  @override
  String get createNewPlaylist => 'Tạo playlist mới';

  @override
  String get selectPlaylist => 'Chọn playlist';

  @override
  String get songAlreadyInPlaylist => 'Playlist này đã có bài hát này';

  @override
  String get tapToAddToPlaylist => 'Nhấn để thêm vào playlist';

  @override
  String deletePlaylistConfirm(String name) {
    return 'Bạn có chắc chắn muốn xóa playlist \"$name\" không? Thao tác này không thể hoàn tác.';
  }

  @override
  String selectedSongsCount(int selected, int max) {
    return 'Đã chọn $selected/$max bài hát';
  }

  @override
  String get selectAll => 'Chọn tất cả';

  @override
  String get deselectAll => 'Bỏ chọn';

  @override
  String get searchInLibrary => 'Tìm kiếm trong thư viện...';

  @override
  String get noSongsToAdd => 'Không có bài hát nào để thêm';

  @override
  String get allSongsAlreadyAdded =>
      'Đã thêm toàn bộ bài hát trong thư viện vào playlist này.';

  @override
  String get noMatchingSongsFound => 'Không tìm thấy bài hát phù hợp';

  @override
  String addSelectedSongs(int count) {
    return 'Thêm $count bài hát vào playlist';
  }

  @override
  String minutesSeconds(int minutes, int seconds) {
    return '$minutes phút $seconds giây';
  }

  @override
  String get uploadMusic => 'Đăng tải bài hát';

  @override
  String get uploadNewSong => 'Tải bài hát';

  @override
  String get myUploadedSongs => 'Bài hát của tôi';

  @override
  String get audioFile => 'Audio File';

  @override
  String get chooseAudioFile => 'Nhấn để chọn file';

  @override
  String get coverImage => 'Ảnh bìa';

  @override
  String get chooseCoverImage => 'Chọn ảnh bìa';

  @override
  String get changeCoverImage => 'Đổi ảnh';

  @override
  String get supportedAudioFormats =>
      'Hỗ trợ MP3, WAV, AAC, FLAC (tối đa 50MB)';

  @override
  String fileSize(String size) {
    return 'Kích thước file: $size';
  }

  @override
  String get songInfo => 'Thông tin bài hát';

  @override
  String get songTitle => 'Tiêu đề';

  @override
  String get artist => 'Nghệ sĩ';

  @override
  String get albumOptional => 'Album (không bắt buộc)';

  @override
  String get visibility => 'Hiển thị';

  @override
  String get submitUpload => 'Đăng bài hát';

  @override
  String get uploading => 'Uploading to server...';

  @override
  String uploadingWithPercent(int percent) {
    return 'Uploading... $percent%';
  }

  @override
  String get noUploadedSongs => 'Chưa có bài hát nào được tải lên';

  @override
  String get noUploadedSongsDesc =>
      'Hãy chuyển qua tab \"Tải bài hát\" để tải lên bài hát đầu tiên của bạn.';

  @override
  String get editSong => 'Sửa thông tin bài hát';

  @override
  String get deleteSong => 'Xóa bài hát';

  @override
  String deleteSongConfirm(String title) {
    return 'Bạn có chắc chắn muốn xóa bài hát \"$title\" không? Thao tác này sẽ xóa tệp vĩnh viễn khỏi hệ thống.';
  }

  @override
  String get pleaseSelectAudioFile => 'Vui lòng chọn file âm thanh';

  @override
  String get pleaseEnterSongTitle => 'Vui lòng nhập tiêu đề bài hát';

  @override
  String get pleaseEnterArtist => 'Vui lòng nhập tên nghệ sĩ';

  @override
  String get myProfile => 'Hồ sơ của tôi';

  @override
  String get editProfile => 'Chỉnh sửa thông tin cá nhân';

  @override
  String get editProfileSubtitle => 'Thay đổi tên, email, mật khẩu';

  @override
  String get playbackHistory => 'Lịch sử phát nhạc';

  @override
  String get playbackHistorySubtitle => 'Xem lại các bài hát bạn đã nghe';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageSubtitle => 'Tiếng Việt';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get logoutSubtitle => 'Đăng xuất khỏi thiết bị này';

  @override
  String get logoutConfirmTitle => 'Đăng xuất';

  @override
  String get logoutConfirmMessage =>
      'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản của mình không?';

  @override
  String get loggedOutSuccess => 'Đã đăng xuất thành công';

  @override
  String get newPasswordHint => 'Mật khẩu mới (bỏ trống nếu không đổi)';

  @override
  String get usernameEmailRequired =>
      'Tên người dùng và email không được để trống';

  @override
  String get usernameMinLength => 'Tên người dùng phải có tối thiểu 4 ký tự';

  @override
  String get passwordMinLength => 'Mật khẩu mới phải có ít nhất 8 ký tự';

  @override
  String get historyTitle => 'Lịch sử phát nhạc';

  @override
  String get emptyHistory => 'Chưa có lịch sử phát nhạc';

  @override
  String get emptyHistoryDesc =>
      'Các bài hát bạn nghe tối thiểu 15 giây sẽ tự động được ghi nhận tại đây.';

  @override
  String get clearHistory => 'Xóa lịch sử';

  @override
  String get clearHistoryConfirmTitle => 'Xóa lịch sử phát nhạc?';

  @override
  String get clearHistoryConfirmMessage =>
      'Toàn bộ lịch sử nghe nhạc của bạn sẽ bị xóa. Bạn có chắc chắn muốn tiếp tục?';
}
