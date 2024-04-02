import 'dart:async';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:flutter/material.dart';
import 'package:users/assistant/assistant_methods.dart';
import 'package:users/global/global.dart';
import 'package:users/screens/login_screen.dart';
import 'package:users/screens/main_screen.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTimer(){
    Timer(const Duration(seconds:2),() async{
      if(firebaseAuth.currentUser!=null)
        {
          firebaseAuth.currentUser != null ? AssistantMethods.readCurrentUser():null;
          Navigator.push(context, MaterialPageRoute(builder: (c) => const MainScreen() ));
        }
      else
        {
          Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
        }

    });
  }


@override
  void initState() {
    startTimer();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      body: Center(
        child: LoadingAnimationWidget.newtonCradle(

    size: 100, color:darkTheme ? Colors.white :Colors.black ,
      ),
    ),
    );
  }
}
