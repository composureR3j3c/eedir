import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridee/AllScreens/searchScreen.dart';
import 'package:ridee/Globals/Global.dart';
import 'package:ridee/Helpers/assistantMethods.dart';
import 'package:ridee/Helpers/geofireAssistant.dart';
import 'package:ridee/Models/directDetails.dart';
import 'package:ridee/Models/nearbyAvailableDrivers.dart';
import 'package:ridee/Provider/appdata.dart';
import 'package:ridee/Widgets/Divider.dart';
import 'package:ridee/Widgets/Drawer.dart';

import '../Widgets/Colorize.dart';

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
  double requestHeight = 0;
  double searchContainerHeight = 320;

  bool searchScreen = true;
  late DirectDetails tripDirectDetails = DirectDetails();
  bool nearbyAvailableDriversKeyLoaded = false;
  Set<Marker> markerSet = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    locatePosition();
    AssistantMethods.readCurrentOnlineUserInfo();
  }

  void saveRideRequest() {
    DatabaseReference reference =
        FirebaseDatabase.instance.ref().child("Ride_Request");

    var pickup =
        Provider.of<AppData>(context, listen: false).userPickUpLocation;
    var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;

    Map pickUpLocMap = {
      "longitude": pickup?.longitude.toString(),
      "latitude": pickup?.latitude.toString(),
    };
    Map dropOffLocMap = {
      "longitude": dropOff?.longitude.toString(),
      "latitude": dropOff?.latitude.toString(),
    };

    void cancelRideRequest() {
      reference.remove();
      displaySearch();
    }

    Map rideInfoMap = {
      "driver_id": "waiting",
      "payment_method": "cash",
      "pickup": pickUpLocMap,
      "dropoff": dropOffLocMap,
      "created_at": DateTime.now().toString(),
      "rider_name": userModelCurrentInfo?.name,
      "rider_phone": userModelCurrentInfo?.phone,
      "pickup_address": pickup?.placeName,
      "dropoff_address": dropOff?.placeName
    };

    reference.push().set(rideInfoMap);
  }

  void displayRideDetail() async {
    // await getDirections();
    setState(() {
      requestHeight = 0;
      searchContainerHeight = 0;
      rideDetailContainerHeight = 550;
    });
  }

  void displaySearch() async {
    // await getDirections();
    setState(() {
      requestHeight = 0;
      searchContainerHeight = 320;
      rideDetailContainerHeight = 0;
    });
  }

  void displayRequest() async {
    // await getDirections();
    setState(() {
      requestHeight = 320;
      searchContainerHeight = 0;
      rideDetailContainerHeight = 0;
    });

    saveRideRequest();
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
        initGeofireListener();
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
            markers: markerSet,
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
                              fontSize: 20.2,
                              fontFamily: "Brand-Bold",
                              fontWeight: FontWeight.bold),
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
                                    alignment: Alignment.center,
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
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Icon(Icons.work, color: Colors.teal),
                              SizedBox(
                                width: 20.0,
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text("Add Work"),
                                    // const SizedBox(
                                    //   height: 10.0,
                                    // ),
                                    Text(
                                      "Your Office Address.",
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12.0),
                                    ),
                                  ],
                                ),
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
                              width: 20.0,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Expanded(
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
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Your Current Address.",
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12.0),
                                    ),
                                  ),
                                ],
                              ),
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
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
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
                                                  fontFamily: "Brand-Bold",
                                                  fontWeight: FontWeight.bold),
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
                                              (tripDirectDetails.distance !=
                                                      null)
                                                  ? "${tripDirectDetails.distance.toString()} Km"
                                                  : "5 km",
                                              style: TextStyle(
                                                  fontSize: 15.2,
                                                  fontFamily: "Brand-Bold",
                                                  fontWeight: FontWeight.bold),
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
                                                  ? "ETB ${AssistantMethods.calcualateFares(tripDirectDetails, "").toString()}"
                                                  : "ETB 100",
                                              style: TextStyle(
                                                  fontSize: 15.2,
                                                  fontFamily: "Brand-Bold",
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
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
                                                  fontFamily: "Brand-Bold",
                                                  fontWeight: FontWeight.bold),
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
                                              (tripDirectDetails.distance !=
                                                      null)
                                                  ? "${tripDirectDetails.distance.toString()} Km"
                                                  : "5 km",
                                              style: TextStyle(
                                                  fontSize: 15.2,
                                                  fontFamily: "Brand-Bold",
                                                  fontWeight: FontWeight.bold),
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
                                                  ? "ETB ${AssistantMethods.calcualateFares(tripDirectDetails, "lada").toString()}"
                                                  : "ETB 100",
                                              style: TextStyle(
                                                  fontSize: 15.2,
                                                  fontFamily: "Brand-Bold",
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
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
                                                  fontFamily: "Brand-Bold",
                                                  fontWeight: FontWeight.bold),
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
                                              (tripDirectDetails.distance !=
                                                      null)
                                                  ? "${tripDirectDetails.distance.toString()} Km"
                                                  : "5 km",
                                              style: TextStyle(
                                                  fontSize: 15.2,
                                                  fontFamily: "Brand-Bold",
                                                  fontWeight: FontWeight.bold),
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
                                                  ? "ETB ${AssistantMethods.calcualateFares(tripDirectDetails, "van").toString()}"
                                                  : "ETB 100",
                                              style: TextStyle(
                                                  fontSize: 15.2,
                                                  fontFamily: "Brand-Bold",
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
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
                                                  fontFamily: "Brand-Bold",
                                                  fontWeight: FontWeight.bold),
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
                                              (tripDirectDetails.distance !=
                                                      null)
                                                  ? "${tripDirectDetails.distance.toString()} Km"
                                                  : "5 km",
                                              style: TextStyle(
                                                  fontSize: 15.2,
                                                  fontFamily: "Brand-Bold",
                                                  fontWeight: FontWeight.bold),
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
                                                  ? "ETB ${AssistantMethods.calcualateFares(tripDirectDetails, "bus").toString()}"
                                                  : "ETB 100",
                                              style: TextStyle(
                                                  fontSize: 15.2,
                                                  fontFamily: "Brand-Bold",
                                                  fontWeight: FontWeight.bold),
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
                            onPressed: () {
                              setState(() {
                                displayRequest();
                              });
                            },
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
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 16.0,
                    spreadRadius: 0.4,
                    offset: Offset(1, 1),
                  )
                ],
              ),
              height: requestHeight,
              child: Column(
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Colorize(),
                  SizedBox(
                    height: 22,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        displaySearch();
                      });
                    },
                    child: CircleAvatar(
                        radius: 25.0,
                        backgroundColor: Colors.teal[300],
                        child: Icon(
                          Icons.close,
                          size: 26.0,
                          color: Colors.white,
                        )),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    "Cancel Ride",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.0),
                  )
                ],
              ),
            ),
          ),
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

  void initGeofireListener() {
    //
    Geofire.initialize("availableDrivers");
    Geofire.queryAtLocation(
            currentPosition.latitude, currentPosition.longitude, 5)
        ?.listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']
        NearbyAvailableDrivers nearbyAvailableDrivers =
            NearbyAvailableDrivers();
        nearbyAvailableDrivers.key = map['key'];
        nearbyAvailableDrivers.latitude = map['latitude'];
        nearbyAvailableDrivers.longitude = map['longitude'];
        switch (callBack) {
          case Geofire.onKeyEntered:
            GeoFireAssistant.nearbyAvailableDriversList
                .add(nearbyAvailableDrivers);
            if (nearbyAvailableDriversKeyLoaded == true) {
              updateAvailableDriversNow();
            }
            break;

          case Geofire.onKeyExited:
            GeoFireAssistant.removeDriverFromlist(map['key']);
            updateAvailableDriversNow();
            break;

          case Geofire.onKeyMoved:
            // Update your key's location
            GeoFireAssistant.updateDriverLocation(nearbyAvailableDrivers);
            updateAvailableDriversNow();
            break;

          case Geofire.onGeoQueryReady:
            // All Intial Data is loaded
            print(map['result']);

            updateAvailableDriversNow();
            break;
        }
      }

      setState(() {});
      //
    });
  }

  void updateAvailableDriversNow() {
    setState(() {
      markerSet.clear();
    });
    Set<Marker> tMarkers = Set<Marker>();
    for (NearbyAvailableDrivers driver
        in GeoFireAssistant.nearbyAvailableDriversList) {
      LatLng driverAvailableposition =
          LatLng(driver.latitude!, driver.longitude!);

      Marker marker = Marker(
          markerId: MarkerId('driver${driver.key}'),
          position: driverAvailableposition,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          rotation: AssistantMethods.createRandomNumber(360));

      tMarkers.add(marker);
    }
    setState(() {
      markerSet = tMarkers;
    });
  }
}
