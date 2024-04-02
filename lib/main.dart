import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users/info_mnager/info_app.dart';
import 'package:users/splash/splash_screen.dart';
import 'package:users/themeProvider/theme_provider.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDvDTif2c7C7KrltE0s4JvQ0RmEw0DG5ZU",
          appId: "1:204522014600:android:9ae718ce4aee4a26a69c3d",
          messagingSenderId: "204522014600",
          projectId: "fir-a9143",
          databaseURL:"https://fir-a9143-default-rtdb.firebaseio.com/"
      )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (context) => AppInfo(),
    child: MaterialApp(
        title: 'Flutter Demo',
        themeMode: ThemeMode.system,
        theme: MyThemes.lightTheme,
        darkTheme: MyThemes.darkTheme,

        home: const SplashScreen()
    ),);
  }
}
