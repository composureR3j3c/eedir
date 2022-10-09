class PlacePredictions {
  String? secondaryText;
  String? mainText;
  String? placeId;
  String? lat;
  String? lon;

  PlacePredictions(
      {this.secondaryText, this.mainText, this.placeId, this.lat, this.lon});
  PlacePredictions.fromJson(Map<String, dynamic> json) {
    placeId = json["place_id"];
    mainText = json["address_line1"];
    secondaryText = json["address_line2"];
    lat = json["lat"];
    lon = json["lon"];
  }
}
