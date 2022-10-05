import 'package:flutter/foundation.dart';
import 'package:ridee/Models/address.dart';

class AppData extends ChangeNotifier{
  Address? userPickUpLocation;


  void updatePickUpLocationAddress(Address userPickUpAddress)
  {
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }
}