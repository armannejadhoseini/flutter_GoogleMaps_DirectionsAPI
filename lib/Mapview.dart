import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_application_2/nethelper.dart';

class Mapview extends StatefulWidget {
  @override
  _MapviewState createState() => _MapviewState();
}

class _MapviewState extends State<Mapview> {
  @override
  void initState() {
    super.initState();
    getlocate();
  }

  Completer<GoogleMapController> _controller = Completer();

  Position position;
  LatLng location;

  final List<LatLng> polyPoints = [];
  final Set<Polyline> polyLines = {};

  var data;

  double startLat;
  double startLng;
  double endLat;
  double endLng;
  double distance;
  double price;

  String totaldistance;
  String price2;

  Set<Marker> markers = Set();

  CameraPosition defaultposition =
      CameraPosition(target: LatLng(35.715298, 51.404343), zoom: 15);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Map"),
        centerTitle: true,
      ),
      body: GoogleMap(
        initialCameraPosition: defaultposition,
        mapType: MapType.normal,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        compassEnabled: true,
        markers: markers,
        polylines: polyLines,
        onTap: (latlng) {
          markermaker(latlng);
          startLat = position.latitude;
          startLng = position.longitude;
          endLat = latlng.latitude;
          endLng = latlng.longitude;
        },
        onLongPress: (latlng) {
          Navigator.pushReplacementNamed(context, '/');
        },
        onMapCreated: (GoogleMapController controller) async {
          if (await Permission.locationAlways.request().isGranted) {
            print('granted');
          }
          _controller.complete(controller);

          controller.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 15)));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          distance =
              Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
          totaldistance = distance.toStringAsFixed(0);
          price = distance * .01;
          price2 = price.toStringAsFixed(1);
          _showMyDialog();
        },
        label: Icon(Icons.near_me),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Future<void> getlocate() async {
    position = await Geolocator.getCurrentPosition();
  }

  void markermaker(LatLng location) {
    Position position1 =
        Position(latitude: location.latitude, longitude: location.longitude);

    Marker resultMarker = Marker(
      markerId: MarkerId('home'),
      infoWindow: InfoWindow(),
      position: LatLng(position1.latitude, position1.longitude),
    );

    setState(() {
      markers.add(resultMarker);
    });
  }

  void getJsonData() async {
    NetworkHelper network = NetworkHelper(
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
    );

    try {
      data = await network.getData();

      LineString ls =
          LineString(data['features'][0]['geometry']['coordinates']);

      for (int i = 0; i < ls.lineString.length; i++) {
        polyPoints.add(LatLng(ls.lineString[i][1], ls.lineString[i][0]));
      }
      setPolyLines();
    } catch (e) {
      print(e);
    }
  }

  setPolyLines() {
    Polyline polyline = Polyline(
      polylineId: PolylineId("polyline"),
      color: Colors.blue,
      points: polyPoints,
    );

    setState(() {
      polyLines.add(polyline);
    });
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Navigate to ... '),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Your Total distance is : $totaldistance Meters \nAnd Costs : $price2 Dollars \nWould you like to navigate to the selected location ?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Navigate'),
              onPressed: () {
                polyPoints.clear();
                polyLines.clear();
                getJsonData();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class LineString {
  LineString(this.lineString);
  List<dynamic> lineString;
}
