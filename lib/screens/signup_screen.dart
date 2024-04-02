import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:users/global/global.dart';
import 'package:users/screens/forgot_password.dart';
import 'package:users/screens/login_screen.dart';
import 'package:users/screens/main_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final phoneTextController = TextEditingController();
  final addressTextController = TextEditingController();
  final passowrdTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();
  bool _passwordVisible = false;
  final _formkey = GlobalKey<FormState>();


  void _submit() async{
    if(_formkey.currentState!.validate())
      {
        await firebaseAuth.createUserWithEmailAndPassword(
            email: emailTextController.text.trim(), password: passowrdTextController.text.trim()
        ).then((auth) async{
          currentUser=auth.user;
          if (currentUser !=null){
            Map userMap={
              "id": currentUser!.uid,
              "name": nameTextController.text.trim(),
              "email" :emailTextController.text.trim(),
              "address":addressTextController.text.trim(),
              "phone" : phoneTextController.text.trim(),

            };
            DatabaseReference userRef=FirebaseDatabase.instance.ref().child("users");
            userRef.child(currentUser!.uid).set(userMap);
          }
          await Fluttertoast.showToast(msg: "Register successfully");
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
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
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
                    "SIGN UP",
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
                                hintText: "Name",
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
                                  Icons.person,
                                  color: darkTheme
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return "Name can't be empty";
                                }
                                if (text.length < 2) {
                                  return "please enter a valid name";
                                }
                                if (text.length > 50) {
                                  return "Name can't be more than 40 characters";
                                }
                                return null;
                              },
                              onChanged: (text) {
                                setState(() {
                                  nameTextController.text = text;
                                });
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
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
                            IntlPhoneField(
                              showCountryFlag: true,
                              dropdownIcon: Icon(
                                Icons.arrow_drop_down_circle_rounded,
                                color: darkTheme
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                              decoration: InputDecoration(
                                hintText: "Phone Number",
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
                                      ? Colors.amber.shade400
                                      : Colors.grey,
                                ),
                              ),
                              initialCountryCode: "ET",
                              onChanged: (text) {
                                setState(() {
                                  phoneTextController.text = text.completeNumber;
                                });
                              },
                            ),
                            TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(60)
                              ],
                              decoration: InputDecoration(
                                hintText: "Address...",
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
                                  Icons.holiday_village,
                                  color: darkTheme
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return "Adress can't be empty";
                                }
                                if (text.length < 2) {
                                  return "please enter a valid Adress";
                                }

                                if (text.length > 200) {
                                  return "Adress can't be more than 60 characters";
                                }
                                return null;
                              },
                              onChanged: (text) {
                                setState(() {
                                  addressTextController.text = text;
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
                            TextFormField(
                              obscureText: !_passwordVisible,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(60)
                              ],
                              decoration: InputDecoration(
                                  hintText: "Confirm Password...",
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
                                if (text != passowrdTextController.text) {
                                  return "Password does't match";
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
                                  confirmPasswordTextController.text = text;
                                });
                              },
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
                                  "Register",
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
                                const Text("Have An Account?",style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15
                                ),),
                                const SizedBox(width: 5,),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder:(contex) => const LoginScreen()));


                                  },
                                  child: Text("Sign In",style: TextStyle(
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
