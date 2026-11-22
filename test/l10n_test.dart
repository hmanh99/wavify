import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavify/core/l10n/app_l10n.dart';
import 'package:wavify/core/l10n/bloc/locale_bloc.dart';

void main() {
  group('L10n & I18n Unit Tests', () {
    test('Supported locales contain both English and Vietnamese', () {
      final supportedCodes = AppLocalizations.supportedLocales.map((l) => l.languageCode).toList();
      expect(supportedCodes, containsAll(['en', 'vi']));
      expect(AppLocalizations.supportedLocales.length, 2);
    });

    test('English translations have expected values', () async {
      final l10nEn = await AppLocalizations.delegate.load(const Locale('en'));
      expect(l10nEn.appTitle, 'Wavify');
      expect(l10nEn.navHome, 'Home');
      expect(l10nEn.navFavourite, 'Favourite');
      expect(l10nEn.navListen, 'Listen');
      expect(l10nEn.navUpload, 'Upload');
      expect(l10nEn.navProfile, 'Profile');
      expect(l10nEn.search, 'Search');
      expect(l10nEn.retry, 'Try again');
      expect(l10nEn.cancel, 'Cancel');
      expect(l10nEn.confirm, 'Confirm');
      expect(l10nEn.delete, 'Delete');
      expect(l10nEn.signIn, 'Sign In');
      expect(l10nEn.signUp, 'Sign Up');
      expect(l10nEn.myProfile, 'My Profile');
      expect(l10nEn.language, 'Language');
      expect(l10nEn.tracksCount(5), '5 tracks');
    });

    test('Vietnamese translations have expected values', () async {
      final l10nVi = await AppLocalizations.delegate.load(const Locale('vi'));
      expect(l10nVi.appTitle, 'Wavify');
      expect(l10nVi.navHome, 'Trang chủ');
      expect(l10nVi.navFavourite, 'Yêu thích');
      expect(l10nVi.navListen, 'Nghe nhạc');
      expect(l10nVi.navUpload, 'Đăng tải');
      expect(l10nVi.navProfile, 'Cá nhân');
      expect(l10nVi.search, 'Tìm kiếm');
      expect(l10nVi.retry, 'Thử lại');
      expect(l10nVi.cancel, 'Hủy');
      expect(l10nVi.confirm, 'Xác nhận');
      expect(l10nVi.delete, 'Xóa');
      expect(l10nVi.signIn, 'Đăng nhập');
      expect(l10nVi.signUp, 'Đăng ký');
      expect(l10nVi.myProfile, 'Hồ sơ của tôi');
      expect(l10nVi.language, 'Ngôn ngữ');
      expect(l10nVi.tracksCount(5), '5 bài hát');
    });

    test('LocaleBloc defaults to vi and supports LocaleChangeRequested and LocaleToggleRequested', () async {
      final bloc = LocaleBloc();
      expect(bloc.state.locale, const Locale('vi'));

      bloc.add(const LocaleChangeRequested(Locale('en')));
      await pumpEventQueue();
      expect(bloc.state.locale, const Locale('en'));

      bloc.add(const LocaleToggleRequested());
      await pumpEventQueue();
      expect(bloc.state.locale, const Locale('vi'));

      bloc.add(const LocaleToggleRequested());
      await pumpEventQueue();
      expect(bloc.state.locale, const Locale('en'));

      await bloc.close();
    });
  });

  group('L10n Widget Tests', () {
    testWidgets('context.l10n provides safe fallback even without MaterialApp localizationsDelegates', (tester) async {
      late AppLocalizations resolvedL10n;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resolvedL10n = context.l10n;
              return Text(context.l10n.myProfile);
            },
          ),
        ),
      );

      expect(resolvedL10n, isNotNull);
      expect(find.text('Hồ sơ của tôi'), findsOneWidget);
    });

    testWidgets('MaterialApp with AppLocalizations delegates switches between en and vi dynamically', (tester) async {
      final localeNotifier = ValueNotifier<Locale>(const Locale('vi'));

      await tester.pumpWidget(
        ValueListenableBuilder<Locale>(
          valueListenable: localeNotifier,
          builder: (context, locale, _) {
            return MaterialApp(
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: Scaffold(
                body: Builder(
                  builder: (ctx) {
                    return Column(
                      children: [
                        Text(ctx.l10n.myProfile),
                        Text(ctx.l10n.navHome),
                        Text(ctx.l10n.uploadMusic),
                        Text(ctx.l10n.noSongSelected),
                        Text(ctx.l10n.historyTitle),
                        Text(ctx.l10n.editProfile),
                        Text(ctx.l10n.logout),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      // In Vietnamese
      expect(find.text('Hồ sơ của tôi'), findsOneWidget);
      expect(find.text('Trang chủ'), findsOneWidget);
      expect(find.text('Đăng tải bài hát'), findsOneWidget);
      expect(find.text('Chưa có bài hát nào được chọn'), findsOneWidget);
      expect(find.text('Lịch sử phát nhạc'), findsOneWidget);
      expect(find.text('Chỉnh sửa thông tin cá nhân'), findsOneWidget);
      expect(find.text('Đăng xuất'), findsOneWidget);

      // Switch to English
      localeNotifier.value = const Locale('en');
      await tester.pumpAndSettle();

      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Upload Music'), findsOneWidget);
      expect(find.text('No song selected'), findsOneWidget);
      expect(find.text('Playback History'), findsOneWidget);
      expect(find.text('Edit Personal Info'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);
    });
  });
}
