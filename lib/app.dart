import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/theme/aria_colors.dart';
import 'core/theme/aria_theme.dart';
import 'core/widgets/aria_toast.dart';
import 'features/settings/application/settings_controller.dart';
import 'l10n/app_localizations.dart';
import 'router/app_router.dart';

/// Root widget. The theme and the type scale are rebuilt when the language
/// changes, because Chinese needs its own leading and tracking.
class AriaApp extends ConsumerStatefulWidget {
  const AriaApp({super.key});

  @override
  ConsumerState<AriaApp> createState() => _AriaAppState();
}

class _AriaAppState extends ConsumerState<AriaApp> {
  late Locale _systemLocale;

  @override
  void initState() {
    super.initState();
    _systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    WidgetsBinding.instance.platformDispatcher.onLocaleChanged = () {
      if (!mounted) return;
      setState(() {
        _systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(settingsProvider);

    final override = switch (settings.locale) {
      'en' => const Locale('en'),
      'zh' => const Locale('zh'),
      _ => null,
    };
    final chinese = (override ?? _systemLocale).languageCode == 'zh';

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: ariaMessenger,
      routerConfig: router,
      locale: override,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        // The plural value already carries the widget, Material and Cupertino
        // delegates — and they all come from the decoupled packages, so the
        // `package:flutter/material.dart` types never leak in.
        ...GlobalMaterialLocalizations.delegates,
      ],
      theme: buildAriaTheme(brightness: Brightness.light, chinese: chinese),
      darkTheme: buildAriaTheme(brightness: Brightness.dark, chinese: chinese),
      themeMode: switch (settings.themeMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      builder: (context, child) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        final colors = context.ariaColors;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
              .copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: colors.ground,
                systemNavigationBarIconBrightness: dark
                    ? Brightness.light
                    : Brightness.dark,
              ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
