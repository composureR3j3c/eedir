import 'package:firebase_auth/firebase_auth.dart';

import '../Models/Users.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? userModelCurrentInfo;

// UserModel? userCurrentInfo;
String cloudMessagingServerToken =
    "key=AAAALwsK4S0:APA91bG-wA_uKsssm_gifp5JSSButlLgLsNuMMzLm_llM2LAAzhAhoXtc6oJRAkiPRggqZtuSbRpNq4vQ14TM4bs0Ff8yxY5_5GdsPUMkDWouU0PEpdpNkXTIyLxC2p7ZgAYAPvKv7lA";
String userDropOffAddress = "";
String driverCarDetails = "";
String driverName = "";
String driverPhone = "";
