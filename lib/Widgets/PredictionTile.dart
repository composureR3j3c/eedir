import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridee/Globals/Global.dart';
import 'package:ridee/Models/address.dart';
import 'package:ridee/Models/placePrediction.dart';
import 'package:ridee/Provider/appdata.dart';

class PredictionTile extends StatefulWidget {
  final PlacePredictions placePredictions;
  PredictionTile({required this.placePredictions});

  @override
  State<PredictionTile> createState() => _PredictionTileState();
}

class _PredictionTileState extends State<PredictionTile> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        setDropOff(widget.placePredictions, context);
      },
      child: Container(
        child: Column(
          children: [
            SizedBox(
              width: 10.0,
            ),
            SizedBox(
              width: 14.0,
            ),
            Row(
              children: [
                SizedBox(
                  width: 15.0,
                ),
                Icon(
                  Icons.add_location,
                  color: Colors.red,
                  size: 50,
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                    child: Column(
                  children: [
                    SizedBox(
                      width: 8.0,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.placePredictions.mainText ?? "",
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 16.0, color: Colors.black),
                      ),
                    ),
                    SizedBox(
                      width: 2.0,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.placePredictions.secondaryText ?? "",
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 13.0, color: Colors.black45),
                      ),
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                  ],
                ))
              ],
            ),
            SizedBox(
              width: 14.0,
            ),
          ],
        ),
      ),
    );
  }

  void setDropOff(PlacePredictions placePredictions, BuildContext context) {
    // showDialog(
    //     context: context,
    //     builder: (BuildContext context) => AlertDialog(
    //           content: Container(
    //             child: Text("Setting DropOff, Please wait..."),
    //           ),
    //         ));

    Address address = Address();
    address.latitude = placePredictions.lat as double?;
    address.longitude = placePredictions.lon as double?;
    address.placeName = placePredictions.mainText;

    Provider.of<AppData>(context, listen: false).updateDropOffLocation(address);
    print("#####drop off #####");
    print(address.latitude);

    setState(() {
      userDropOffAddress = placePredictions.mainText!;
    });
    Navigator.pop(context, "obtainDirection");
  }
}
