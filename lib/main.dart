// main.dart
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'splash_screen.dart'; // Add this line
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themeModeString = prefs.getString('themeMode');
    if (themeModeString != null) {
      setState(() {
        _themeMode = ThemeMode.values.firstWhere((element) => element.toString() == themeModeString);
      });
    }
  }

  Future<void> _saveThemeMode(ThemeMode themeMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', themeMode.toString());
  }

  void _toggleThemeMode() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }
      _saveThemeMode(_themeMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Book App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: _themeMode,
      initialRoute: '/', // Change this to use the splash screen initially
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/home': (context) => HomePage(toggleThemeMode: _toggleThemeMode),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}
