import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridee/Helpers/assistantMethods.dart';
import 'package:ridee/Provider/appdata.dart';
import 'package:ridee/Widgets/Divider.dart';
import 'package:ridee/Widgets/Drawer.dart';
import 'package:geolocator/geolocator.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController newGoogleMapController;
  static final CameraPosition _kinit = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  late Position currentPosition;
  var geoLocator = Geolocator();
  late LocationPermission permission;
  double bottomPadding=0;

  void locatePosition() async{
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {

      }
      else if (permission == LocationPermission.deniedForever) {

      }
      else{
        Position position =await Geolocator.
        getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        currentPosition= position;

        LatLng latLngPosition=LatLng(position.latitude, position.longitude);

        CameraPosition cameraPosition=new CameraPosition(target: latLngPosition,zoom: 14.4746,);
        newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        String address = await AssistantMethods.searchAddressForGeographicCoOrdinates(position, context);
        print("address##############");
        print(address);
        setState(() {
          bottomPadding=300.0;
        });
      }
    }


  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Main Screen"),
      ),
      drawer: DrawerWidget(),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPadding),
            initialCameraPosition: _kinit,
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              newGoogleMapController = controller;

              locatePosition();
            },
          ),
          Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: Container(
                height: 320.0,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18.0),
                        topRight: Radius.circular(18.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 16.0,
                        spreadRadius: 0.8,
                        offset: Offset(1, 1),
                      )
                    ]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 23.0, vertical: 17.5),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5.0,
                      ),

                      Text(
                        "Hi, hope you're doing well!",
                        style: TextStyle(fontSize: 12.2),
                      ),
                      Text(
                        "Where to?",
                        style:
                        TextStyle(fontSize: 20.2, fontFamily: "Brand-Bold"),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 6.0,
                                spreadRadius: 0.4,
                                offset: Offset(1, 1),
                              )
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(children: [
                            Icon(Icons.search, color: Colors.teal),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text("Search Destination."),
                          ]),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        children: [
                          Icon(Icons.work, color: Colors.teal),
                          SizedBox(
                            width: 10.0,
                          ),
                          Column(
                            children: [
                              Text("Add Work"),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                "Your Office Address.",
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 12.0),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(
                        height: 10.0,
                      ),
                      DividerWidget(),
                      SizedBox(height: 16.0,),
                      Row(
                        children: [
                          Icon(Icons.home, color: Colors.teal),
                          SizedBox(
                            width: 10.0,
                          ),
                          Column(
                            children: [
                              Text(  Provider.of<AppData>(context).userPickUpLocation != null
                                  ? (Provider.of<AppData>(context).userPickUpLocation!.placeName!): "Add Home"),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                "Your Home Address.",
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 12.0),
                              ),
                            ],
                          ),
                        ],
                      ),

                    ],

                  ),
                ),
              ))
        ],
      ),
    );
  }
}
