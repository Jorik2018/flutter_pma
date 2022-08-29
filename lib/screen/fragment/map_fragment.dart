import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:registration_login/screen/fragment/zoombuttons_plugin_option.dart';

class MapFragment extends StatefulWidget {

  Map? options;

  MapFragment({this.options});

    @override
    _MapFragmentState createState() => new _MapFragmentState();
}

class _MapFragmentState extends State<MapFragment> {
    @override
    Widget build(BuildContext context) {
      double lat=widget.options!['lat']??0;
      double lon=widget.options!['lon']??0;
        return new Scaffold(
           appBar: new AppBar(
                title: new Text('Localizacion de Vivenda de Niño'),
               // elevation: defaultTargetPlatform== TargetPlatform.android?5.0:0.0,
            ),
            body:Column(
                children: [
                    Flexible(
                        child: FlutterMap(
                            options: MapOptions(
                                center: LatLng(lat, lon),
                                zoom: 9.2,
                            ),
                            layers: [
                                TileLayerOptions(
                                    urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                                    userAgentPackageName: 'com.example.app',
                                ),
                                MarkerLayerOptions(
                                    markers: [
                                        Marker(
                                          point: LatLng(lat,lon),
                                          width: 40,
                                          height: 40,
                                          builder: (context) => FlutterLogo(),
                                        ),
                                    ],
                                ),
                            ],
                            nonRotatedChildren: [
                              
                  FlutterMapZoomButtons(
                    minZoom: 4,
                    maxZoom: 19,
                    mini: true,
                    padding: 10,
                    alignment: Alignment.bottomRight,
                  ),
                                AttributionWidget.defaultWidget(
                                    source: 'OpenStreetMap contributors',
                                    onSourceTapped: null,
                                ),
                            ],
                        )
                    ),
                ],
            ),
        );
    }
}