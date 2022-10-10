import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridee/AllScreens/searchScreen.dart';
import 'package:ridee/Helpers/assistantMethods.dart';
import 'package:ridee/Models/directDetails.dart';
import 'package:ridee/Provider/appdata.dart';
import 'package:ridee/Widgets/Divider.dart';
import 'package:ridee/Widgets/Drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
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
  double bottomPadding = 0;
  double rideDetailContainerHeight = 0;
  double searchContainerHeight = 320;

  late DirectDetails tripDirectDetails;

  void displayRideDetail() async {
    // await getDirections();
    setState(() {
      searchContainerHeight = 0;
      rideDetailContainerHeight = 230;
    });
  }

  void locatePosition() async {
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
      } else if (permission == LocationPermission.deniedForever) {
      } else {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        currentPosition = position;

        LatLng latLngPosition = LatLng(position.latitude, position.longitude);

        CameraPosition cameraPosition = new CameraPosition(
          target: latLngPosition,
          zoom: 14.4746,
        );
        newGoogleMapController
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        final address =
            await AssistantMethods.searchAddressForGeographicCoOrdinates(
                position, context);
        print("address##############");
        print(address);
        setState(() {
          bottomPadding = 300.0;
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
            onCameraMove: (position) {
              locatePosition();
            },
          ),
          Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: AnimatedSize(
                curve: Curves.bounceIn,
                duration: new Duration(milliseconds: 160),
                child: Container(
                  height: searchContainerHeight,
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
                          style: TextStyle(
                              fontSize: 20.2, fontFamily: "Brand-Bold"),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        GestureDetector(
                          onTap: () async {
                            var res = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchScreen()));
                            if (res == "obtainDirection") {
                              await getPlaceDirections();
                              displayRideDetail();
                            }
                          },
                          child: Container(
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
                        SizedBox(
                          height: 16.0,
                        ),
                        Row(
                          children: [
                            Icon(Icons.home, color: Colors.teal),
                            SizedBox(
                              width: 10.0,
                            ),
                            Column(
                              children: [
                                Text(Provider.of<AppData>(context)
                                            .userPickUpLocation !=
                                        null
                                    ? (Provider.of<AppData>(context)
                                        .userPickUpLocation!
                                        .placeName!)
                                    : "Add Home"),
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
                ),
              )),
          Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: AnimatedSize(
                curve: Curves.bounceIn,
                duration: new Duration(milliseconds: 160),
                child: Container(
                  height: rideDetailContainerHeight,
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
                    padding: const EdgeInsets.symmetric(vertical: 17.5),
                    child: Column(
                      children: [
                        Container(
                          color: Colors.amber[500],
                          width: double.infinity,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                Image.asset(
                                  "images/taxi.png",
                                  height: 70.0,
                                  width: 80.0,
                                ),
                                SizedBox(
                                  height: 16.0,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      "Car",
                                      style: TextStyle(
                                          fontSize: 18.2,
                                          fontFamily: "Brand-Bold"),
                                    ),
                                    Text(
                                      (tripDirectDetails != null)
                                          ? tripDirectDetails.distance
                                              .toString()
                                          : "5km",
                                      style: TextStyle(
                                          fontSize: 18.2,
                                          fontFamily: "Brand-Bold"),
                                    ),
                                    Expanded(
                                        child: Container(
                                      child: Text((tripDirectDetails != null)
                                          ? AssistantMethods.calcualateFares(
                                                  tripDirectDetails)
                                              .toString()
                                          : ""),
                                    ))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.moneyBill1,
                                color: Colors.black54,
                              ),
                              SizedBox(
                                width: 16.0,
                              ),
                              Text("Cash"),
                              SizedBox(
                                height: 6.0,
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.black54,
                                size: 16.0,
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: ElevatedButton(
                            // color: Theme.of(context).teal,
                            onPressed: () {},
                            child: Padding(
                              padding: EdgeInsets.all(17.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Request",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(FontAwesomeIcons.taxi,
                                      color: Colors.white, size: 26.0)
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Future<void> getPlaceDirections() async {
    var initialPosition =
        Provider.of<AppData>(context, listen: false).userPickUpLocation;
    var finalPosition =
        Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickupLatlng =
        LatLng(initialPosition!.latitude!, initialPosition!.longitude!);
    var dropOffLatlng =
        LatLng(finalPosition!.latitude!, finalPosition!.longitude!);

    // showDialog(context: context, builder: (BuildContext context)=>ProgressDialog(type:ProgressDialogType.Normal).style(message: "Please Wait...")  }

    var details =
        await AssistantMethods.obtainDirection(pickupLatlng, dropOffLatlng);
    setState(() {
      tripDirectDetails = details;
    });
    // Navigator.pop(context);
  }
}
