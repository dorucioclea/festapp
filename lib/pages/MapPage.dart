import 'package:av_app/services/DataService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'dart:math';

class MarkerWithText extends Marker {
  final String title;
  final String description;

  MarkerWithText({
    required LatLng point,
    required WidgetBuilder builder,
    Key? key,
    double width = 30.0,
    double height = 30.0,
    bool? rotate,
    Offset? rotateOrigin,
    AlignmentGeometry? rotateAlignment,
    AnchorPos<dynamic>? anchorPos,
    required this.title,
    required this.description,
  }) : super(
          point: point,
          builder: builder,
          key: key,
          width: width,
          height: height,
          rotate: rotate,
          rotateOrigin: rotateOrigin,
          rotateAlignment: rotateAlignment,
          anchorPos: anchorPos,
        );
}

class MapPage extends StatefulWidget {
  static const route = 'MapPage';

  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final List<MarkerWithText> _markers = [];

  /// Used to trigger showing/hiding of popups.
  final PopupController _popupLayerController = PopupController();

  @override
  void initState() {
    super.initState();
    loadPlaces();
  }

  Random random = Random();

  double demorandom() {
    // TODO: remove this function. It's a temporary fix because all the in the
    // database have the same coordinates
    // or uncomment:
    // return 0;
    return random.nextDouble() / 100;
  }

  Map<String, Image> type2icon_map = {
    // TODO: put the final versions of icons to assets/icons dir and rewrite
    "kavárna, čajovna": const Image(image: AssetImage('icons/coffee-shop.png')),
    "bankomat": const Image(image: AssetImage('icons/atm.png')),
    "kostel, kaple": const Image(image: AssetImage('icons/chapel.png')),
    "kostel": const Image(image: AssetImage('icons/chapel.png')),
    "sport": const Image(image: AssetImage('icons/football.png')),
// church - kostel/kaple
// coffee - kavárna
// wine - vinárna
// reception - recepce
// food - jídlo
// sport - sport
// accomodation - ubytování
// cross - kříž
// other - jiné'
  };

  Widget type2icon(String place_type) {
    if (type2icon_map.containsKey(place_type)) {
      return type2icon_map[place_type]!;
    }

    return const Icon(Icons.location_on);
  }

  Future<void> loadPlaces() async {
    var markers = await DataService.getPlaces();

    var mappedMarkers = markers
        .map(
          (markerPosition) => MarkerWithText(
            point: LatLng(
                markerPosition['coordinates']['latLng']['lat'] + demorandom(),
                markerPosition['coordinates']['latLng']['lng'] + demorandom()),
            width: 40,
            height: 40,
            builder: (_) => type2icon(markerPosition["type"]),
            anchorPos: AnchorPos.align(AnchorAlign.top),
            title: markerPosition['title'].toString(),
            description: markerPosition['description']?.toString() ?? "",
          ),
        )
        .toList();
    setState(() {
      mappedMarkers.forEach((m) => _markers.add(m));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa AV 2023'),
      ),
      body: FlutterMap(
        options: MapOptions(
          zoom: 16.5,
          center: LatLng(49.10353, 17.39502),
          onTap: (_, __) => _popupLayerController
              .hideAllPopups(), // Hide popup when the map is tapped.
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          PopupMarkerLayerWidget(
            options: PopupMarkerLayerOptions(
              popupController: _popupLayerController,
              markers: _markers,
              markerRotateAlignment:
                  PopupMarkerLayerOptions.rotationAlignmentFor(AnchorAlign.top),
              popupBuilder: (BuildContext context, Marker marker) {
                if (marker is MarkerWithText) {
                  return MapDescriptionPopup(marker);
                }
                return SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MapDescriptionPopup extends StatefulWidget {
  final MarkerWithText marker;

  const MapDescriptionPopup(this.marker, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MapDescriptionPopupState();
}

class _MapDescriptionPopupState extends State<MapDescriptionPopup> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _cardDescription(context),
        ],
      ),
    );
  }

  Widget _cardDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              widget.marker.title,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
            Text(
              widget.marker.description,
              style: const TextStyle(fontSize: 12.0),
            ),
          ],
        ),
      ),
    );
  }
}
