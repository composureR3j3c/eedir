import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridee/Helpers/callApi.dart';
import 'package:ridee/Models/placePrediction.dart';
import 'package:ridee/Widgets/Divider.dart';

import '../Provider/appdata.dart';
import '../Widgets/PredictionTile.dart';
import 'configMaps.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();
  List<PlacePredictions> placesPredictionList = [];
  @override
  Widget build(BuildContext context) {
    String? placeAddress =
        Provider.of<AppData>(context).userPickUpLocation != null
            ? (Provider.of<AppData>(context).userPickUpLocation?.placeName!)
            : "";
    // String placeAddress = "";
    pickUpTextEditingController.text = placeAddress!;

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 255,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.teal,
                  blurRadius: 6.0,
                  spreadRadius: 0.4,
                  offset: Offset(1, 1),
                )
              ],
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 50.0,
                  ),
                  Stack(
                    children: [
                      GestureDetector(
                        child: Icon(
                          Icons.arrow_back,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      Center(
                          child: Text(
                        "Set Drop Off",
                        style:
                            TextStyle(fontSize: 18.0, fontFamily: "Brand-Bold"),
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        "images/pickicon.png",
                        height: 28.0,
                        width: 28.0,
                      ),
                      SizedBox(
                        width: 15.0,
                      ),
                      Expanded(
                          child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(5.0)),
                        child: Padding(
                          padding: EdgeInsets.all(3.0),
                          child: TextField(
                            controller: pickUpTextEditingController,
                            decoration: InputDecoration(
                              hintText: "Pickup Loction",
                              fillColor: Colors.grey[200],
                              filled: true,
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.only(
                                  right: 11.0,
                                  left: 11.0,
                                  top: 8.0,
                                  bottom: 8.0),
                            ),
                          ),
                        ),
                      ))
                    ],
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        "images/desticon.png",
                        height: 28.0,
                        width: 28.0,
                      ),
                      SizedBox(
                        width: 15.0,
                      ),
                      Expanded(
                          child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(5.0)),
                        child: Padding(
                          padding: EdgeInsets.all(3.0),
                          child: TextField(
                            onChanged: (val) => findPlace(val),
                            controller: dropOffTextEditingController,
                            decoration: InputDecoration(
                              hintText: "Where To?",
                              fillColor: Colors.grey[200],
                              filled: true,
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.only(
                                  right: 11.0,
                                  left: 11.0,
                                  top: 8.0,
                                  bottom: 8.0),
                            ),
                          ),
                        ),
                      ))
                    ],
                  )
                ],
              ),
            ),
          ),
          (placesPredictionList.length > 0)
              ? Expanded(
                  child: ListView.separated(
                    itemBuilder: (context, index) => PredictionTile(
                      placePredictions: placesPredictionList[index],
                    ),
                    separatorBuilder: (BuildContext context, int Index) =>
                        DividerWidget(),
                    itemCount: placesPredictionList.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  void findPlace(String Placename) async {
    if (Placename.length > 1) {
      String apiUrl =
          "https://api.geoapify.com/v1/geocode/autocomplete?text=$Placename&format=json&filter=countrycode:et&circle:-38.763611,9.005401,1&apiKey=$geopify";

      var res = await RequestAssistant.receiveRequest(apiUrl);
      if (res == "Error Occurred, Failed. No Response.") {
        return;
      } else
      // if (res["status"] == "OK")
      {
        print(res["results"]);
        var predictions = res["results"];
        var placeList = (predictions as List)
            .map((e) => PlacePredictions.fromJson(e))
            .toList();
        setState(() {
          placesPredictionList = placeList;
        });
      }
    }
  }
}
