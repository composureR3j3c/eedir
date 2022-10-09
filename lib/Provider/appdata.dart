import 'package:flutter/foundation.dart';
import 'package:ridee/Models/address.dart';

class AppData extends ChangeNotifier {
  Address? userPickUpLocation, dropOffLocation;

  void updatePickUpLocationAddress(Address userPickUpAddress) {
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocation(Address userPickUpAddress) {
    dropOffLocation = dropOffLocation;
    notifyListeners();
  }
}
