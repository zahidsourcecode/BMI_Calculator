import 'package:flutter/material.dart';
import 'Screens/welcome_page.dart';
import 'Screens/SavedResults_Page.dart';
import 'Services/theme_controller.dart';
import 'constants.dart';
import 'theme/app_palette.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeController _themeController = ThemeController();

  @override
  void initState() {
    super.initState();
    _themeController.load();
  }

  @override
  Widget build(BuildContext context) {
    return AppThemeScope(
      controller: _themeController,
      child: ListenableBuilder(
        listenable: _themeController,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Your BMI',
            theme: buildAppTheme(AppPalette.light),
            darkTheme: buildAppTheme(AppPalette.dark),
            themeMode: _themeController.mode,
            home: const WelcomePage(),
            routes: {
              '/history': (context) => const SavedResultsPage(),
            },
          );
        },
      ),
    );
  }
}
