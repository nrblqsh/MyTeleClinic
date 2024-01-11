import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:my_teleclinic/Patients/Map/view_clinic_specialist.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Main/main.dart';


//import '../Main/main.dart';

void main() {
  runApp(const MaterialApp(
    home: MapLocation(),
  ));
}

class MapLocation extends StatefulWidget {
  const MapLocation({Key? key}) : super(key: key);

  @override
  State<MapLocation> createState() => _MapLocationState();
}

class _MapLocationState extends State<MapLocation> {

  String? distance;
  String? duration;

  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(2.3232303497978815, 102.29396072202006),
    zoom: 14,
  );

  final List<Marker> myMarker = [];
  Map<PolylineId, Polyline> polylines = {};
  Position? userLocation; // Declare userLocation at a higher scope
  final TextEditingController _searchController = TextEditingController();
  List<String> suggestions = [];

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

  Future<List<LatLng>> getDirections(
      LatLng origin, LatLng destination, String travelMode) async {
    final apiKey = 'AIzaSyBayQdqPuNJaYbS5vOd_ij7WsQdyPojKsk';
    final apiUrl =
        'https://maps.googleapis.com/maps/api/directions/json?'
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
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue),
          ),
        );
        CameraPosition cameraPosition = CameraPosition(
          target: LatLng(userLocation!.latitude, userLocation!.longitude),
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
      final response = await http.get(
          Uri.parse('http://${MyApp.ipAddress}${MyApp.clinicPath}'));

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
              snippet: 'Phone: ${item['phone']}\n',
            ),
            onTap: () {
              // Handle tap on the marker's InfoWindow
              print('Marker tapped: ${item['clinicName']}');
             showDistanceAndDuration(item);
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


  Future<void> openInMaps(String latitude, String longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }


  Widget buildDialog(dynamic item) => Container(
    height: 200,
    child: Dialog(
      insetPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['clinicName'],
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        '· ${item['phone']}                 ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: 25),
                      Text(
                        '· ${item['clinicType']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                      ),

                      if (distance != null && duration != null)
                        SizedBox(height: 30,),
                      Row(
                        children: [
                          // Car icon next to distance
                          Row(
                            children: [
                              Icon(Icons.directions_car, size: 20, color: Colors.blue),
                              SizedBox(width: 7),
                              Text(
                                distance!,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                            ],
                          ),
                          SizedBox(width:240), // Add some spacing between distance and duration
                          // Clock icon next to duration
                          Row(
                            children: [
                              SizedBox(width: 15),
                              Icon(Icons.access_time, size: 20, color: Colors.green),
                              SizedBox(width: 10), // Add some spacing
                              Text(
                                duration!,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                            ],
                          ),
                        ],
                      )

                    ],
                  ),
                ),
                Divider(),
                ElevatedButton(
                  onPressed: () {
                    handleNavigation(item);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    backgroundColor: Color(hexColor('C73B3B')),
                    fixedSize:
                    Size.fromHeight(45), // Adjust the height as needed
                  ),
                  child: Text(
                    'Navigate to this Clinic',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  height: 45,
                  width: 145,
                  child: ElevatedButton(
                    onPressed: () {
                      openInMaps(item['latitude'], item['longitude']);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      backgroundColor: Color(hexColor('7393B3')),
                      fixedSize: Size.fromHeight(45),
                    ),
                    child: Text(
                      'Open in Maps',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 45,
                  width: 145,
                  child: ElevatedButton(
                    onPressed: () async{
                      final SharedPreferences pref = await SharedPreferences.getInstance();
                      await pref.setInt("clinicID", int.parse(item['clinicID']));
                      print('Tapped on clinic: ${item['clinicID']}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => viewClinicSpecialistScreen(patientID:0, clinicID: 0,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      backgroundColor: Color(hexColor('7393B3')),
                      fixedSize: Size.fromHeight(35),
                    ),
                    child: Text(
                      'Make Appointment',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),

              ],
            ),

            Positioned(
              top: 30.0,
              right: 8.0,
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
  );

  Future<void> fetchDistanceAndDuration(LatLng destination) async {
    if (userLocation != null) {
      final result = await getDistanceAndDuration(
        LatLng(userLocation!.latitude, userLocation!.longitude),
        destination,
      );

      setState(() {
        distance = result['distance'];
        duration = result['duration'];
      });
    }
  }

  Future<void> showDistanceAndDuration(dynamic item) async {
    double destinationLat = double.parse(item['latitude']);
    double destinationLng = double.parse(item['longitude']);

    print(
      'Calculating distance and duration to ${item['clinicName']}'
          ' from current location to ($destinationLat, $destinationLng)',
    );

    // Fetch distance and duration
    final result = await getDistanceAndDuration(
      LatLng(userLocation!.latitude, userLocation!.longitude),
      LatLng(destinationLat, destinationLng),
    );

    setState(() {
      distance = result['distance'];
      duration = result['duration'];
    });

    // Now show the dialog with distance and duration
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return buildDialog(item);
      },
    );
  }


  Future<void> handleNavigation(dynamic item) async {
    if (userLocation != null) {
      double destinationLat = double.parse(item['latitude']);
      double destinationLng = double.parse(item['longitude']);

      print(
        'Navigate to ${item['clinicName']}'
            ' from current location to ($destinationLat, $destinationLng)',
      );

      // Call fetchDistanceAndDuration here with the destination
      await fetchDistanceAndDuration(LatLng(destinationLat, destinationLng));

      // Fetch directions
      final polylineCoordinates = await getDirections(
        LatLng(userLocation!.latitude, userLocation!.longitude),
        LatLng(destinationLat, destinationLng),
        'driving',
      );

      if (polylineCoordinates.isNotEmpty) {
        drawPolyline(polylineCoordinates);
      } else {
        print('No polyline coordinates received');
      }

      closeDialog();
    }
  }

  void clearPolylines() {
    setState(() {
      polylines.clear();
    });
  }

  void moveToClinic(String clinicName) {
    for (Marker marker in myMarker) {
      if (marker.infoWindow.title == clinicName) {
        _controller.future.then((controller) {
          controller.animateCamera(CameraUpdate.newLatLng(marker.position));
        });

        _searchController.clear();
        suggestions.clear();
        return;
      }
    }
  }

  void closeDialog() {
    Navigator.of(context).pop();
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


  Future<Map<String, String>> getDistanceAndDuration(
      LatLng origin, LatLng destination) async {
    final apiKey = 'AIzaSyBayQdqPuNJaYbS5vOd_ij7WsQdyPojKsk';
    final apiUrl =
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}&'
        'destination=${destination.latitude},${destination.longitude}&'
        'mode=driving&key=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);

      if (decodedData['status'] == 'OK') {
        final List<dynamic> routes = decodedData['routes'];
        if (routes.isNotEmpty) {
          final List<dynamic> legs = routes[0]['legs'];
          if (legs.isNotEmpty) {
            final Map<String, String> result = {
              'distance': legs[0]['distance']['text'],
              'duration': legs[0]['duration']['text'],
            };
            return result;
          }
        }
      }
    }

    print('Failed to fetch distance and duration');
    return {};
  }


  Future<void> searchClinics(String query) async {
    final response = await http.get(
      Uri.parse('http://${MyApp.ipAddress}${MyApp.clinicPath}?q=$query'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<Marker> searchedMarkers = data.map<Marker>((dynamic item) {
        return Marker(
          markerId: MarkerId(item['clinicID'].toString()),
          position: LatLng(
              double.parse(item['latitude']),
              double.parse(item['longitude'])),
          infoWindow: InfoWindow(
            title: item['clinicName'],
            snippet: 'Phone: ${item['phone']}\n',
          ),
          onTap: () {
            // Handle tap on the marker's InfoWindow
            print('Marker tapped: ${item['clinicName']}');
            showDistanceAndDuration(item);

          },
        );
      }).toList();

      setState(() {
        myMarker.clear();
        myMarker.addAll(searchedMarkers);
      });
    } else {
      print('Failed to fetch search results');
    }
  }

  Future<void> updateSuggestions(String query) async {
    final response = await http.get(
      Uri.parse('http://${MyApp.ipAddress}${MyApp.clinicPath}/suggestions?q=$query'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<String> clinicNames = data.map<String>((dynamic item) {
        return item['clinicName'] as String;
      }).toList();

      setState(() {
        suggestions = clinicNames;

        searchClinics(query);
      });
    } else {
      print('Failed to fetch search suggestions');
    }
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
            onTap: (_) {
              // Clear polylines when tapping on the map
              //clearPolylines();
            },
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              height: 53,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
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
                      controller: _searchController,
                      onChanged: (query) {
                        updateSuggestions(query);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search Clinic..',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        fillColor: Colors.white70,
                        filled: true,
                        hintStyle: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (suggestions.isNotEmpty)
            Positioned(
              top: 95,
              left: 10,
              right: 10,
              child: Card(
                elevation: 5,
                child: Column(
                  children: [
                    for (String suggestion in suggestions)
                      ListTile(
                        title: Text(suggestion),
                        onTap: () async {
                          setState(() {
                            _searchController.text = suggestion;
                          });
                          // Search clinics based on the selected suggestion
                          await searchClinics(suggestion);
                          moveToClinic(suggestion);
                        },
                      ),


                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.location_searching),
        onPressed: () async {
          packData();
          clearPolylines();
          // Fetch all markers
          fetchMarkers();
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,

    );
  }
}

int hexColor(String color) {
  String newColor = '0xff' + color;
  newColor = newColor.replaceAll('#', '');
  int finalColor = int.parse(newColor);
  return finalColor;
}
