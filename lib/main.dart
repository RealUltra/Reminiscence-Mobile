import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:reminiscence/features/permissions_manager/permissions_manager.dart';
import 'package:reminiscence/ui/pages/chat/chat_page.dart';
import 'package:reminiscence/ui/pages/chat/chat_page_args.dart';
import 'package:reminiscence/ui/pages/graph/graph_page.dart';
import 'package:reminiscence/ui/pages/pinned_messages/pinned_messages_page.dart';
import 'package:reminiscence/ui/pages/search/search_page.dart';
import 'package:reminiscence/ui/providers/session_data.dart';
import 'package:reminiscence/ui/theme/app_theme.dart';
import 'package:reminiscence/ui/pages/chats_list/chats_list_page.dart';
import 'package:reminiscence/ui/pages/data_loader/data_loader_page.dart';
import 'package:reminiscence/ui/pages/loading_screen/loading_screen.dart';
import 'package:reminiscence/ui/pages/loading_screen/loading_screen_args.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await requestPermissions();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SessionData(),
      child: MaterialApp(
        title: "Reminiscence",
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
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
    } else if (settings.name == "/loading") {
      final args = settings.arguments as LoadingScreenArgs;

      return MaterialPageRoute(
        settings: settings,
        builder:
            (_) => LoadingScreen(
              operation: args.operation,
              operationParams: args.operationParams,
            ),
      );
    } else if (settings.name == "/chats") {
      return MaterialPageRoute(
        settings: settings,
        builder: (context) {
          return ChatsListPage();
        },
      );
    } else if (settings.name == "/chat") {
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
    } else if (settings.name == "/pins") {
      return MaterialPageRoute(
        settings: settings,
        builder: (context) {
          return PinnedMessagesPage();
        },
      );
    } else if (settings.name == "/graph") {
      return MaterialPageRoute(
        settings: settings,
        builder: (context) {
          return GraphPage();
        },
      );
    } else if (settings.name == "/search") {
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
