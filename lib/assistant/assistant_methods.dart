import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:users/assistant/assistant_request.dart';
import 'package:users/global/global.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:users/models/directions.dart';
import 'package:users/models/user_models.dart';

import '../info_mnager/info_app.dart';
import '../models/direction_detail_info.dart';





class AssistantMethods {
  static void readCurrentUser() async{
    currentUser=firebaseAuth.currentUser;
    DatabaseReference userRef=FirebaseDatabase.instance
    .ref()
    .child("users").child(currentUser!.uid);
    userRef.once().then((value) {
      if(value.snapshot.value != null){
        userModelCurrentInfo = UserModel.fromSnapshot(value.snapshot);
      }
    });
  }
  // Future<String> searchAddressForGeographicCoordinate(Position position, BuildContext context) async {
  //   String apiUrl = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=';
  //   String humanReadableAddress = '';
  //
  //   try {
  //     // Make request to Google Places API
  //     final response = await http.get(Uri.parse('$apiUrl&key=$apiKey'));
  //
  //     if (response.statusCode == 200) {
  //       final decodedResponse = json.decode(response.body);
  //
  //       if (decodedResponse['status'] == 'OK') {
  //         final result = decodedResponse['result'];
  //         humanReadableAddress = result['formatted_address'];
  //
  //         Directions userPickUpAddress = Directions(
  //           locationLatitude: position.latitude,
  //           locationLongitude: position.longitude,
  //           locationName: humanReadableAddress,
  //         );
  //
  //         Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
  //       }
  //     } else {
  //       throw Exception('Failed to retrieve address');
  //     }
  //   } catch (error) {
  //     print('Error: $error');
  //   }
  //
  //   return humanReadableAddress;
  // }
static Future<String>searchAddressForGeographicCoordinate(Position position ,context) async {
    String apiUrl= "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey";
    String humanReadableAddress="";
    var requestResponse= await RequestAssistant.receiveRequest(apiUrl);



    if(requestResponse!= "Error Occured,No Response"){
      humanReadableAddress = requestResponse["results"]["0"]["formated_address"];

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude=position.latitude;
      userPickUpAddress.locationLongitude=position.longitude;
      userPickUpAddress.locationName=humanReadableAddress;


       Provider.of<AppInfo>(context,listen: false).updatePickUpLocationAddress(userPickUpAddress);

    }
    return humanReadableAddress;


}

static Future<DirectionDetailInfo> obtainOriginToDestinationDirectionDetails(LatLng originPosition,LatLng destinationPosition)async{

    String urlOriginToDestinationDirectionDetails= "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$apiKey";
var responseDirectionApi =await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);

// if(responseDirectionApi =="Error Occured,No Response") {
//   return null
// }
DirectionDetailInfo directionDetailInfo=DirectionDetailInfo();

  if (responseDirectionApi["routes"].isNotEmpty) {
    directionDetailInfo.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    if (responseDirectionApi["routes"][0]["legs"].isNotEmpty) {
      directionDetailInfo.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
      directionDetailInfo.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

      directionDetailInfo.duration_txt = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
      directionDetailInfo.duration_value = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];
    }
  }

    return directionDetailInfo;


}
  static double caculateFareAmountFromOriginToDestination(DirectionDetailInfo? directionDetailInfo) {
    if (directionDetailInfo == null || directionDetailInfo.duration_value == null || directionDetailInfo.distance_value == null) {
      // Handle the case where directionDetailInfo or its properties are null
      return 0.0; // Or any default value you prefer
    }

    double timeTravelFareAmountPerMinute = (directionDetailInfo.duration_value! / 60) * 0.1;
    double distanceTraveledFareAmountPerKilometer = (directionDetailInfo.distance_value! / 100) * 0.1;

    //ETB
    double totalPrice = timeTravelFareAmountPerMinute + distanceTraveledFareAmountPerKilometer;

    return double.parse(totalPrice.toStringAsFixed(1));
  }

// static double caculateFareAmountFromOriginToDestination(DirectionDetailInfo directionDetailInfo) {
//     double timeTravelFareAmountPerMinute= (directionDetailInfo.duration_value! / 60) * 0.1;
//     double distanceTraveledFareAmountPerKilometer= (directionDetailInfo.distance_value!/100) * 0.1;
//
//
//     //ETB
//   double totalPrice= timeTravelFareAmountPerMinute + distanceTraveledFareAmountPerKilometer;
//
//   return double.parse(totalPrice.toStringAsFixed(1));
//
// }
  // static Future<void> sendNotificationToDriverNow(String deviceRegistrationToken, String userRideRequestId, String userDropOffAddress) async {
  //   String destinationAddress = userDropOffAddress;
  //   Map<String, String> headerNotification = {
  //     'Content-Type': 'application/json',
  //     "Authorization": cloudMessagingServerToken,
  //   };
  //   Map<String, String> bodyNotification = {
  //     "body": "Destination Address :\n$destinationAddress",
  //     "title": "New Trip Request"
  //   };
  //
  //   Map<String, String> dataMap = {
  //     "click_action": "FLUTTER_NOTIFICATION_CLICK",
  //     "id": "1",
  //     "status": "done",
  //     "rideRequestId": userRideRequestId // Corrected the typo here
  //   };
  //
  //   Map<String, dynamic> officialNotificationFormat = {
  //     "notification": bodyNotification,
  //     "data": dataMap,
  //     "priority": "high",
  //     "to": deviceRegistrationToken
  //   };
  //
  //   try {
  //     var response = await http.post(
  //       Uri.parse("https://fcm.googleapis.com/fcm/send"),
  //       headers: headerNotification,
  //       body: jsonEncode(officialNotificationFormat),
  //     );
  //     if (response.statusCode == 200) {
  //       // Notification sent successfully
  //       print("Notification sent successfully");
  //     } else {
  //       // Handle error
  //       print("Failed to send notification. Status code: ${response.statusCode}");
  //     }
  //   } catch (error) {
  //     // Handle error
  //     print("Error sending notification: $error");
  //   }
  // }


static sendNotificationToDriverNow(String deviceRegistrationToken,String userRideRequestId,context) async {
    String destinationAddress=userDropOffAddress;
    Map <String ,String> headerNotification={
      'Content-Type': 'application/json',
      "Authorization":cloudMessagingServerToken,

    };
    Map bodyNotification={
      "body":"Destination Address : \n$destinationAddress",
      "title":"New Trip Request"
    };

    Map dataMap={
      "click_action":"FLUTTER_NOTIFICATION_CLICK",
      "id":"1",
      "status":"done",
      "reideRequestId":userRideRequestId
    };

    Map officialNotificationFormat={
      "notification":bodyNotification,
      "data":dataMap,
      "priority":"high",
      "to":deviceRegistrationToken

    };

    var responseNotification=http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormat),
  );

}


}



























