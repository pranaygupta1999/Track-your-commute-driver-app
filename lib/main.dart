/**
 * @author Pranay Gupta
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'config.dart' ;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  var location = new Location();
  LocationData currentLocation =
      LocationData.fromMap({"latitude": 27.3303, "longitude": 37.335});
  @override
  void initState() {
    super.initState();
    initLocation();
  }

  void initLocation() async {
    super.initState();
    try {
      currentLocation = await location.getLocation();
      updateServer(currentLocation);
      location.onLocationChanged().listen((LocationData newlocation) {
        setState(() {
          currentLocation = newlocation;
          updateServer(currentLocation);
          print("locatoin updated");
          mapController.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: LatLng(
                      currentLocation.latitude, currentLocation.longitude),
                  zoom: 20)));
        });
      });
    } on PlatformException catch (e){
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
      currentLocation = null;
    }
  }

  void updateServer(LocationData data) async {
    try {
      var response = await http.post(Config.SERVER_IP+ "/location",
          body: {
            "latitude": data.latitude.toString(),
            "longitutde": data.longitude.toString()
          });
      if (response.statusCode != 200) {
        print('request failed');
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  GoogleMapController mapController;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
            target: LatLng(currentLocation.latitude, currentLocation.longitude),
            zoom: 15),
        /*markers: Set<Marker>.from([
          Marker(
              markerId: MarkerId("1"),
              position:
                  LatLng(currentLocation.latitude, currentLocation.longitude))
        ]),*/
        myLocationEnabled: true,
        
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: Text("hello"),
        icon: Icon(Icons.map),
      ),
    ));
  }
}
