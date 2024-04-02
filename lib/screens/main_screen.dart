import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:users/screens/drawer_screen.dart';
import 'package:users/screens/precise_pickup_location.dart';
import 'package:users/screens/search_place.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as locator;
import 'package:provider/provider.dart';
import 'package:users/assistant/assistant_methods.dart';
import 'package:users/global/global.dart';
import 'package:users/widgets/page_dialog.dart';

import '../info_mnager/info_app.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  LatLng? pickLocation;

  String? _address;

  //loc.Location location=loc.Location();

  locator.Location location = locator.Location();

  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();

  GoogleMapController? _newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();


  double searchLocationHeight = 220;
  double waitingResponsefromDriverhEIGHT = 0;
  double assignDriverInfoContainerHeight = 0;
  Position? userCurrentPosition;
  var geoLocation = Geolocator();
  LocationPermission? _locationPermission;
  double bottomPaddinMap = 0;
  List<LatLng> pLineCoordinatedList = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markerSet = {};
  Set<Circle> circulSet = {};

  late String userName;
  late String userEmail;

  bool openNavigationDrawer = true;
  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyIcon;

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.reduced);
    userCurrentPosition = cPosition;
    LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 15);


    _newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanreadbleaddress = await AssistantMethods.searchAddressForGeographicCoordinate(userCurrentPosition!, context);
    print("user Address$humanreadbleaddress");


    userName=userModelCurrentInfo!.name!;
    userEmail=userModelCurrentInfo!.email!;
  }

  // locateUserPosition() async {
  //
  //   Position position = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.high,
  //   );
  //
  //   // Update the camera position to user's current location
  //   LatLng latLngPosition = LatLng(position.latitude, position.longitude);
  //   CameraPosition cameraPosition =
  //       CameraPosition(target: latLngPosition, zoom: 15);
  //   _newGoogleMapController!
  //       .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  //
  //   String humanreadbleaddress =
  //       await AssistantMethods.searchAddressForGeographicCoordinate(
  //           userCurrentPosition!, context);
  //   print("user Address" + humanreadbleaddress);
  // }

  Future<void> drawPolyLineFromOriginToDestination(darkTheme) async {
    var originalPosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropoffLocation;

    var originLatlng = LatLng(originalPosition!.locationLatitude!,
        originalPosition.locationLongitude!);
    var destinationLatlng = LatLng(destinationPosition!.locationLatitude!,
        destinationPosition.locationLongitude!);
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "please wait",
      ),
    );
    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            originLatlng, destinationLatlng);
    setState(() {
      tripDirectionDetailInfo = directionDetailsInfo;
    });
    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodePloyLinePointsResultPoints =
        pPoints.decodePolyline(directionDetailsInfo.e_points!);

    pLineCoordinatedList.clear();

    if (decodePloyLinePointsResultPoints.isNotEmpty) {
      for (var pointLatLng in decodePloyLinePointsResultPoints) {
        pLineCoordinatedList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }
    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
          color: darkTheme ? Colors.lightBlue : Colors.lightBlueAccent,
          jointType: JointType.round,
          points: pLineCoordinatedList,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
          width: 5,
          polylineId: const PolylineId("PolylineId"));

      polylineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (originLatlng.latitude > destinationLatlng.latitude &&
        originLatlng.longitude > destinationLatlng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatlng, northeast: originLatlng);
    } else if (originLatlng.longitude > destinationLatlng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatlng.latitude, destinationLatlng.latitude),
        northeast: LatLng(destinationLatlng.latitude, originLatlng.longitude),
      );
    } else if (originLatlng.latitude > destinationLatlng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatlng.latitude, originLatlng.longitude),
        northeast: LatLng(originLatlng.latitude, destinationLatlng.longitude),
      );
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatlng, northeast: destinationLatlng);
    }
    _newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
        markerId: const MarkerId("originId"),
        infoWindow: InfoWindow(
            title: destinationPosition.locationName, snippet: "Origin"),
        position: originLatlng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));

    Marker destinationMarker = Marker(
        markerId: const MarkerId("destinationId"),
        infoWindow: InfoWindow(
            title: originalPosition.locationName, snippet: "Destination"),
        position: destinationLatlng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));

    setState(() {
      markerSet.add(originMarker);
      markerSet.add(destinationMarker);
    });

    Circle originalCircle = Circle(
        circleId: const CircleId("originId"),
        fillColor: Colors.greenAccent,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: originLatlng);

    Circle destinationCircle = Circle(
        circleId: const CircleId("destinationId"),
        fillColor: Colors.greenAccent,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: destinationLatlng);

    setState(() {
      circulSet.add(originalCircle);
      circulSet.add(destinationCircle);
    });
  }

  // getAddressFromLatLng() async {
  //   try {
  //     GeoData data = await Geocoder2.getDataFromCoordinates(
  //         latitude: pickLocation!.latitude,
  //         longitude: pickLocation!.longitude,
  //         googleMapApiKey: apiKey);
  //     setState(() {
  //       Directions userPickUpAddress = Directions();
  //       userPickUpAddress.locationLatitude = pickLocation!.latitude;
  //       userPickUpAddress.locationLongitude = pickLocation!.longitude;
  //       userPickUpAddress.locationName = data.address;
  //
  //       Provider.of<AppInfo>(context, listen: false)
  //           .updatePickUpLocationAddress(userPickUpAddress);
  //
  //       // _address = data.address;
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  checKLocationPermission() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  @override
  void initState() {
    super.initState();
    // checKLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldState,
        drawer: const DrawerScreen(),


        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _kGooglePlex,
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              polylines: polylineSet,
              markers: markerSet,
              circles: circulSet,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                _newGoogleMapController = controller;

                // locateUserPosition();

                setState(() {
                  bottomPaddinMap=200;

                });

                locateUserPosition();
              },
              // onCameraMove: (CameraPosition? position) {
              //   if (pickLocation != position!.target) {
              //     setState(() {
              //       pickLocation = position.target;
              //     });
              //   }
              // },
              // onCameraIdle: () {
              //   getAddressFromLatLng();
              // },
            ),
            // Align(
            //   alignment: Alignment.center,
            //   child: Padding(
            //     padding: const EdgeInsets.only(bottom: 35),
            //     child: Image.asset(
            //       "images/location-pointer.png",
            //       height: 30,
            //       width: 30,
            //     ),
            //   ),
            // ),


            Positioned(top: 50,left: 20,
                child: Container(
                  child: GestureDetector(
                    onTap: (){
                      scaffoldState.currentState!.openDrawer();
                    },
                    child: CircleAvatar(
                      backgroundColor: darkTheme? Colors.blueGrey: Colors.lightBlueAccent,
                      child: Icon(
                        Icons.menu,
                        color: darkTheme ? Colors.greenAccent:Colors.lightBlue,
                      ),
                    ),
                  ),

            )),


            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade500,

                      // color: darkTheme ? Colors.grey.shade700: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),

                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: Row(children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.white60,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "From",
                                      style: TextStyle(
                                          color: Colors.lightBlue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      Provider.of<AppInfo>(context)
                                                  .userPickUpLocation !=
                                              null
                                          ? "${(Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0, 24)}..."
                                          : "Not Getting Address",
                                      style: const TextStyle(
                                          color: Colors.brown, fontSize: 14),
                                    )
                                  ],
                                )
                              ]),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: Colors.black,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: GestureDetector(
                                onTap: () async {
                                  var responseFromSearchScreen =
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (c) => const SearchPlace()));
                                  if (responseFromSearchScreen ==
                                      "obtainDropoff") {
                                    setState(() {
                                      openNavigationDrawer = false;
                                    });
                                  }
                                  await drawPolyLineFromOriginToDestination(
                                      darkTheme);
                                },
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      color: Colors.white60,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "To",
                                          style: TextStyle(
                                              color: Colors.lightBlue,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          Provider.of<AppInfo>(context)
                                                      .userPickUpLocation !=
                                                  null
                                              ? Provider.of<AppInfo>(context)
                                                  .userDropoffLocation!
                                                  .locationName!
                                              : "Where",
                                          style: const TextStyle(
                                              color: Colors.brown, fontSize: 14),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (c)=>const PrecisePickUpScreen()));
                          },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkTheme ? Colors.green : Colors.blue,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                              )
                            ),
                              child: Text(
                                "change Pick UP ",
                                style: TextStyle(
                                  color: darkTheme? Colors.black: Colors.lightBlueAccent
                                ),
                              ),
                          ),
                          const SizedBox(width: 10,),

                          ElevatedButton(onPressed: (){},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: darkTheme ? Colors.green : Colors.blue,
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16
                                )
                            ),
                            child: Text(
                              "Request Ride",
                              style: TextStyle(
                                  color: darkTheme? Colors.black: Colors.lightBlueAccent
                              ),
                            ),
                          ),


                        ],
                      )






                    ],
                  ),
                ),
              ),
            ),

            // Positioned(
            //    top: 40,
            //   right: 20,
            //   left: 20,
            //   child: Container(
            //     decoration: BoxDecoration(
            //       border: Border.all(color: Colors.black),
            //       color: Colors.pink,
            //     ),
            //     padding: const EdgeInsets.all(20), // Corrected spelling: EdgeInsets.all(20)
            //     child: Text(
            //       Provider.of<AppInfo>(context).userPickUpLocation!= null
            //       ? "${(Provider.of<AppInfo> (context).userPickUpLocation!.locationName!).substring(0,24)}..."
            //       : "Not Getting Address",
            //
            //
            //       overflow: TextOverflow.visible,
            //       softWrap: true,
            //       // Corrected spelling: softWrap
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}

// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:geocoder2/geocoder2.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart' as locator;
// import 'package:users/assistant/assistant_methods.dart';
// import 'package:users/global/global.dart';
//
// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});
//
//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//
//
//
//
//
//
//
//
//
//   LatLng? pickLocation;
//
//   String? _address;
//
//   //loc.Location location=loc.Location();
//   locator.Location location = locator.Location();
//
//   final Completer<GoogleMapController> _controllerGoogleMap =
//       Completer<GoogleMapController>();
//
//   GoogleMapController? _newGoogleMapController;
//
//   static const CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(37.42796133580664, -122.085749655962),
//     zoom: 14.4746,
//   );
//   GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
//   double searchLocationHeight = 220;
//   double waitingResponsefromDriverhEIGHT = 0;
//   double assignDriverInfoContainerHeight = 0;
//   Position? userCurrentPosition;
//   var geoLocation = Geolocator();
//   LocationPermission? _locationPermission;
//   double bottomPaddinMap = 0;
//   List<LatLng> pLineCoordinatedList = [];
//   Set<Polyline> polylineSet = {};
//   Set<Marker> markerSet = {};
//   Set<Circle> circulSet = {};
//   late String userName;
//   late String userEmail;
//   bool openNavigationDrawer = true;
//   bool activeNearbyDriverKeysLoaded = false;
//   BitmapDescriptor? activeNearbyIcon;
//
//   // locateUserPosition() async{
//   //   Position cPosition =await Geolocator.getCurrentPosition(desiredAccuracy:LocationAccuracy.reduced);
//   //  userCurrentPosition=cPosition;
//   //   LatLng latLngPosition=LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
//   //   CameraPosition cameraPosition=CameraPosition(target: latLngPosition,zoom: 15);
//   //   _newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
//   //
//   //
//   //
//   // }
//
//   locateUserPosition() async {
//     // // Check if location permission is granted
//     // bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     // LocationPermission permission = await Geolocator.checkPermission();
//     //
//     // if (!serviceEnabled || permission == LocationPermission.denied) {
//     //   // Request permission or enable location services
//     //   permission = await Geolocator.requestPermission();
//     //   if (permission == LocationPermission.denied) {
//     //     // Permission still denied, handle accordingly
//     //     return;
//     //   }
//     //   if (!serviceEnabled) {
//     //     // Location services still disabled, handle accordingly
//     //     return;
//     //   }
//     // }
//
//     // Get current position
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//
//     // Update the camera position to user's current location
//     LatLng latLngPosition = LatLng(position.latitude, position.longitude);
//     CameraPosition cameraPosition =
//         CameraPosition(target: latLngPosition, zoom: 15);
//     _newGoogleMapController!
//         .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
//
//     String humanreadbleaddress =
//         await AssistantMethods.searchAddressForGeographicCoordinate(
//             userCurrentPosition!, context);
//     print("user Address" + humanreadbleaddress);
//   }
//
//   getAddressFromLatLng() async {
//     try {
//       GeoData data = await Geocoder2.getDataFromCoordinates(
//           latitude: pickLocation!.latitude,
//           longitude: pickLocation!.longitude,
//           googleMapApiKey: apiKey
//       );
//       setState(() {
//         _address = data.address;
//         print("abeeb$_address");
//       });
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   checKLocationPermission() async {
//     _locationPermission = await Geolocator.requestPermission();
//     if (_locationPermission == LocationPermission.denied) {
//       _locationPermission = await Geolocator.requestPermission();
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     checKLocationPermission();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//         onTap: () {
//           FocusScope.of(context).unfocus();
//         },
//         child: Scaffold(
//           body: Stack(
//             children: [
//               GoogleMap(
//                 initialCameraPosition: _kGooglePlex,
//                 mapType: MapType.normal,
//                 myLocationEnabled: true,
//                 zoomGesturesEnabled: true,
//                 polylines: polylineSet,
//                 markers: markerSet,
//                 circles: circulSet,
//                 onMapCreated: (GoogleMapController controller) {
//                   _controllerGoogleMap.complete(controller);
//                   _newGoogleMapController = controller;
//
//                   // locateUserPosition();
//
//                   setState(() {});
//
//                   locateUserPosition();
//                 },
//                 onCameraMove: (CameraPosition? position) {
//                   if (pickLocation != position!.target) {
//                     setState(() {
//                       pickLocation = position.target;
//                     });
//                   }
//                 },
//                 onCameraIdle: () {
//                   getAddressFromLatLng();
//                 },
//               ),
//               Align(
//                 alignment: Alignment.center,
//                 child: Padding(
//                   padding: const EdgeInsets.only(bottom: 35),
//                   child: Image.asset(
//                     "images/location-pointer.png",
//                     height: 30,
//                     width: 30,
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: 40,
//                 right: 20,
//                 left: 20,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.black),
//                     color: Colors.pink,
//                   ),
//                   padding: const EdgeInsets.all(20), // Corrected spelling: EdgeInsets.all(20)
//                   child: Text(
//                    style :TextStyle(
//                      color: Colors.black
//                    ),
//
//                     _address ?? "Set your pickup location", // Corrected spelling: _address
//                     overflow: TextOverflow.visible,
//                     softWrap: true,
//                     // Corrected spelling: softWrap
//                   ),
//                 ),
//               )
//
//             ],
//           ),
//         ),
//     );
//   }
// }

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
