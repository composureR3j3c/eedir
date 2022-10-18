import 'package:ridee/Models/nearbyAvailableDrivers.dart';

class GeoFireAssistant {
  static List<NearbyAvailableDrivers> nearbyAvailableDriversList = [];

  static void removeDriverFromlist(String key) {
    int index =
        nearbyAvailableDriversList.indexWhere((element) => key == element.key);
    nearbyAvailableDriversList.removeAt(index);
  }

  static void updateDriverLocation(NearbyAvailableDrivers drivers) {
    int index = nearbyAvailableDriversList
        .indexWhere((element) => drivers.key == element.key);
    nearbyAvailableDriversList[index].longitude = drivers.longitude;
    nearbyAvailableDriversList[index].longitude = drivers.latitude;
  }
}
