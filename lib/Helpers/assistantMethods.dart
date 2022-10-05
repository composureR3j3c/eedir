import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:ridee/Models/address.dart';

import '../AllScreens/configMaps.dart';
import '../Provider/appdata.dart';
import 'callApi.dart';

class AssistantMethods {
  static Future<String> searchAddressForGeographicCoOrdinates(Position position,
      context) async
  {
    // String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position
    //     .latitude},${position.longitude}&key=$mapKey";

    String apiUrl = "https://api.geoapify.com/v1/geocode/reverse?lat=${position.latitude}&lon=${position.longitude}&apiKey=$geopify";
    String humanReadableAddress = "";
    dynamic geofyHumanReadableAddress = "";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    print("requestResponse"+requestResponse);
    if (requestResponse != "Error Occurred, Failed. No Response.") {
      // humanReadableAddress = requestResponse["results"][0]["formatted_address"];
      geofyHumanReadableAddress = requestResponse["type"];
      // geofyHumanReadableAddress = requestResponse["features"][0]["properties"]["name"];
      print(" #####geofyHumanReadableAddress##### "+geofyHumanReadableAddress);
      //
      Address userPickUpAddress = Address();
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.placeName = geofyHumanReadableAddress;
      //
      Provider.of<AppData>(context, listen: false).updatePickUpLocationAddress(
          userPickUpAddress);
    }

    return humanReadableAddress;
  }

}