import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/permissions_manager/permissions_manager.dart';
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
    return MaterialApp(
      title: "Reminiscence",
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: "/",
      onGenerateRoute: onGenerateRoute,
    );
  }

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == '/') {
      return MaterialPageRoute(
        builder: (context) {
          return DataLoaderPage();
        },
      );
    } else if (settings.name == "/loading") {
      final args = settings.arguments as LoadingScreenArgs;

      return MaterialPageRoute(
        builder:
            (_) => LoadingScreen(
              operation: args.operation,
              operationParams: args.operationParams,
            ),
      );
    } else if (settings.name == "/chats") {
      final data = settings.arguments as ReminiscenceData;

      return MaterialPageRoute(
        builder: (context) {
          return ChatsListPage(data);
        },
      );
    }

    return null;
  }
}
