import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as locator;
import 'package:provider/provider.dart';

import '../assistant/assistant_methods.dart';
import '../global/global.dart';
import '../info_mnager/info_app.dart';
import '../models/directions.dart';

class PrecisePickUpScreen extends StatefulWidget {
  const PrecisePickUpScreen({super.key});

  @override
  State<PrecisePickUpScreen> createState() => _PrecisePickUpScreenState();
}

class _PrecisePickUpScreenState extends State<PrecisePickUpScreen> {
  LatLng? pickLocation;

  String? _address;

  //loc.Location location=loc.Location();

  locator.Location location = locator.Location();

  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();

  GoogleMapController? _newGoogleMapController;
  Position? userCurrentPosition;
  double bottomPaddinMap = 0;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.reduced);
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
  }

  getAddressFromLatLng() async {
    try {
      GeoData data = await Geocoder2.getDataFromCoordinates(
          latitude: pickLocation!.latitude,
          longitude: pickLocation!.longitude,
          googleMapApiKey: apiKey);
      setState(() {
        Directions userPickUpAddress = Directions();
        userPickUpAddress.locationLatitude = pickLocation!.latitude;
        userPickUpAddress.locationLongitude = pickLocation!.longitude;
        userPickUpAddress.locationName = data.address;

        Provider.of<AppInfo>(context, listen: false)
            .updatePickUpLocationAddress(userPickUpAddress);

        // _address = data.address;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kGooglePlex,
            mapType: MapType.normal,
            zoomControlsEnabled: true,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              _newGoogleMapController = controller;

              // locateUserPosition();

              setState(() {
                bottomPaddinMap=100;
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
              getAddressFromLatLng();
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 60,bottom: 35),
              child: Image.asset(
                "images/location-pointer.png",
                height: 30,
                width: 30,
              ),
            ),
          ),
          Positioned(
             top: 40,
            right: 20,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.pink,
              ),
              padding: const EdgeInsets.all(20), // Corrected spelling: EdgeInsets.all(20)
              child:
              Text(
                Provider.of<AppInfo>(context).userPickUpLocation != null && Provider.of<AppInfo>(context).userPickUpLocation!.locationName != null
                    ? "${Provider.of<AppInfo>(context).userPickUpLocation!.locationName!}..."
                    : "Not Getting Address",
                overflow: TextOverflow.visible,
                softWrap: true,
                style: TextStyle(color: Colors.brown, fontSize: 14),
              ),


              // Text(
              //   Provider.of<AppInfo>(context).userPickUpLocation!= null
              //   ? "${(Provider.of<AppInfo> (context).userPickUpLocation!.locationName!).substring(0,24)}..."
              //   : "Not Getting Address",
              //
              //
              //   overflow: TextOverflow.visible,
              //   softWrap: true,
              //   // Corrected spelling: softWrap
              // ),
            ),
          ),

          Positioned(
            bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
            padding: const EdgeInsets.all(12),

                child: ElevatedButton(
                  onPressed: (){
                  Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkTheme ? Colors.amberAccent : Colors.blueAccent,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    )

                  ),
                  child: const Text("Set current Location"),

                ),
          ))
        ],
      ),
    );
  }
}
