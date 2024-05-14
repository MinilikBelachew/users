import 'package:firebase_auth/firebase_auth.dart';
import 'package:users/models/direction_detail_info.dart';

import '../models/user_models.dart';

FirebaseAuth firebaseAuth=FirebaseAuth.instance;
User? currentUser;
UserModel? userModelCurrentInfo;
String apiKey="AIzaSyAleDgZbox33LEXbNbOFjEf9duUA1rjyTA";


DirectionDetailInfo? tripDirectionDetailInfo;
String userDropOffAddress='';

String cloudMessagingServerToken="key=AAAAL552R4g:APA91bGqgQq9KVtNS-mrLTnhaL05kMK331B6SeCIfvstvYbCTAQc9205QO7MyNRsAFxnVBVZNEfIPz5hVqA6s16sU8jT2dXPYSzYnFV4mdVvDHnkshuhJQHJP2WDxeW65fTtgMgG_xlv";

String driverCarDetails="";
String driverName="";
String driverPhone="";

double countRatingStars=0.0;
String titleStarRating="";
List driversList=[];

