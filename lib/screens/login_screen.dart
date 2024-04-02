import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:users/screens/forgot_password.dart';
import 'package:users/screens/signup_screen.dart';

import '../global/global.dart';
import 'main_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailTextController = TextEditingController();
  final passowrdTextController = TextEditingController();

  bool _passwordVisible = false;
  final _formkey = GlobalKey<FormState>();


  void _submit() async{
    if(_formkey.currentState!.validate())
    {
      await firebaseAuth.signInWithEmailAndPassword(
          email: emailTextController.text.trim(), password: passowrdTextController.text.trim()
      ).then((auth) async{
        currentUser=auth.user;

        await Fluttertoast.showToast(msg: "Login successfully");
        Navigator.push(context, MaterialPageRoute(builder:(contex) => const MainScreen()));


      }).catchError((e){
        Fluttertoast.showToast(msg: "Error occured: \n $e");

      });


    }
    else{
      Fluttertoast.showToast(msg: "something went wrong, please try again");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(0),
            children: [
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Image.asset(
                      darkTheme ? "images/day.jpg" : "images/night.png",
                      height: 100,

                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "LOGIN PAGE",
                    style: TextStyle(
                        color:
                        darkTheme ? Colors.lightBlueAccent : Colors.lightBlue,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Form(
                            key: _formkey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [


                                TextFormField(
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(60)
                                  ],
                                  decoration: InputDecoration(
                                    hintText: "Email",
                                    hintStyle: const TextStyle(color: Colors.grey),
                                    filled: true,
                                    fillColor: darkTheme
                                        ? Colors.black45
                                        : Colors.grey.shade300,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(45),
                                        borderSide: const BorderSide(
                                            width: 0, style: BorderStyle.none)),
                                    prefixIcon: Icon(
                                      Icons.email,
                                      color: darkTheme
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                  autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return "Email can't be empty";
                                    }
                                    if (text.length < 2) {
                                      return "please enter a valid Email";
                                    }
                                    if (EmailValidator.validate(text) == true) {
                                      return null;
                                    }
                                    if (text.length > 50) {
                                      return "Email can't be more than 40 characters";
                                    }
                                    return null;
                                  },
                                  onChanged: (text) {
                                    setState(() {
                                      emailTextController.text = text;
                                    });
                                  },
                                ),
                                const SizedBox(
                                  height: 10,
                                ),

                                TextFormField(
                                  obscureText: !_passwordVisible,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(60)
                                  ],
                                  decoration: InputDecoration(
                                      hintText: "Password...",
                                      hintStyle: const TextStyle(color: Colors.grey),
                                      filled: true,
                                      fillColor: darkTheme
                                          ? Colors.black45
                                          : Colors.grey.shade300,
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(45),
                                          borderSide: const BorderSide(
                                              width: 0, style: BorderStyle.none)),
                                      prefixIcon: Icon(
                                        Icons.password,
                                        color: darkTheme
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _passwordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: darkTheme
                                              ? Colors.black
                                              : Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _passwordVisible = !_passwordVisible;
                                          });
                                        },
                                      )),
                                  autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return "Password can't be empty";
                                    }
                                    if (text.length < 2) {
                                      return "please enter a valid Password";
                                    }

                                    if (text.length > 50) {
                                      return "Password can't be more than 40 characters";
                                    }
                                    return null;
                                  },
                                  onChanged: (text) {
                                    setState(() {
                                      passowrdTextController.text = text;
                                    });
                                  },
                                ),
                                const SizedBox(
                                  height: 10,
                                ),

                                const SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        foregroundColor: darkTheme ? Colors.black87 : Colors.white, backgroundColor: darkTheme
                                            ? Colors.lightBlueAccent
                                            : Colors.lightBlueAccent.shade700,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20)),
                                        minimumSize: const Size(double.infinity, 50)),
                                    onPressed: () {
                                      setState(() {
                                        _submit();

                                      });
                                    },
                                    child: const Text(
                                      "Login",
                                      style: TextStyle(fontSize: 20),
                                    )),
                                const SizedBox(height: 20,),
                                GestureDetector(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder:(contex) => const ForgotPasswordScreen()));


                                  },
                                  child: Text("Forgot Password?",style: TextStyle(
                                      color: darkTheme ? Colors.blue : Colors.lightBlue
                                  ),),
                                ),
                                const SizedBox(height: 30,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,

                                  children: [
                                    const Text("Don't have An Account?",style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15
                                    ),),
                                    const SizedBox(width: 5,),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder:(contex) => const SignupScreen()));


                                      },
                                      child: Text("Register",style: TextStyle(
                                          fontSize: 15,
                                          color: darkTheme? Colors.lightBlue :Colors.lightBlue
                                      ),),

                                    )
                                  ],
                                )
                              ],
                            ))
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
