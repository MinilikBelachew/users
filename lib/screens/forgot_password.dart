import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:users/global/global.dart';
import 'package:users/screens/login_screen.dart';
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  final emailTextController = TextEditingController();


  final bool _passwordVisible = false;
  final _formkey = GlobalKey<FormState>();

  void _submit(){
    firebaseAuth.sendPasswordResetEmail(email: emailTextController.text.trim()
    ).then((value) {
      Fluttertoast.showToast(msg: "We have Sent An email to reset password check your email ");
    }).onError((error,stackTrace)
        {
          Fluttertoast.showToast(msg: "Error Occur : \n${error.toString()}");

  });
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
                                      "Send Reset Link",
                                      style: TextStyle(fontSize: 20),
                                    )),
                                const SizedBox(height: 20,),
                                GestureDetector(
                                  onTap: (){

                                  },
                                  child: Text("Forgot Password?",style: TextStyle(
                                      color: darkTheme ? Colors.blue : Colors.lightBlue
                                  ),),
                                ),
                                const SizedBox(height: 30,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,

                                  children: [
                                    const Text(" have An Account?",style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15
                                    ),),
                                    const SizedBox(width: 5,),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder:(contex) => const LoginScreen()));


                                      },
                                      child: Text("Login",style: TextStyle(
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






// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class MainScreen extends StatefulWidget {
//   const MainScreen({Key? key}) : super(key: key);
//
//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//
//
//      Position? userCurrentPosition;
//
//   final Completer<GoogleMapController> _controllerGoogleMap = Completer<GoogleMapController>();
//   GoogleMapController? _newGoogleMapController;
//   Set<Polyline> polylineSet = {};
//   Set<Marker> markerSet = {};
//   Set<Circle> circleSet = {};
//
//   late final Future<Position?> _initialization = _getUserLocation();
//
//   Future<Position?> _getUserLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // Handle disabled location services
//       return null;
//     }
//
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         // Handle denied location permissions
//         return null;
//       }
//     }
//
//     return Geolocator.getCurrentPosition();
//   }
//
//   void _moveToUserLocation(Position position) async{
//          Position cPosition =await Geolocator.getCurrentPosition(desiredAccuracy:LocationAccuracy.reduced);
//     userCurrentPosition=cPosition;
//     LatLng latLngPosition = LatLng(position.latitude, position.longitude);
//     CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 15);
//     _newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder<Position?>(
//         future: _initialization,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError || snapshot.data == null) {
//             // Handle errors in fetching location
//             return const Center(child: Text('Error fetching location'));
//           } else {
//             Position userCurrentPosition = snapshot.data!;
//             return GoogleMap(
//               initialCameraPosition: CameraPosition(
//                 target: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
//                 zoom: 15,
//               ),
//               mapType: MapType.normal,
//               myLocationEnabled: true,
//               zoomGesturesEnabled: true,
//               polylines: polylineSet,
//               markers: markerSet,
//               circles: circleSet,
//               onMapCreated: (GoogleMapController controller) {
//                 _controllerGoogleMap.complete(controller);
//                 _newGoogleMapController = controller;
//                 _moveToUserLocation(userCurrentPosition);
//               },
//               onCameraMove: (CameraPosition position) {
//                 // Handle camera movements
//               },
//               onCameraIdle: () {
//                 // Handle camera idle state
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }

















