import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:ridee/Models/address.dart';

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
}
