import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:reminiscence/features/notifications/reminder_notifications.dart';
import 'package:reminiscence/features/permissions_manager/permissions_manager.dart';
import 'package:reminiscence/ui/pages/chat/chat_page.dart';
import 'package:reminiscence/ui/pages/chat/chat_page_args.dart';
import 'package:reminiscence/ui/pages/data_viewer/data_viewer_page.dart';
import 'package:reminiscence/ui/pages/graph/graph_page.dart';
import 'package:reminiscence/ui/pages/pinned_messages/pinned_messages_page.dart';
import 'package:reminiscence/ui/pages/search/search_page.dart';
import 'package:reminiscence/ui/providers/pinned_messages_provider.dart';
import 'package:reminiscence/ui/providers/session_data.dart';
import 'package:reminiscence/ui/providers/system_messages_provider.dart';
import 'package:reminiscence/ui/theme/theme_mode_provider.dart';
import 'package:reminiscence/ui/theme/app_theme.dart';
import 'package:reminiscence/ui/pages/data_loader/data_loader_page.dart';
import 'package:reminiscence/ui/pages/loading_screen/loading_screen.dart';
import 'package:reminiscence/ui/pages/loading_screen/loading_screen_args.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /*
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  */

  await requestPermissions();

  await initializeReminderNotifications();
  await refreshReminderNotifications();

  await clearMediaCacheOnStartup();

  final prefs = await SharedPreferences.getInstance();
  final themeModeProvider = ThemeModeProvider(prefs: prefs);
  final systemMessagesProvider = SystemMessagesProvider(prefs: prefs);
  final pinnedMessagesProvider = PinnedMessagesProvider(prefs: prefs);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => themeModeProvider),
        ChangeNotifierProvider(create: (context) => systemMessagesProvider),
        ChangeNotifierProvider(create: (context) => pinnedMessagesProvider),
      ],
      child: App(),
    ),
  );
}

Future<void> clearMediaCacheOnStartup() async {
  final tempDir = await getTemporaryDirectory();

  for (final file in tempDir.listSync()) {
    try {
      if (file is File && file.path.startsWith('media_')) {
        file.deleteSync();
      }
    } catch (e) {
      // Ignore errors
    }
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModeProvider = Provider.of<ThemeModeProvider>(context);

    return ChangeNotifierProvider(
      create: (context) => SessionData(),
      child: MaterialApp(
        title: "Reminiscence",
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeModeProvider.themeMode,
        initialRoute: "/",
        onGenerateRoute: onGenerateRoute,
      ),
    );
  }

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == '/') {
      return MaterialPageRoute(
        settings: settings,
        builder: (context) {
          return DataLoaderPage();
        },
      );
    }

    if (settings.name == "/loading") {
      final args = settings.arguments as LoadingScreenArgs;

      return MaterialPageRoute(
        settings: settings,
        builder:
            (_) => LoadingScreen(
              operation: args.operation,
              operationParams: args.operationParams,
              showProgress: args.showProgress,
              tooltip: args.tooltip,
            ),
      );
    }

    if (settings.name == "/viewer") {
      return MaterialPageRoute(
        settings: settings,
        builder: (context) {
          return DataViewerPage();
        },
      );
    }

    if (settings.name == "/chat") {
      final args =
          settings.arguments == null
              ? ChatPageArgs()
              : settings.arguments as ChatPageArgs;

      return MaterialPageRoute(
        settings: settings,
        builder: (context) {
          return ChatPage(
            initialMessageId: args.initialMessageId,
            disabled: args.disabled,
          );
        },
      );
    }

    if (settings.name == "/pins") {
      return MaterialPageRoute(
        settings: settings,
        builder: (context) {
          return PinnedMessagesPage();
        },
      );
    }

    if (settings.name == "/graph") {
      return MaterialPageRoute(
        settings: settings,
        builder: (context) {
          return GraphPage();
        },
      );
    }

    if (settings.name == "/search") {
      return MaterialPageRoute(
        settings: settings,
        builder: (context) {
          return SearchPage();
        },
      );
    }

    return null;
  }
}
