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
  Map<PolylineId, Polyline> polylines = {};
  Position? userLocation; // Declare userLocation at a higher scope

  @override
  void initState() {
    super.initState();
    fetchMarkers();
    packData();
  }

  Future<void> getUserLocation() async {
    await Geolocator.requestPermission().then((value) {
      if (value == LocationPermission.denied) {
        print('Location permission denied');
      }
    }).onError((error, stackTrace) {
      print('error $error');
    });

    userLocation = await Geolocator.getCurrentPosition();
  }

  void packData() {
    getUserLocation().then((_) async {
      if (userLocation != null) {
        print('My Location');
        print('${userLocation!.latitude} ${userLocation!.longitude}');

        myMarker.add(
          Marker(
            markerId: MarkerId('Second '),
            position:
            LatLng(userLocation!.latitude, userLocation!.longitude),
            infoWindow: const InfoWindow(
              title: 'My Location',
            ),
          ),
        );
        CameraPosition cameraPosition = CameraPosition(
          target:
          LatLng(userLocation!.latitude, userLocation!.longitude),
          zoom: 14,
        );

        final GoogleMapController controller = await _controller.future;

        controller.animateCamera(
            CameraUpdate.newCameraPosition(cameraPosition));
        setState(() {});
      }
    });
  }

  Future<void> fetchMarkers() async {
    try {
      final response =
      await http.get(Uri.parse('http://192.168.8.186/teleclinic/clinic.php'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Marker> markers = data.map<Marker>((dynamic item) {
          return Marker(
            markerId: MarkerId(item['clinicID'].toString()),
            position: LatLng(
                double.parse(item['latitude']),
                double.parse(item['longitude'])),
            infoWindow: InfoWindow(
              title: item['clinicName'],
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Navigate to ${item['clinicName']}?'),
                    content: Text(
                        'Do you want to navigate to this clinic from your current location?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('No'),
                      ),
                      TextButton(
                        onPressed: () {
                          if (userLocation != null) {
                            double destinationLat =
                            double.parse(item['latitude']);
                            double destinationLng =
                            double.parse(item['longitude']);

                            print(
                                'Navigate to ${item['clinicName']}'
                                    ' from current location to ($destinationLat,'
                                    ' $destinationLng)');

                            drawPolyline(
                              LatLng(
                                  userLocation!.latitude,
                                  userLocation!.longitude),
                              LatLng(destinationLat, destinationLng),
                            );

                            Navigator.of(context).pop();
                          }
                        },
                        child: Text('Yes'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        }).toList();

        setState(() {
          myMarker.addAll(markers);
        });
      } else {
        print('HTTP request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching markers: $e');
    }
  }

  void clearPolylines() {
    //clear polyline ..
    setState(() {
      polylines.clear();
    });
  }

  void drawPolyline(LatLng origin, LatLng destination) {
    clearPolylines();

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      points: [origin, destination],
      color: Colors.blue,
      width: 5,
    );

    setState(() {
      polylines[id] = polyline;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            mapType: MapType.normal,
            markers: Set<Marker>.of(myMarker),
            polylines: Set<Polyline>.of(polylines.values),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Positioned(
            top:10,
            left: 0,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              height: 53,
              decoration: BoxDecoration(

                // Set the background color with opacity
                borderRadius: BorderRadius.circular(
                    20.0), // Set the border radius
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black), // Set the border color
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        fillColor: Colors.transparent,
                        // Set the background color of the text field
                        filled: false,
                      ),
                      // Handle the onChanged or onSubmitted callback as needed
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.location_searching),
        onPressed: () {
          packData();
        },
      ),
    );
  }
}