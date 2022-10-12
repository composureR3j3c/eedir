import 'dart:async';

import 'package:flutter/cupertino.dart';
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
      target: LatLng(9.005401, 38.763611),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  late Position currentPosition;
  var geoLocator = Geolocator();
  late LocationPermission permission;
  double bottomPadding = 0;
  double rideDetailContainerHeight = 0;
  double searchContainerHeight = 320;

  bool searchScreen = true;
  late DirectDetails tripDirectDetails = DirectDetails();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    locatePosition();
  }
  void displayRideDetail() async {
    // await getDirections();
    setState(() {
      searchContainerHeight = 0;
      rideDetailContainerHeight = 550;
    });
  }

  void displaySearch() async {
    // await getDirections();
    setState(() {
      searchContainerHeight = 320;
      rideDetailContainerHeight = 0;
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
        title: Text(""),
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
          // (searchScreen == true)
          //     ?
          Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: AnimatedSize(
                curve: Curves.bounceIn,
                duration: new Duration(milliseconds: 160),
                child: Container(
                  width: double.infinity,
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
                              fontSize: 20.2, fontFamily: "Brand-Bold", fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: GestureDetector(
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
                                  color: Colors.teal,
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
                                padding: const EdgeInsets.all(15.0),
                                child: Row(children: [
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Icon(Icons.search,
                                      color: Colors.white, size: 35),
                                  SizedBox(
                                    width: 20.0,
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Search Destination",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 21.0,
                                      ),
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Icon(Icons.work, color: Colors.teal),
                              SizedBox(
                                width: 10.0,
                              ),
                              Column(
                                children: [
                                  Text("Add Work"),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                      "Your Office Address.",
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12.0),
                                    ),

                                ],
                              ),
                            ],
                          ),
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
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    Provider.of<AppData>(context)
                                                .userPickUpLocation !=
                                            null
                                        ? (Provider.of<AppData>(context)
                                            .userPickUpLocation!
                                            .placeName!)
                                        : "Add Current Location",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Your Current Address.",
                                    style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12.0),
                                  ),
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
                duration: const Duration(milliseconds: 10),
                child: Container(
                  height: rideDetailContainerHeight,
                  width: double.infinity,
                  decoration: const BoxDecoration(
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
                        SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: Column(
                            children: [Container(
                              decoration:
                              BoxDecoration(color: Colors.white, boxShadow: [
                                BoxShadow(
                                  color: Colors.white12,
                                  blurRadius: 1,
                                  spreadRadius: 0.8,
                                  offset: Offset(0.2, 0.2),
                                )
                              ]),
                              // color: Colors.amber,
                              width: double.infinity,
                              child: Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20.0,
                                    ),
                                    Image.asset(
                                      "images/taxi.png",
                                      height: 70.0,
                                      width: 80.0,
                                    ),
                                    SizedBox(
                                      height: 16.0,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 20.0,
                                        ),
                                        CircleAvatar(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black,
                                          radius: 25,
                                          child: Text(
                                            "Any Car",
                                            style: TextStyle(
                                                fontSize: 12.2,
                                                fontFamily: "Brand-Bold", fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20.0,
                                        ),
                                        CircleAvatar(
                                          backgroundColor: Colors.white12,
                                          foregroundColor: Colors.black,
                                          radius: 30,
                                          child: Text(
                                            (tripDirectDetails.distance != null)
                                                ? "${tripDirectDetails.distance
                                                .toString()} Km"
                                                :
                                            "5 km",
                                            style: TextStyle(
                                                fontSize: 15.2,
                                                fontFamily: "Brand-Bold", fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20.0,
                                        ),
                                        CircleAvatar(
                                          backgroundColor: Colors.white12,
                                          foregroundColor: Colors.black,
                                          radius: 35,
                                          child: Text(
                                            tripDirectDetails.distance != null
                                                ? "ETB ${AssistantMethods.calcualateFares(tripDirectDetails).toString()}"
                                                :
                                            "ETB 100",
                                            style: TextStyle(
                                                fontSize: 15.2,
                                                fontFamily: "Brand-Bold", fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                              Container(
                                decoration:
                                BoxDecoration(color: Colors.white, boxShadow: [
                                  BoxShadow(
                                    color: Colors.white12,
                                    blurRadius: 1,
                                    spreadRadius: 0.8,
                                    offset: Offset(0.2, 0.2),
                                  )
                                ]),
                                // color: Colors.amber,
                                width: double.infinity,
                                child: Padding(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 20.0,
                                      ),
                                      Image.asset(
                                        "images/logo.png",
                                        height: 70.0,
                                        width: 80.0,
                                      ),
                                      SizedBox(
                                        height: 16.0,
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 20.0,
                                          ),
                                          CircleAvatar(
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.black,
                                            radius: 25,
                                            child: Text(
                                              "Lada",
                                              style: TextStyle(
                                                  fontSize: 12.2,
                                                  fontFamily: "Brand-Bold", fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 20.0,
                                          ),
                                          CircleAvatar(
                                            backgroundColor: Colors.white12,
                                            foregroundColor: Colors.black,
                                            radius: 30,
                                            child: Text(
                                              (tripDirectDetails.distance != null)
                                                  ? "${tripDirectDetails.distance
                                                  .toString()} Km"
                                                  :
                                              "5 km",
                                              style: TextStyle(
                                                  fontSize: 15.2,
                                                  fontFamily: "Brand-Bold", fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 20.0,
                                          ),
                                          CircleAvatar(
                                            backgroundColor: Colors.white12,
                                            foregroundColor: Colors.black,
                                            radius: 35,
                                            child: Text(
                                              tripDirectDetails.distance != null
                                                  ? "ETB ${AssistantMethods.calcualateFares(tripDirectDetails).toString()}"
                                                  :
                                              "ETB 100",
                                              style: TextStyle(
                                                  fontSize: 15.2,
                                                  fontFamily: "Brand-Bold", fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                decoration:
                                BoxDecoration(color: Colors.white, boxShadow: [
                                  BoxShadow(
                                    color: Colors.white10,
                                    blurRadius: 1,
                                    spreadRadius: 0.8,
                                    offset: Offset(0.2, 0.2),
                                  )
                                ]),
                                // color: Colors.amber,
                                width: double.infinity,
                                child: Padding(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 20.0,
                                      ),
                                      Image.asset(
                                        "images/automoblie.png",
                                        height: 70.0,
                                        width: 80.0,
                                      ),
                                      SizedBox(
                                        height: 16.0,
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 20.0,
                                          ),
                                          CircleAvatar(
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.black,
                                            radius: 25,
                                            child: Text(
                                              "Minivan",
                                              style: TextStyle(
                                                  fontSize: 12.2,
                                                  fontFamily: "Brand-Bold", fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 20.0,
                                          ),
                                          CircleAvatar(
                                            backgroundColor: Colors.white12,
                                            foregroundColor: Colors.black,
                                            radius: 30,
                                            child: Text(
                                              (tripDirectDetails.distance != null)
                                                  ? "${tripDirectDetails.distance
                                                  .toString()} Km"
                                                  :
                                              "5 km",
                                              style: TextStyle(
                                                  fontSize: 15.2,
                                                  fontFamily: "Brand-Bold", fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 20.0,
                                          ),
                                          CircleAvatar(
                                            backgroundColor: Colors.white12,
                                            foregroundColor: Colors.black,
                                            radius: 35,
                                            child: Text(
                                              tripDirectDetails.distance != null
                                                  ? "ETB ${AssistantMethods.calcualateFares(tripDirectDetails).toString()}"
                                                  :
                                              "ETB 100",
                                              style: TextStyle(
                                                  fontSize: 15.2,
                                                  fontFamily: "Brand-Bold", fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                decoration:
                                BoxDecoration(color: Colors.white, boxShadow: [
                                  BoxShadow(
                                    color: Colors.white12,
                                    blurRadius: 1,
                                    spreadRadius: 0.8,
                                    offset: Offset(0.2, 0.2),
                                  )
                                ]),
                                // color: Colors.amber,
                                width: double.infinity,
                                child: Padding(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 20.0,
                                      ),
                                      Image.asset(
                                        "images/minibus.png",
                                        height: 70.0,
                                        width: 80.0,
                                      ),
                                      SizedBox(
                                        height: 16.0,
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 20.0,
                                          ),
                                          CircleAvatar(
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.black,
                                            radius: 25,
                                            child: Text(
                                              "Minibus",
                                              style: TextStyle(
                                                  fontSize: 12.2,
                                                  fontFamily: "Brand-Bold", fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 20.0,
                                          ),
                                          CircleAvatar(
                                            backgroundColor: Colors.white12,
                                            foregroundColor: Colors.black,
                                            radius: 30,
                                            child: Text(
                                              (tripDirectDetails.distance != null)
                                                  ? "${tripDirectDetails.distance
                                                  .toString()} Km"
                                                  :
                                              "5 km",
                                              style: TextStyle(
                                                  fontSize: 15.2,
                                                  fontFamily: "Brand-Bold", fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 20.0,
                                          ),
                                          CircleAvatar(
                                            backgroundColor: Colors.white12,
                                            foregroundColor: Colors.black,
                                            radius: 35,
                                            child: Text(
                                              tripDirectDetails.distance != null
                                                  ? "ETB ${AssistantMethods.calcualateFares(tripDirectDetails).toString()}"
                                                  :
                                              "ETB 100",
                                              style: TextStyle(
                                                  fontSize: 15.2,
                                                  fontFamily: "Brand-Bold", fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
                          padding: EdgeInsets.symmetric(horizontal: 50.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.teal,
                              // backgroundColor: Colors.cyan
                            ),
                            // color: Theme.ofdecoration: BoxDecoration(
                            //                       color: Colors.white,
                            //                       borderRadius: BorderRadius.only(
                            //                           topLeft: Radius.circular(18.0),
                            //                           topRight: Radius.circular(18.0)),
                            //                       boxShadow: [
                            //                         BoxShadow(
                            //                           color: Colors.black,
                            //                           blurRadius: 16.0,
                            //                           spreadRadius: 0.8,
                            //                           offset: Offset(1, 1),
                            //                         )
                            //                       ]),(context).teal,
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
                                      color: Colors.white, size: 26.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 50.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red[800],
                              // backgroundColor: Colors.cyan
                            ),
                            onPressed: () {
                              setState(() {
                                displaySearch();
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.all(17.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Back",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(FontAwesomeIcons.undo,
                                      color: Colors.white, size: 26.0),
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

    print("####locations####");
    print(initialPosition);
    var pickupLatlng =
        LatLng(initialPosition!.latitude!, initialPosition.longitude!);
    var dropOffLatlng =
        LatLng(finalPosition!.latitude!, finalPosition.longitude!);

    // showDialog(context: context, builder: (BuildContext context)=>ProgressDialog(type:ProgressDialogType.Normal).style(message: "Please Wait...")  }

    var details =
        await AssistantMethods.obtainDirection(pickupLatlng, dropOffLatlng);
    setState(() {
      tripDirectDetails = details!;
    });
    // Navigator.pop(context);
  }
}
