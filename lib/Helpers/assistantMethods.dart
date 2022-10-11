import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridee/Models/address.dart';
import 'package:ridee/Models/directDetails.dart';

import '../AllScreens/configMaps.dart';
import '../Provider/appdata.dart';
import 'callApi.dart';

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
        "https://api.geoapify.com/v1/routing?waypoints=$initialPos|$finalPos&mode=drive&details=route_details&apiKey=$geopify";

    final requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if (requestResponse != "Error Occurred, Failed. No Response.") {
      DirectDetails directDetails = DirectDetails();

      directDetails.distance =
          requestResponse["features"][0]["properties"]["distance"];
      directDetails.time = requestResponse["features"][0]["properties"]["time"];

      return directDetails;
    }
    else{
      return null;
    }
  }

  static int calcualateFares(DirectDetails directDetails) {
    double Fare = directDetails.distance! / 100;
    return Fare.truncate();
  }
}
