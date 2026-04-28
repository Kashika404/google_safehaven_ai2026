import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:safehaven_dashboard/firebase_options.dart';
import 'package:safehaven_dashboard/screens/dashboard/dashboard_screen.dart';
import 'package:safehaven_dashboard/screens/sos/sos_screen.dart'; // ← ADD THIS
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  usePathUrlStrategy();
  runApp(const SafeHavenApp());
}

class SafeHavenApp extends StatelessWidget {
  const SafeHavenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeHaven',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1117),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/sos':
            return MaterialPageRoute(builder: (context) => const SosScreen());
          case '/':
          default:
            return MaterialPageRoute(
              builder: (context) => const DashboardScreen(),
            );
        }
      },
    );
  }
}
