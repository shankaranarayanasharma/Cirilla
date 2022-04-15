import 'package:cirilla/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:restart_app/restart_app.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_phoenix/flutter_phoenix.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String dropdownValue = 'Doral';

  late GoogleMapController mapController;

  final Set<Marker> markers = new Set();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

  }

  var cityList = ['Doral', 'Kendall', 'North Miami', 'Cooper City'];

  List<LatLng> cityLocations = <LatLng>[const LatLng(25.79658164696298, -80.34284814476236),const LatLng(25.687090520652454, -80.4032501582566),const LatLng(25.890286505845953, -80.16177118708845),const LatLng(26.055268517011935, -80.25990601773023)];




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff42210b),
      //backgroundColor: Colors.white,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fitHeight,
                        image: AssetImage(
                          'assets/images/logolocation.png',
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    "Choose Your Location",
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xffffc100),
                        fontSize: 30,
                        fontWeight: FontWeight.w600),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    height: 150,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: GoogleMap(
                            markers: getmarkers(),
                            zoomControlsEnabled: false,
                            mapType: MapType.normal,
                            myLocationEnabled: true,
                            initialCameraPosition: CameraPosition(
                              target: cityLocations[2],
                              zoom: 8
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: const Text(
                          "Choose your Preferred Location which is near by you",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w100,
                            fontFamily: 'Poppins',
                            color: Color(0xffffc100),
                            fontSize: 18,
                          ),
                        ),
                      ),


                      // getAddressWidget(
                      //     cityList[0], "2494 NW 80th Place Doral, FL 33172",['ck_6dc4952f036d16159ba9b05a961ea08bcbbc457b','cs_ccb49920c09bbca88e57a7ceaaf894732dcb8ddc']),
                      // getAddressWidget(
                      //     '', "2494 NW 80th Place Doral, FL 33172",['ck_bfe0dcdcfe2594a6805ac0881bc81e74b7f9e6a8','cs_a8094caec0330074b827a51f0839d376582e1605']),
                      getAddressWidget(
                          cityList[0], "2494 NW 80th Place Doral, FL 33172",['ck_d08c8b938107d70c21737366158696e63eef73ef','cs_f3115bb68373a883baa5fe731a55bf61258f9535']),
                      getAddressWidget(
                          cityList[1], "13021 SW 88th Street Kendall, FL 33186",['ck_2c9f1eaaa187023fdab85ba7b451f806b1cb62fb','cs_909cf12536c9b1a955cdec8bb70f6b364b33c88f']),
                      getAddressWidget(
                          cityList[2], "1821 NE 123 street North Miami, FL 33181",['ck_2785196409b3084ef7b41ddbf7c4a57e7b490d74','cs_83fbc1245f237cac5a267c85551349830a0ba573']),
                      getAddressWidget(
                          cityList[3], "10295 Stirling Rd Cooper City, FL 33328",['ck_77815084b5ad4d6acee4b9cb732fbdf80b787e6d','cs_260387f985310b9ea9735aa6887799fedac838d9']),
                      // getAddressWidget(
                      //     '', "10295 Stirling Rd Cooper City, FL 33328",['ck_a2f404d70306cfae2b52064a65c7156d190598d4','cs_e1c6601f73068da1a55265d408781e0bdae697eb']),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Set<Marker> getmarkers() {

    setState(() {
      markers.add(Marker(
        markerId: MarkerId(cityLocations[0].toString()),
        position: cityLocations[0], //position of marker
        infoWindow: const InfoWindow( //popup info
          title: 'Doral',
          snippet: '2494 NW 80th Place Doral, FL 33172',
        ), //Icon for Marker
      ));

      markers.add(Marker( //add first marker
        markerId: MarkerId(cityLocations[1].toString()),
        position: cityLocations[1], //position of marker
        infoWindow: const InfoWindow( //popup info
          title: 'Kendall',
          snippet: '13021 SW 88th Street Kendall, FL 33186',
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));

      markers.add(Marker( //add first marker
        markerId: MarkerId(cityLocations[2].toString()),
        position: cityLocations[2], //position of marker
        infoWindow: const InfoWindow( //popup info
          title: 'North Miami',
          snippet: '1821 NE 123 street North Miami, FL 33181',
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));

      markers.add(Marker( //add first marker
        markerId: MarkerId(cityLocations[3].toString()),
        position: cityLocations[3], //position of marker
        infoWindow: const InfoWindow( //popup info
          title: 'Cooper City',
          snippet: '10295 Stirling Rd Cooper City, FL 33328',
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));



      //add more markers here
    });

    return markers;
  }

  Widget getAddressWidget(String city, String address, List<String> woocommerce) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // if you need this
          side: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.fromLTRB(10,5,10,5),
          padding: const EdgeInsets.all(5),
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 4,
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(city,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                            color: Colors.black,
                            fontSize: 18,
                          )),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(address,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                            color: Colors.black,
                            fontSize: 12,
                          )),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 2,
                child: Column(
                  children: [
                    Container(
                        alignment: Alignment.centerRight,
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          height: 25,
                          minWidth: 40,
                          color: const Color(0xff42210b),
                          onPressed: () async {
                            final SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();

                            var citySelected    = sharedPreferences.getBool('firstTime');

                            if(citySelected == true)
                            {
                              sharedPreferences.remove('selectedCity');
                              sharedPreferences.remove('woocommerce_key');
                              sharedPreferences.setString(
                                  'selectedCity', city);
                              sharedPreferences.setStringList(
                                  'woocommerce_key', woocommerce);
                              Restart.restartApp();
                            }
                            else
                            {
                              sharedPreferences.setBool('firstTime', true);
                              sharedPreferences.setString(
                                  'selectedCity', city);
                              sharedPreferences.setStringList(
                                  'woocommerce_key', woocommerce);
                              Restart.restartApp();
                            }


                            // runApp(appServiceInject.getApp);


                          },
                          child: const Text(
                            'Choose',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                              color: Color(0xffffc100),
                              fontSize: 12,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget GetDropdown(String dropdownValue) {
//   return Align(
//     alignment: Alignment.center,
//     child: Container(
//       height: 50,
//       padding: const EdgeInsets.only(left: 15.0, right: 15.0),
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10.0),
//           border: Border.all(),
//           color: Colors.white),
//       child: MouseRegion(
//         cursor: SystemMouseCursors.click,
//         child: DropdownButtonHideUnderline(
//           child: DropdownButton<String>(
//             value: dropdownValue,
//             icon: const Icon(Icons.arrow_downward),
//             iconSize: 20,
//             dropdownColor: Colors.white,
//             style: const TextStyle(color: Colors.deepPurple),
//             onChanged: (String? newValue) {},
//             items: <String>['Doral', 'Kendall', 'North Miami', 'Cooper City']
//                 .map<DropdownMenuItem<String>>((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Container(
//                   width: 240,
//                   margin: const EdgeInsets.only(left: 20),
//                   child: Text(
//                     value,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w100,
//                       fontFamily: 'Poppins',
//                       color: Colors.black,
//                       fontSize: 18,
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ),
//     ),
//   );
// }
