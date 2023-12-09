import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    home: MapLocation(),
  ));
}

class MapLocation extends StatefulWidget {
  const MapLocation({super.key});

  @override
  State<MapLocation> createState() => _MapLocationState();
}

class _MapLocationState extends State<MapLocation> {
  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(2.3232303497978815, 102.29396072202006),
    zoom: 14,
  );

  final List<Marker> myMarker = [];

  @override
  void initState() {
    super.initState();
    fetchMarkers();
     myMarker.addAll(myMarker);
    // Fetch markers when the widget initializes

    //packData();
  }


  Future<Position> getUserLocation() async{

    await Geolocator.requestPermission().then((value)
    {
      if (value == LocationPermission.denied) {
        // Handle the case where permission is not granted
        print('Location permission denied');
      }
    }).onError((error, stackTrace)
    {
      print('error $error');
    });

    return await Geolocator.getCurrentPosition();
}

    packData()
    {
      getUserLocation().then((value) async{
        print('My Location');
        print('${value.latitude} ${value.longitude}');

        myMarker.add(
          Marker(
            markerId: MarkerId('Second '),
            position: LatLng(value.latitude, value.longitude),
            infoWindow: const InfoWindow(
              title: 'My Location',
            )
          )
        );
        CameraPosition cameraPosition = CameraPosition(
          target: LatLng(value.latitude, value.longitude),
          zoom: 14,

        );

        final GoogleMapController controller = await _controller.future;

        controller .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        setState(() {

        });
      });
    }

  Future<void> fetchMarkers() async {
    final response = await http.get(Uri.parse('http://172.20.10.3/teleclinic/clinic.php'));
    if (response.statusCode == 200) {
      // Parse JSON and update markers
      final List<dynamic> data = json.decode(response.body);
      final List<Marker> markers = data.map<Marker>((dynamic item) {
        // Print clinic information to the console
        print("Clinic ID: ${item['clinicID']}");
        print("Clinic Name: ${item['clinicName']}");
        print("Latitude: ${item['latitude']}");
        print("Longitude: ${item['longitude']}");

        return Marker(
          markerId: MarkerId(item['clinicID'].toString()),
          position: LatLng(double.parse(item['latitude']), double.parse(item['longitude'])),
          infoWindow: InfoWindow(
            title: item['clinicName'],
          ),
        );
      }).toList();

      setState(() {
        myMarker.addAll(markers);
      });
    } else {
      throw Exception('Failed to load markers');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          initialCameraPosition: _initialPosition,
          mapType: MapType.normal,
          markers: Set<Marker>.of(myMarker),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child:  const Icon(Icons.location_searching),
          onPressed: ()
          {
            packData();

            },

      ),
    );
  }
}

