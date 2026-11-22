import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';
import 'generated/app_localizations_vi.dart';

export 'generated/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  /// Convenient accessor for localized strings.
  /// If context has no localizations provider (e.g. In widget tests without delegates),
  /// It falls back safely to AppLocalizationsVi so tests and widgets never throw null errors.
  AppLocalizations get l10n {
    return AppLocalizations.of(this) ?? AppLocalizationsVi();
  }
}
