import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsFlutterDesign extends StatefulWidget {
  const GoogleMapsFlutterDesign({super.key});

  @override
  State<GoogleMapsFlutterDesign> createState() =>
      _GoogleMapsFlutterDesignState();
}

class _GoogleMapsFlutterDesignState extends State<GoogleMapsFlutterDesign> {
  //  Completer is a class that is used to produce the future object and to complete them later with a value or an error

  final Completer<GoogleMapController> _controller =

      /// Controller for a single GoogleMap instance running on the host platform.

      Completer<GoogleMapController>();

  /// The position of the map "camera", the view point from which the world is shown in the map view.

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

//  A pair of latitude and longitude coordinates, stored as degrees.

  LatLng latLng = LatLng(37.42796133580664, -122.085749655962);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Google Maps Flutter",
        ),
        centerTitle: true,
      ),
      body: Center(
        //   Google map is a flutter widget used to display the map on the screen
        child: GoogleMap(
          //  Map type is the display of the map on the screen
          // . A MapType is an interface that defines the display and usage of map tiles and the translation of coordinate systems from screen coordinates to world coordinates (on the map).
          mapType: MapType.hybrid,
          markers: {
            //  marker's are used to mark the geographical location on the map
            Marker(markerId: MarkerId("madni"), position: latLng)
          },
          //  The position of the map "camera", the view point from which the world is shown in the map view.

          // Aggregates the camera's target geographical location, its zoom level, tilt angle, and bearing.
          // initial camera position mean's that the display of the camera location on the screen when the mao start's

          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToTheLake,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    //  controller . future is used to fetch the value of the controller in future
    final GoogleMapController controller = await _controller.future;
    //  Position class is used to fetch the position of the given value

    Position position = await _determinePosition();
    //   The position of the map "camera", the view point from which the world is shown in the map view.

    CameraPosition currentLocation = CameraPosition(
        //  The camera's bearing in degrees, measured clockwise from north.
        bearing: 192.8334901395799,
        //  The geographical location that the camera is pointing at.

        target: LatLng(position.latitude, position.longitude),
        //  The angle, in degrees, of the camera angle from the nadir.

        tilt: 0,
        //  The zoom level of the camera.

        zoom: 19.151926040649414);
    latLng = LatLng(position.latitude, position.longitude);
    setState(() {});
    //  Geo co ordinates is a class that is used to allow for the conversation between the address and the geographical co ordinates
    //   A service for converting between an address and a LatLng.
    GeoCode geoCode = GeoCode();

    try {
      //   Address class is used to work with the address of the location
      // Here we used to covert the latitude and longitude into the Address

      Address address =
          //   reverse geo coding  is used to  convert the given longitude and the latitude into the Address of that place

          await geoCode.reverseGeocoding(
              latitude: position.latitude, longitude: position.longitude);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(address.streetAddress.toString() +
              address.city.toString() +
              "steet number ${address.streetNumber}")));
    } catch (e) {
      print(e);
    }
    await controller
        //   animate camera is used to animate the camera from the old position to the new position
        .animateCamera(
            // Defines a camera move, supporting absolute moves as well as moves relative the current position.

            CameraUpdate.newCameraPosition(currentLocation));
  }

//   Determine position function is made to the current location of the user
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    /// Returns a [Future] containing a [bool] value indicating whether location
    /// services are enabled on the device.
    //  Used to check whether the location of the device is on or off at that time
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please turn on your location")));
    }

//   request permission is used to request the user to turn on the location of the device to fetch the current location of the user
    permission = await Geolocator.requestPermission();

//   get current position is used to fetch the current position of the user
    return await Geolocator.getCurrentPosition();
  }
}
