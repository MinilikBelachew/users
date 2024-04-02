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

directionDetailInfo.e_points=responseDirectionApi["routes"][0]["overview_polyline"]["points"];


directionDetailInfo.distance_text=responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
directionDetailInfo.distance_value=responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];


directionDetailInfo.duration_txt=responseDirectionApi["routes"][0]["legs"][0]["durations"]["text"];
    directionDetailInfo.duration_value=responseDirectionApi["routes"][0]["legs"][0]["durations"]["value"];

    return directionDetailInfo;


}

}



























