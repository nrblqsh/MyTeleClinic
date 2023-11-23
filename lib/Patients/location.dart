import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    home: Location(),
  ));
}

class Location extends StatefulWidget {

  const Location({super.key});

  @override
  State<Location> createState() => _LocationState();
}
class _LocationState extends State<Location> {
  Completer<GoogleMapController> _googleMapController = Completer();
  CameraPosition? _cameraPosition;

  @override
  void initState() {
    super.initState();
    _init(); // Call _init() to initialize _cameraPosition
  }

  _init() {
    _cameraPosition = CameraPosition(
      target: LatLng(11.576262, 1004.92222),
      zoom: 15,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return _getMap();
  }

  Widget _getMarker(){
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0,3),
            spreadRadius: 4,
            blurRadius: 6
          )
        ]
      ),

    );
  }
  Widget _getMap() {
    // Check if _cameraPosition is not null before using it
    return Stack(
      children: [
        GoogleMap(initialCameraPosition: _cameraPosition!,
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller) {
            if (!_googleMapController.isCompleted) {
              _googleMapController.complete(controller);
            }
          },
        ),
        Positioned.fill(
            child: Align(
              alignment: Alignment.center,
                child: _getMarker()
        )
        )
      ],
    );
  }
}
