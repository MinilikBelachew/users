import 'package:firebase_auth/firebase_auth.dart';
import 'package:users/models/direction_detail_info.dart';

import '../models/user_models.dart';

FirebaseAuth firebaseAuth=FirebaseAuth.instance;
User? currentUser;
UserModel? userModelCurrentInfo;
String apiKey="AIzaSyDvDTif2c7C7KrltE0s4JvQ0RmEw0DG5ZU";


DirectionDetailInfo? tripDirectionDetailInfo;
String userDropOffAddress='';

