import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridee/Globals/Global.dart';
import 'package:ridee/Models/Users.dart';
import 'package:ridee/Models/address.dart';
import 'package:ridee/Models/directDetails.dart';

import '../Globals/configMaps.dart';
import '../Provider/appdata.dart';
import 'callApi.dart';

import 'package:http/http.dart' as http;

class AssistantMethods {
  static Future<dynamic> searchAddressForGeographicCoOrdinates(
      Position position, context) async {
    // String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position
    //     .latitude},${position.longitude}&key=$mapKey";

    String apiUrl =
        "https://api.geoapify.com/v1/geocode/reverse?lat=${position.latitude}&lon=${position.longitude}&apiKey=$geopify";
    // String humanReadableAddress = "";
    String? geofyHumanReadableAddress = "";

    final requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    // print("requestResponse"+requestResponse);
    if (requestResponse != "Error Occurred, Failed. No Response.") {
      // humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      String? name = requestResponse["features"][0]["properties"]["name"] ?? "";
      ;
      geofyHumanReadableAddress =
          requestResponse["features"][0]["properties"]["road"] ?? "";
      String? street =
          requestResponse["features"][0]["properties"]["county"] ?? "";
      String? city =
          requestResponse["features"][0]["properties"]["state"] ?? "";
      String? country =
          requestResponse["features"][0]["properties"]["country"] ?? "";

      geofyHumanReadableAddress = geofyHumanReadableAddress! +
          " " +
          name! +
          ", " +
          street! +
          ", " +
          city! +
          ", " +
          country! +
          ".";
      print(
          " #####geofyHumanReadableAddress##### " + geofyHumanReadableAddress);
      //
      Address userPickUpAddress = Address();
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.placeName = geofyHumanReadableAddress;
      print(" #####userPickUpAddress##### " + userPickUpAddress.placeName!);
      //
      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }

    return geofyHumanReadableAddress;
  }

  static Future<dynamic> searchAutoComplete(Position position, context) async {
    String place = "";
    String apiUrl =
        "https://api.geoapify.com/v1/geocode/autocomplete?text=$place&format=json&filter=countrycode:et&circle:-38.763611,9.005401,1&apiKey=$geopify";
  }

  static Future<DirectDetails?> obtainDirection(
      LatLng initialPos, LatLng finalPos) async {
    String apiUrl =
        "https://api.geoapify.com/v1/routing?waypoints=${initialPos.latitude},${initialPos.longitude}|${finalPos.latitude},${finalPos.longitude}&mode=drive&details=route_details&apiKey=$geopify";

    final requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    print("###URL###");
    print(apiUrl);
    if (requestResponse != "Error Occurred, Failed. No Response.") {
      DirectDetails directDetails = DirectDetails();

      directDetails.distance =
          (requestResponse["features"][0]["properties"]["distance"] / 1000)
              .truncate();
      print("####distance####");

      directDetails.time = requestResponse["features"][0]["properties"]["time"];
      print(directDetails.distance);
      return directDetails;
    } else {
      return null;
    }
  }

  static int calcualateFares(DirectDetails directDetails, String? type) {
    double Fare = directDetails.distance! * 18 + 100;
    if (type == "lada") {
      Fare = directDetails.distance! * 12 + 100;
    } else if (type == "bus") {
      Fare = directDetails.distance! * 25 + 100;
    } else if (type == "van") {
      Fare = directDetails.distance! * 20 + 100;
    }
    return Fare.truncate();
  }

  static void readCurrentOnlineUserInfo() async {
    currentFirebaseUser = fAuth.currentUser;

    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentFirebaseUser!.uid);

    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }

  // static void getCurrentOnlineUserInfo() async {
  //   currentFirebaseUser = fAuth.currentUser;
  //   String userId = currentFirebaseUser!.uid;

  //   DatabaseReference reference =
  //       FirebaseDatabase.instance.ref().child("users").child(userId);

  //   reference.once().then((dataSnapshot) {
  //     if (dataSnapshot.snapshot.value != null) {
  //       userCurrentInfo = UserModel.fromSnapshot(dataSnapshot.snapshot);
  //     }
  //   });
  // }

  static double createRandomNumber(int num) {
    var random = Random();

    return (random.nextInt(num).toDouble());
  }

  static sendNotificationToDriverNow(
      String deviceRegistrationToken, String userRideRequestId, context) async {
    String destinationAddress = userDropOffAddress;

    Map<String, String> headerNotification = {
      'Content-Type': 'application/json',
      'Authorization': cloudMessagingServerToken,
    };

    Map bodyNotification = {
      "body": "Destination Address: \n$destinationAddress.",
      "title": "New Trip Request"
    };

    Map dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "rideRequestId": userRideRequestId
    };

    Map officialNotificationFormat = {
      "notification": bodyNotification,
      "data": dataMap,
      "priority": "high",
      "to": deviceRegistrationToken,
    };

    var responseNotification = http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormat),
    );
  }
}
