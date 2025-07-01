import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voice_notes/helper/local_db.dart';
import 'package:voice_notes/view/task_screen.dart';

late final ObjectBox objectBox;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  objectBox = await ObjectBox.create();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false, home: TaskScreen());
  }
}

const apiKey = 'API_KEY';
