import 'package:firebase_auth/firebase_auth.dart';
import '../Models/Users.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? userModelCurrentInfo;

// UserModel? userCurrentInfo;
