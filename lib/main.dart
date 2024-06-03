import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:wizardingworld/hive_database.dart';
import 'package:wizardingworld/landing.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

void main() async {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  HiveDatabase.initHive();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wizarding World',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LandingPage(),
    );
  }
}
