import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_task_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Parse
  const String appId = 'Dt2JFIMuRYO99W2NZ4Wh67GVE6ep6ZmWzQYTWorr';
  const String clientKey = 'VVu8K90Oo446HTgI2zVvkBRMPMcRMnXU8j95KOd1';
  const String parseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(appId, parseServerUrl, clientKey: clientKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QuickTask',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login', // Set initial route to login screen
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
        '/addTask': (context) => AddTaskScreen(),
      },
    );
  }
}
