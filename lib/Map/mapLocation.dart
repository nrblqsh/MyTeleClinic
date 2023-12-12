import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';


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

  Future<List<LatLng>> getDirections(LatLng origin, LatLng destination, String travelMode) async {
    final apiKey = 'AIzaSyBayQdqPuNJaYbS5vOd_ij7WsQdyPojKsk';
    final apiUrl = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}&'
        'destination=${destination.latitude},${destination.longitude}&'
        'mode=$travelMode&key=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);

      print('Decoded Data: $decodedData');

      if (decodedData['status'] == 'OK') {
        final List<dynamic> routes = decodedData['routes'];
        if (routes.isNotEmpty) {
          final List<dynamic> legs = routes[0]['legs'];
          if (legs.isNotEmpty) {
            final List<dynamic> steps = legs[0]['steps'];
            if (steps.isNotEmpty) {
              final List<LatLng> polylineCoordinates = [];

              for (final step in steps) {
                final String points = step['polyline']['points'];
                final List<PointLatLng> decodedPoints =
                PolylinePoints().decodePolyline(points);

                // Convert PointLatLng to LatLng
                final List<LatLng> convertedPoints = decodedPoints
                    .map((point) => LatLng(point.latitude, point.longitude))
                    .toList();

                polylineCoordinates.addAll(convertedPoints);
              }

              print('Polyline Coordinates: $polylineCoordinates');

              return polylineCoordinates;
            }
          }
        }
      }
    }

    print('No valid response received');
    return [];
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
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), // Set the marker color to blue

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

                            getDirections(
                              LatLng(userLocation!.latitude, userLocation!.longitude),
                              LatLng(destinationLat, destinationLng),
                              'driving',
                            ).then((polylineCoordinates) {
                              if (polylineCoordinates.isNotEmpty) {
                                drawPolyline(polylineCoordinates);
                              } else {
                                print('No polyline coordinates received');
                              }
                            });



                            // drawPolyline(
                            //   LatLng(
                            //       userLocation!.latitude,
                            //       userLocation!.longitude),
                            //   LatLng(destinationLat, destinationLng),
                            // );

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

  void drawPolyline(List<LatLng> polylineCoordinates) {
    clearPolylines();

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
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