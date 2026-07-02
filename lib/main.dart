import 'package:flutter/material.dart';
import 'Screens/welcome_page.dart';
import 'Screens/SavedResults_Page.dart';
import 'Services/results_repository.dart';
import 'Services/theme_controller.dart';
import 'constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ResultsRepository.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: MediaQuery.textScalerOf(context).clamp(
                  minScaleFactor: 0.85,
                  maxScaleFactor: 1.2,
                ),
              ),
              child: child!,
            ),
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
