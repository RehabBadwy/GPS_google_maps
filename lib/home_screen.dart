import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {

  static const String routeName ='home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(30.0358676,31.2012691),
    zoom: 14.4746,
  );

  static final CameraPosition routeAcademy = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(30.0358676,31.2012691),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  Set<Marker> markers = {};
  double defLat = 30.0358676;
 double defLng = 31.2012691;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserLocation();
    var userMarker =Marker(markerId: MarkerId('user_location'),
    position: LatLng(locationData?.latitude??defLat,
        locationData?.longitude??defLng)
    );
    markers.add(userMarker);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPS'),
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: markers,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: Text('To Route Academy!'),
        icon: Icon(Icons.route),
      ),
    );
  }

  Location location = new Location();

  late PermissionStatus permissionStatus;

  bool serviceEnabled =false;

  LocationData? locationData=null;

 StreamSubscription<LocationData>? locationListener=null;

 @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    locationListener?.cancel();
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(routeAcademy));
  }

  void getUserLocation()async{
   bool permGranted = await isPermissionGranted();
   if(permGranted==false) return;

   bool gpsEnable = await isServiceEnabled();
   if(gpsEnable==false) return;

   if(permGranted&&gpsEnable){
    locationData = await location.getLocation();
    print("${locationData?.latitude??0}");
    print("${locationData?.longitude??0}");

    location.changeSettings(accuracy: LocationAccuracy.high,
    interval: 1000,
      distanceFilter: 10
    );

  locationListener =  location.onLocationChanged.listen((newsLocation) {
    locationData = newsLocation;
    updateUserMarker();
      print("${locationData?.latitude??0}");
      print("${locationData?.longitude??0}");
    });
   }
  }

  void updateUserMarker()async{
    var userMarker =Marker(markerId: MarkerId('user_location'),
        position: LatLng(locationData?.latitude??defLat,
            locationData?.longitude??defLng)
    );
    markers.add(userMarker);
    setState(() {

    });
    final GoogleMapController controller = await _controller.future;
   var newCameraPosition = CameraPosition(target: LatLng(locationData?.latitude??defLat,
        locationData?.longitude??defLng),
   zoom: 19
   );
    controller.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
  }

  Future<bool> isPermissionGranted()async{
    permissionStatus = await location.hasPermission();
    if(permissionStatus==PermissionStatus.denied){
      permissionStatus = await location.requestPermission();
    }
    return permissionStatus == PermissionStatus.granted;
  }

  Future<bool> isServiceEnabled()async{
    serviceEnabled = await location.serviceEnabled();
    if(!serviceEnabled){
      serviceEnabled = await location.requestService();
    }
    return serviceEnabled;
  }
}