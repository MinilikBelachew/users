import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:users/assistant/assistent_gofire.dart';
import 'package:users/models/active_nearby_available_driver.dart';
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
import 'package:users/splash/splash_screen.dart';
import 'package:users/widgets/page_dialog.dart';
import 'package:users/widgets/pay_price_dialog.dart';

import '../info_mnager/info_app.dart';
import '../models/directions.dart';
Future<void> _makePhoneCall(String url) async {
  if(await canLaunch(url)) {
    await launch(url);

  }
  else {
    throw "could not launch$url";
  }
}


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
  double suggestedRideContainerHeight = 0;
  double searchingForDriverContainerHeight=0;

  Position? userCurrentPosition;

  var geoLocation = Geolocator();
  LocationPermission? _locationPermission;
  double bottomPaddinMap = 0;

  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markerSet = {};
  Set<Circle> circulSet = {};

  late String userName;
  late String userEmail;



  DatabaseReference? referenceRideRequest;

  bool openNavigationDrawer = true;

  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyIcon;

  String selectedVehicleType = "";

  String driverRideStatus= "Driver is Coming";
  StreamSubscription<DatabaseEvent>? tripRidesRequestInfoStreamSubscription;

  List<ActiveNearByAvailableDrivers> onlineNearByAvailableDriverList=[];
  String userRideRequestStatus="";
  bool requestPositionInfo=true;

  get amount => null;


  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;
    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 15);

    _newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanreadbleaddress =
        await AssistantMethods.searchAddressForGeographicCoordinate(
            userCurrentPosition!, context);
    print("user Address$humanreadbleaddress");

    userName = userModelCurrentInfo!.name!;
    userEmail = userModelCurrentInfo!.email!;
    initializeGeoFireListener();
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

  initializeGeoFireListener() {
    Geofire.initialize("activeDrivers");
    Geofire.queryAtLocation(userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!
    .listen((map) {
      print(map);

      if(map !=null) {
        var callBack = map["callBack"];
        switch(callBack) {
          case Geofire.onKeyEntered:
            ActiveNearByAvailableDrivers activeNearByAvailableDrivers=ActiveNearByAvailableDrivers();
            activeNearByAvailableDrivers.locationLatitude=map["latitude"];
            activeNearByAvailableDrivers.locationLongitude=map["longitude"];
            activeNearByAvailableDrivers.driverId=map["key"];
            GeoFireAssistant.activeNearByAvailableDriverList.add(activeNearByAvailableDrivers);
            if(activeNearbyDriverKeysLoaded==true) {
              displayActiveDriversOnUserMap();
            }
            break;


          case Geofire.onKeyExited:
            GeoFireAssistant.deleteOfflineDriverFromList(map["key"]);
            displayActiveDriversOnUserMap();
            break;
          case Geofire.onKeyMoved:
            ActiveNearByAvailableDrivers activeNearByAvailableDrivers= ActiveNearByAvailableDrivers();
            activeNearByAvailableDrivers.locationLatitude=map["latitude"];
            activeNearByAvailableDrivers.locationLongitude=map["longitude"];
            activeNearByAvailableDrivers.driverId=map["key"];
            GeoFireAssistant.updateActiveNearByAvailableDriverLocation(activeNearByAvailableDrivers);
            displayActiveDriversOnUserMap();
            break;

          case Geofire.onGeoQueryReady:
            activeNearbyDriverKeysLoaded=true;
            displayActiveDriversOnUserMap();
            break;

        }
      }

      setState(() {

      });
    });
  }
  displayActiveDriversOnUserMap(){
    setState(() {
      markerSet.clear();
      circulSet.clear();


      Set<Marker> driverMarkerSet=Set<Marker>();


      for(ActiveNearByAvailableDrivers eachDriver in GeoFireAssistant.activeNearByAvailableDriverList) {
        LatLng eachDriverActivePosition=LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);


        Marker marker =Marker(
            markerId: MarkerId(eachDriver.driverId!),
          position: eachDriverActivePosition,
          icon: activeNearbyIcon!,
            rotation: 360


        );
        driverMarkerSet.add(marker);
      }

      setState(() {
        markerSet=driverMarkerSet;

      });
    });
  }


  createActiveNearByDriverIconMarker(){
    if(activeNearbyIcon==null) {
      ImageConfiguration imageConfiguration= createLocalImageConfiguration(context,size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car.png").then((value){
        activeNearbyIcon=value;
      });
    }
  }

  Future<void> drawPolyLineFromOriginToDestination(bool darkTheme) async {
    var originalPosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropoffLocation;

    if (originalPosition == null || destinationPosition == null) {
      // Handle case where either originalPosition or destinationPosition is null
      return;
    }

    var originLatlng = LatLng(
      originalPosition.locationLatitude!,
      originalPosition.locationLongitude!,
    );

    var destinationLatlng = LatLng(
      destinationPosition.locationLatitude!,
      destinationPosition.locationLongitude!,
    );
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

    pLineCoOrdinatesList.clear();

    if (decodePloyLinePointsResultPoints.isNotEmpty) {
      decodePloyLinePointsResultPoints.forEach((PointLatLng pointLatLng) {
        pLineCoOrdinatesList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    // if (decodePloyLinePointsResultPoints.isNotEmpty) {
    //   for (var pointLatLng in decodePloyLinePointsResultPoints) {
    //     pLineCoordinatedList
    //         .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
    //   }
    // }
    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
          color: darkTheme ? Colors.lightBlue : Colors.lightBlueAccent,
          jointType: JointType.round,
          points: pLineCoOrdinatesList,
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
        southwest: LatLng(originLatlng.latitude, destinationLatlng.longitude),
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
  void showSearchingForDriversContainer(){
    setState(() {

      searchingForDriverContainerHeight=200;

    });
  }

  void showSuggestedRideContainer() {
    setState(() {
      suggestedRideContainerHeight = 420;
      bottomPaddinMap = 400;
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
  //       _address = data.address;
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
     checKLocationPermission();
  }


 saveRideRequestInformation( String selectedVehicleType ) async{
//save Ride Request Information
   referenceRideRequest = FirebaseDatabase.instance.ref().child("AllRideRequest").push();

   var originLocation= Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
   var destinationLocation=Provider.of<AppInfo>(context, listen: false).userDropoffLocation;

   Map originLocationMap= {
     "latitude": originLocation!.locationLatitude.toString(),
     "longitude" : originLocation.locationLongitude.toString()
   };
   Map destinationLocationMap= {
     "latitude": destinationLocation!.locationLatitude.toString(),
     "longitude" : destinationLocation.locationLongitude.toString()
   };

   Map userInformationMap= {
     "origin": originLocationMap,
     "destination": destinationLocationMap,
     "time": DateTime.now().toString(),
     "userName": userModelCurrentInfo!.name,
     "userPhone":userModelCurrentInfo!.phone,
     "originAddress":originLocation.locationName,
     "destinationAddress": destinationLocation.locationName,
     "driverId": "waiting",
   };

   referenceRideRequest!.set(userInformationMap);
   tripRidesRequestInfoStreamSubscription = referenceRideRequest!.onValue.listen((eventSnap) async {
     if(eventSnap.snapshot.value == null) {
       return;
     }


     if((eventSnap.snapshot.value as Map) ["car_details"] !=null) {
       setState(() {
         driverCarDetails = (eventSnap.snapshot.value as Map)["car_details"].toString();
       });
     }



     if((eventSnap.snapshot.value as Map) ["driverPhone"] !=null) {
       setState(() {
         driverPhone = (eventSnap.snapshot.value as Map)["driverPhone"].toString();
       });
     }


     if((eventSnap.snapshot.value as Map) ["driverName"] !=null) {
       setState(() {
         driverName = (eventSnap.snapshot.value as Map)["driverName"].toString();
       });
     }


     if((eventSnap.snapshot.value as Map) ["status"] !=null) {
       setState(() {
         userRideRequestStatus = (eventSnap.snapshot.value as Map)["status"].toString();
       });
     }

     
     if((eventSnap.snapshot.value as Map)["driverLocation"] !=null) {
       // setState(() async {
         double driverCurrentPositionLat= double.parse((eventSnap.snapshot.value as Map) ["driverLocation"]["latitude"].toString());
         double driverCurrentPositionLng= double.parse((eventSnap.snapshot.value as Map) ["driverLocation"]["longitude"].toString());

         LatLng driverCurrentPositionLatLng= LatLng(driverCurrentPositionLat, driverCurrentPositionLng);

         // ststus accepted

         if(userRideRequestStatus =="accepted") {
           updateArrivalTimeToUserPickUpLocation(driverCurrentPositionLatLng);
         }
         //status arrived

         if(userRideRequestStatus == "arrived") {
           setState(() {
             driverRideStatus="Drive Has Arrived";
           });
         }

         //status on trip


         if(userRideRequestStatus =="ontrip") {
           updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng);

         }

         if(userRideRequestStatus == "ended") {
           if((eventSnap.snapshot.value as Map)["amount"] !=null){
             double fareAmount= double.parse((eventSnap.snapshot.value as  Map) ["amount"].toString());


             var response = await showDialog(
               context: context,

                 builder: ( BuildContext context) => PayPriceDialog(
                   amount: amount,
                 ),
             );

             if(response == "Cash Paid") {
               //user car rate the

               if((eventSnap.snapshot.value as Map)["driverId"] !=null) {
                 String assignDriverId=(eventSnap.snapshot.value as Map)["driverId"].toString();
                 // Navigator.push(context, MaterialPageRoute(builder: (c) => RateDriverScreen()));


                 referenceRideRequest!.onDisconnect();
                 tripRidesRequestInfoStreamSubscription!.cancel();
               }
             }
           }
         }
      // });
     }




   });

   onlineNearByAvailableDriverList= GeoFireAssistant.activeNearByAvailableDriverList;
   searchNearestOnlineDrivers(selectedVehicleType);
}


  searchNearestOnlineDrivers(String selectedVehicleType) async {
    if(onlineNearByAvailableDriverList.length == 0) {
      referenceRideRequest!.remove();


      setState(() {
        polylineSet.clear();
        markerSet.clear();
        circulSet.clear();
        pLineCoOrdinatesList.clear();

      });

      Fluttertoast.showToast(msg: "No onlie Nearest Driver Available");
      Fluttertoast.showToast(msg: "Search Again.\n Restarting App");

      Future.delayed(Duration(milliseconds: 4000),() {
        referenceRideRequest!.remove();
        Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));

      });

      return;
    }
    await retrieveOnlineDriversInformation(onlineNearByAvailableDriverList);
    print("Driver List: " + driversList.toString());

    for(int i=0;i < driversList.length; i++) {
      if(driversList[i]["car_details"]["type"] == selectedVehicleType) {
        AssistantMethods.sendNotificationToDriverNow(driversList[i]["token"],referenceRideRequest!.key!,context );
      }
    }
    Fluttertoast.showToast(msg: "NotificationSent Successfully");

    showSearchingForDriversContainer();
    await FirebaseDatabase.instance.ref().child("AllRideRequest").child(referenceRideRequest!.key!).child("driverId").onValue.listen((eventRideRequestSnapshot) {

      print("Event Snapshot : ${eventRideRequestSnapshot.snapshot.value} ");
      if(eventRideRequestSnapshot.snapshot.value !=null) {
        if(eventRideRequestSnapshot.snapshot.value != "waiting"){
          showUIForAssignedDriverInfo();
        }
      }
    });
  }




  updateArrivalTimeToUserPickUpLocation(driverCurrentPositionLatLng)async {
    if(requestPositionInfo == true) {
      requestPositionInfo= false;

      LatLng userPickUpPosition = LatLng( userCurrentPosition!.latitude, userCurrentPosition!.longitude);
      
      var directionDetailsInfo= await AssistantMethods.obtainOriginToDestinationDirectionDetails(driverCurrentPositionLatLng, userPickUpPosition);
      
      
      if(directionDetailsInfo == null) {
        return;
      }
      setState(() {
        driverRideStatus = "Drive Is Coming: " + directionDetailsInfo.duration_txt.toString();
      });
      
      requestPositionInfo= true;
      
      

      
    }


  }

  updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng) async {
    if(requestPositionInfo == true) {
      requestPositionInfo =false;
      var dropOffLocation= Provider.of<AppInfo> (context , listen: false).userDropoffLocation;
      
      LatLng userDestinationPosition = LatLng(
  dropOffLocation!.locationLatitude!, 
  dropOffLocation.locationLongitude!
  );
      
      var directionDetailsInfo= await AssistantMethods.obtainOriginToDestinationDirectionDetails(driverCurrentPositionLatLng, userDestinationPosition);
      
      if(directionDetailsInfo == null) {
        return;
      }
      setState(() {
        driverRideStatus= " Going Towards Destination: " + directionDetailsInfo.duration_txt.toString();
      });
      requestPositionInfo =true;
      
  }
}


  showUIForAssignedDriverInfo(){
    setState(() {

      waitingResponsefromDriverhEIGHT=0;
      searchLocationHeight=0;
      assignDriverInfoContainerHeight=200;
      suggestedRideContainerHeight=0;
      bottomPaddinMap=200;
    });
  }


  retrieveOnlineDriversInformation(List onlineNeareastDriverList) async {
    driversList.clear();

    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");

    for (int i = 0; i < onlineNeareastDriverList.length; i++) {
await ref.child(onlineNeareastDriverList[i].driverId.toString()).once().then((dataSnapshot) {
  var driverKeyInfo=dataSnapshot.snapshot.value;

  driversList.add(driverKeyInfo);
  print("driver Key information= " + driversList.toString());
});

    }





  }  // retrieveOnlineDriversInformation( List onlineNeareastDriverList) async{
  //   driverList.clear();
  //   DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");
  //   for(int i=0 ; i< onlineNeareastDriverList.length; i++) {
  //     await ref.child(onlineNeareastDriverList[i].driverId.toString()).once().then((dataSnapshot) {
  //       var driverKeyInfo= dataSnapshot.snapshot.value;
  //       driverList.add(driverKeyInfo);
  //       print("driverKeyInformation= :" + driverList.toString());
  //     });
  //   }
  //
  //
  // }


  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    createActiveNearByDriverIconMarker();
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
                  bottomPaddinMap = 200;
                });

                locateUserPosition();
              },
              onCameraMove: (CameraPosition? position) {
                if (pickLocation != position!.target) {
                  setState(() {
                    pickLocation = position.target;
                  });
                }
              },
              onCameraIdle: () {
                //getAddressFromLatLng();
              },
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 35),
                child: Image.asset(
                  "images/car.png",
                  height: 30,
                  width: 30,
                ),
              ),
            ),

            Positioned(
                top: 50,
                left: 20,
                child: Container(
                  child: GestureDetector(
                    onTap: () {
                      scaffoldState.currentState!.openDrawer();
                    },
                    child: CircleAvatar(
                      backgroundColor:
                          darkTheme ? Colors.blueGrey : Colors.lightBlueAccent,
                      child: Icon(
                        Icons.menu,
                        color:
                            darkTheme ? Colors.greenAccent : Colors.lightBlue,
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
                                      Provider.of<AppInfo>(context).userPickUpLocation != null
                                          ? Provider.of<AppInfo>(context).userPickUpLocation!.locationName!.length > 24
                                          ? "${Provider.of<AppInfo>(context).userPickUpLocation!.locationName!.substring(0, 24)}"
                                          : "${Provider.of<AppInfo>(context).userPickUpLocation!.locationName!}"
                                          : "No location available",

                                      // Provider.of<AppInfo>(context)
                                      //             .userPickUpLocation !=
                                      //         null
                                      //     ? "${Provider.of<AppInfo>(context).userPickUpLocation?.locationName?.substring(0, 54) ?? 'Address not available'}"
                                      //     : "Not Getting Address",
                                      style: const TextStyle(
                                        color: Colors.brown,
                                        fontSize: 14,
                                      ),
                                    )

                                    // Text(
                                    //   Provider.of<AppInfo>(context)
                                    //               .userPickUpLocation !=
                                    //           null
                                    //       ? "${(Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0, 24)}..."
                                    //       : "Not Getting Address",
                                    //   style: const TextStyle(
                                    //       color: Colors.brown, fontSize: 14),
                                    // )
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
                                              builder: (c) =>
                                                  const SearchPlace()));
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
                                                      .userDropoffLocation !=
                                                  null
                                              ? (Provider.of<AppInfo>(context)
                                                          .userDropoffLocation !=
                                                      null)
                                                  ? Provider.of<AppInfo>(
                                                          context)
                                                      .userDropoffLocation!
                                                      .locationName!
                                                  : "Dropoff location unavailable"
                                              : "Where",
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.brown,
                                            fontSize: 14,
                                          ),
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
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (c) =>
                                          const PrecisePickUpScreen()));
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    darkTheme ? Colors.green : Colors.blue,
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            child: Text(
                              "change Pick UP ",
                              style: TextStyle(
                                  color: darkTheme
                                      ? Colors.black
                                      : Colors.lightBlueAccent),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (Provider.of<AppInfo>(context, listen: false)
                                      .userDropoffLocation != null) {
                                showSuggestedRideContainer();
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Please add destination location");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    darkTheme ? Colors.green : Colors.blue,
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            child: Text(
                              "Show Price",
                              style: TextStyle(
                                  color: darkTheme
                                      ? Colors.black
                                      : Colors.lightBlueAccent),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: suggestedRideContainerHeight,
                decoration: BoxDecoration(
                    color: darkTheme ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20))),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: darkTheme
                                  ? Colors.lightBlueAccent
                                  : Colors.blue,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Icon(
                              Icons.star,
                              color: darkTheme ? Colors.white : Colors.black,
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            Provider.of<AppInfo>(context).userPickUpLocation != null
                                ? Provider.of<AppInfo>(context).userPickUpLocation!.locationName != null
                                ? "${Provider.of<AppInfo>(context).userPickUpLocation!.locationName!.substring(0, 2) ?? 'Address not available'}"
                                : "Address not available"
                                : "Not Getting Address",

                            // Provider.of<AppInfo>(context).userPickUpLocation !=
                            //         null
                            //     ? "${Provider.of<AppInfo>(context).userPickUpLocation?.locationName?.substring(0, 24) ?? 'Address not available'}"
                            //     : "Not Getting Address",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: darkTheme
                                  ? Colors.lightBlueAccent
                                  : Colors.blue,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Icon(
                              Icons.star,
                              color: darkTheme ? Colors.white : Colors.black,
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            Provider.of<AppInfo>(context).userDropoffLocation !=
                                    null
                                ? (Provider.of<AppInfo>(context)
                                            .userDropoffLocation !=
                                        null)
                                    ? Provider.of<AppInfo>(context)
                                        .userDropoffLocation!
                                        .locationName!
                                    : "Dropoff location unavailable"
                                : "Where",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Suggested Rides",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedVehicleType = "Isuzu";
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: selectedVehicleType == "Isuzu"
                                        ? (darkTheme
                                            ? Colors.lightBlueAccent.shade400
                                            : Colors.lightBlue)
                                        : (darkTheme
                                            ? Colors.black54
                                            : Colors.grey[100]),
                                    borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: EdgeInsets.all(25),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        "images/3d-truck.png",
                                        scale: 10,
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        "Isuzu",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: selectedVehicleType == "Isuzu"
                                                ? (darkTheme
                                                    ? Colors.black
                                                    : Colors.white)
                                                : (darkTheme
                                                    ? Colors.white
                                                    : Colors.black)),
                                      ),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        tripDirectionDetailInfo != null
                                            ? "Birr ${((AssistantMethods.caculateFareAmountFromOriginToDestination(tripDirectionDetailInfo!) * 2) * 107).toStringAsFixed(1)}"
                                            : "null",
                                        style: TextStyle(color: Colors.grey),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedVehicleType = "Sino Truck";
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: selectedVehicleType == "Sino Truck"
                                        ? (darkTheme
                                        ? Colors.lightBlueAccent.shade400
                                        : Colors.lightBlue)
                                        : (darkTheme
                                        ? Colors.black54
                                        : Colors.grey[100]),
                                    borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: EdgeInsets.all(25),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        "images/car.png",
                                        scale: 2,
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        "Sino Truck",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: selectedVehicleType == "Sino Truck"
                                                ? (darkTheme
                                                ? Colors.black
                                                : Colors.white)
                                                : (darkTheme
                                                ? Colors.white
                                                : Colors.black)),
                                      ),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        tripDirectionDetailInfo != null
                                            ? "Birr ${((AssistantMethods.caculateFareAmountFromOriginToDestination(tripDirectionDetailInfo!) * 3) * 107).toStringAsFixed(1)}"
                                            : "null",
                                        style: TextStyle(color: Colors.grey),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedVehicleType = "Truck";
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: selectedVehicleType == "Truck"
                                        ? (darkTheme
                                        ? Colors.lightBlueAccent.shade400
                                        : Colors.lightBlue)
                                        : (darkTheme
                                        ? Colors.black54
                                        : Colors.grey[100]),
                                    borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: EdgeInsets.all(25),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        "images/mule3.png",
                                        scale: 6,
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        "Truck",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: selectedVehicleType == "Truck"
                                                ? (darkTheme
                                                ? Colors.black
                                                : Colors.white)
                                                : (darkTheme
                                                ? Colors.white
                                                : Colors.black)),
                                      ),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        tripDirectionDetailInfo != null
                                            ? "Birr ${((AssistantMethods.caculateFareAmountFromOriginToDestination(tripDirectionDetailInfo!) * 2) * 107).toStringAsFixed(1)}"
                                            : "null",
                                        style: TextStyle(color: Colors.grey),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedVehicleType = "Truckone";
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: selectedVehicleType == "Truckone"
                                        ? (darkTheme
                                        ? Colors.lightBlueAccent.shade400
                                        : Colors.lightBlue)
                                        : (darkTheme
                                        ? Colors.black54
                                        : Colors.grey[100]),
                                    borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: EdgeInsets.all(25),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        "images/truck_one.png",
                                        scale: 6,
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        "Truck",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: selectedVehicleType == "Truckone"
                                                ? (darkTheme
                                                ? Colors.black
                                                : Colors.white)
                                                : (darkTheme
                                                ? Colors.white
                                                : Colors.black)),
                                      ),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        tripDirectionDetailInfo != null
                                            ? "Birr ${((AssistantMethods.caculateFareAmountFromOriginToDestination(tripDirectionDetailInfo!) * 2) * 107).toStringAsFixed(1)}"
                                            : "null",
                                        style: TextStyle(color: Colors.grey),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )


                          ],
                        ),
                      ),
                      SizedBox(height: 20,),

                      Expanded(

                        child: GestureDetector(
                        onTap: () {
                          if(selectedVehicleType != "") {

                            saveRideRequestInformation(selectedVehicleType);
                          }
                          else {
                            Fluttertoast.showToast(msg: "Please Select  From The above...");
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: darkTheme ? Colors.lightBlue.shade400 : Colors.blueGrey,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Center(
                            child: Text(
                              "Request a Ride",
                              style: TextStyle(
                                color: darkTheme ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20
                              ),
                            ),

                          ),
                        ),
                      ),
                      ),


                    ],
                  ),
                ),
              ),
            ),

            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: searchingForDriverContainerHeight,
                  decoration: BoxDecoration(
                      color: darkTheme? Colors.black: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15))
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LinearProgressIndicator(
                          color: darkTheme? Colors.white: Colors.black,
                        ),
                        SizedBox(height: 10,),
                        Center(
                          child: Text("Seaching Driver...",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 20,
                                fontWeight: FontWeight.bold

                            ),),
                        ),
                        SizedBox(height: 20,),
                        GestureDetector(
                          onTap: () {
                            referenceRideRequest!.remove();
                            setState(() {
                              searchingForDriverContainerHeight=0;
                              suggestedRideContainerHeight=0;
                            });
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                color: darkTheme? Colors.black:Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(width: 1,color: Colors.grey)
                            ),
                            child: Icon(Icons.close,size: 25,),

                          ),
                        ),
                        SizedBox(height: 15,),
                        Container(
                          width: double.infinity,
                          child: Text(
                            "Cancel",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red,fontSize: 12,fontWeight: FontWeight.bold
                            ),
                          ),
                        )

                      ],
                    ),
                  ),

                ),
            ),

            Positioned(
                bottom:0,
                left: 0,
                right: 0,

                child: Container(
                  height: assignDriverInfoContainerHeight,
                  decoration: BoxDecoration(
                    color: darkTheme ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text(driverRideStatus,style: TextStyle(fontWeight: FontWeight.bold),),
                        SizedBox(height: 5,),
                        Divider(thickness: 1,color: darkTheme? Colors.grey: Colors.grey.shade400,),
                        SizedBox(height: 5,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: darkTheme? Colors.lightBlueAccent : Colors.lightGreen,
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                  
                                  child: Icon(Icons.person,color: darkTheme? Colors.black : Colors.white,),
                                ),
                                
                                SizedBox(width: 10,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(driverName,style: TextStyle(fontWeight: FontWeight.bold),),
                                    Row(
                                      children: [
                                        Icon(Icons.star,color: Colors.orangeAccent,),
                                        SizedBox(width: 5,),
                                        Text("4.5",
                                        style: TextStyle(
                                          color: Colors.grey
                                        ),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),

                            Column(
                              mainAxisAlignment:MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Image.asset("images/truck.png",scale: 3,),
                                Text(driverCarDetails,style: TextStyle(fontSize: 12),)
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 5,),
                        Divider(thickness: 1,color: darkTheme? Colors.grey : Colors.grey.shade400,),

                        // ElevatedButton.icon(onPressed: onPressed, child: child)
                      ],
                    ),
                  ),
                ))



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
