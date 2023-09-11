import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login/RegisterPage.dart';
import 'firebase_options.dart';
import 'login/login_page.dart';
import 'menus/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampoyTT',
      theme: ThemeData(
        // Tema de la aplicación
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/register': (context) => RegisterPage(),

      },
    );
  }
}
