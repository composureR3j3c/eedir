import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridee/Provider/appdata.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  TextEditingController pickUpTextEditingController= TextEditingController();
  TextEditingController dropOffTextEditingController= TextEditingController();
  @override
  Widget build(BuildContext context) {

    String placeAddress= Provider.of<AppData>(context).userPickUpLocation!.placeName ?? "";
    pickUpTextEditingController.text=placeAddress;


    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 6.0,
                    spreadRadius: 0.4,
                    offset: Offset(1, 1),
                  )

                ],

            ),
            child: Column(
              children: [
                SizedBox(
                  height: 5.0,
                ),
                Stack(
                  children: [
                    GestureDetector(child: Icon(Icons.arrow_back),
                    onTap: (){Navigator.pop(context);},),
                    Text("Set Drop Off",style: TextStyle(fontSize: 18.0,fontFamily: "Brand-Bold"),),
                  ],
                ),
                SizedBox(
                  height: 16.0,
                ),
                Row(
                  children: [
                    Image.network("https://icons.veryicon.com/png/o/system/star-and-home-distribution-system-management/pick-up-point-management.png",
                    height:16.0,
                      width: 16.0,
                    ),
                    SizedBox(
                      height: 18.0,
                    ),
                    Expanded(child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(5.0)
                        ),
                      child: Padding(
                        padding: EdgeInsets.all(3.0),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Pickup Loction",
                            fillColor: Colors.grey[400],
                            filled: true,
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.only(left: 11.0,top: 8.0,bottom: 8.0),
                                                      ),
                        ),
                      ),
                    ))
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
