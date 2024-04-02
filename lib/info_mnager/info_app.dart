import 'package:flutter/cupertino.dart';
import 'package:users/models/directions.dart';

class AppInfo extends ChangeNotifier{
  Directions? userPickUpLocation, userDropoffLocation;
  int countTotalTrips=0;
 // List<String> historyTripskeyList=[];
 // List<TripsHistoryModel> allTripsHistoryInformationList=[];
  void updatePickUpLocationAddress(Directions userPickUpAddress){
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions dropOffAddress){
    userDropoffLocation = dropOffAddress;
    notifyListeners();
  }
}