import 'package:flutter/services.dart';
import 'package:flutter_map_polywidget/flutter_map_polywidget.dart';
import 'package:e14_station/providers/socket_station.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';

class EmergenciesView extends StatefulWidget {
  const EmergenciesView({super.key});

  @override
  State<StatefulWidget> createState() => _EmergenciesViewState();
}

class _EmergenciesViewState extends State<EmergenciesView> {
  late ScrollController scroll;
  late MapController mapController;
  bool verticalMode = false;
  ValueNotifier<int> selectedIndex = ValueNotifier<int>(-1);

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    scroll = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    mapController.dispose();
    scroll.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width <
        MediaQuery.of(context).size.height) {
      verticalMode = true;
    } else {
      verticalMode = false;
    }

    return Scaffold(
        appBar: AppBar(),
        body: ValueListenableBuilder(
            valueListenable: selectedIndex,
            builder: (context, _, __) => ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                    controller: scroll,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Consumer<SocketStation>(
                        builder: (context, socketStation, _) => Wrap(children: [
                              SizedBox(
                                  width: verticalMode
                                      ? MediaQuery.of(context).size.width
                                      : MediaQuery.of(context).size.width / 3,
                                  height:
                                      MediaQuery.of(context).size.height - 56,
                                  child: Card(
                                      child: EventsTileListView(
                                          emergenciesContent:
                                              socketStation.emergenciesContent,
                                          mapController: mapController,
                                          selectedIndex: selectedIndex,
                                          verticalMode: verticalMode,
                                          scroll: scroll))),
                              SizedBox(
                                  width: verticalMode
                                      ? MediaQuery.of(context).size.width
                                      : MediaQuery.of(context).size.width -
                                          (MediaQuery.of(context).size.width /
                                              3),
                                  height:
                                      MediaQuery.of(context).size.height - 56,
                                  child: Card(
                                      child: Stack(children: [
                                    SingleChildScrollView(
                                        child: Column(children: [
                                      SizedBox(
                                          height: (MediaQuery.of(context)
                                                      .size
                                                      .height -
                                                  56) /
                                              1.5,
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: MapView(
                                                  initialCenter:
                                                      const LatLng(16, 106),
                                                  points: [
                                                    for (var point
                                                        in socketStation
                                                            .emergenciesContent)
                                                      LatLng(point["latitude"],
                                                          point["longitude"])
                                                  ],
                                                  selectedIndex: selectedIndex,
                                                  mapController:
                                                      mapController))),
                                      Padding(
                                          padding: const EdgeInsets.all(25),
                                          child: selectedIndex.value != -1
                                              ? InfoDisplay(
                                                  reportedTime:
                                                      socketStation.emergenciesContent[selectedIndex.value]
                                                          ["reportedTime"],
                                                  address: socketStation.emergenciesContent[selectedIndex.value]
                                                      ["address"],
                                                  location: LatLng(
                                                      socketStation.emergenciesContent[selectedIndex.value]
                                                          ["latitude"],
                                                      socketStation.emergenciesContent[selectedIndex.value]
                                                          ["longitude"]),
                                                  reporterPhoneNumber: socketStation.emergenciesContent[selectedIndex.value]
                                                      ["reporterPhoneNumber"],
                                                  locationApproximate: socketStation
                                                      .emergenciesContent[selectedIndex.value]
                                                          ["locationApproximate"]
                                                      .toDouble()
                                                      .toStringAsFixed(2))
                                              : Text("Chọn mục bên trái để mở chi tiết các địa điểm.", style: TextStyle(color: Colors.grey.withOpacity(.7), fontSize: 20)))
                                    ])),
                                    Align(
                                        alignment: Alignment.bottomRight,
                                        child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  FilledButton.icon(
                                                      onPressed: selectedIndex
                                                                  .value !=
                                                              -1
                                                          ? socketStation.emergenciesContent[
                                                                      selectedIndex
                                                                          .value]
                                                                  ["notified"]
                                                              ? null
                                                              : () {
                                                                  socketStation.notifyClientZone(socketStation
                                                                          .emergenciesContent[
                                                                      selectedIndex
                                                                          .value]["_id"]);
                                                                }
                                                          : null,
                                                      icon: const Icon(
                                                          Icons.radar),
                                                      label: const Text(
                                                          "Thông báo cho người dùng khoanh vùng")),
                                                  const SizedBox(width: 20),
                                                  FilledButton.icon(
                                                      onPressed:
                                                          selectedIndex.value !=
                                                                  -1
                                                              ? () {
                                                                  socketStation.finishReport(socketStation
                                                                          .emergenciesContent[
                                                                      selectedIndex
                                                                          .value]["_id"]);
                                                                  selectedIndex
                                                                      .value = -1;
                                                                }
                                                              : null,
                                                      icon: const Icon(
                                                          Icons.check),
                                                      label: const Text(
                                                          "Đã xử lý"))
                                                ]))),
                                    verticalMode
                                        ? Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: ElevatedButton.icon(
                                                onPressed: () {
                                                  scroll.animateTo(0,
                                                      duration: const Duration(
                                                          milliseconds: 300),
                                                      curve: Curves.ease);
                                                  selectedIndex.value = -1;
                                                },
                                                icon: const Icon(
                                                    Icons.arrow_upward),
                                                label: const Text("Quay lại")))
                                        : Container()
                                  ])))
                            ]))))));
  }
}

class EventsTileListView extends StatelessWidget {
  final MapController mapController;
  final ScrollController scroll;
  final bool verticalMode;
  final ValueNotifier<int> selectedIndex;
  final dynamic emergenciesContent;
  const EventsTileListView(
      {super.key,
      this.emergenciesContent,
      required this.selectedIndex,
      required this.verticalMode,
      required this.scroll,
      required this.mapController});

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      for (int eventIndex = 0;
          eventIndex < emergenciesContent.length;
          eventIndex++)
        Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: selectedIndex.value == eventIndex
                    ? Theme.of(context).colorScheme.onPrimary
                    : null),
            child: EventTile(
                reporterPhoneNumber: emergenciesContent[eventIndex]
                    ["reporterPhoneNumber"],
                location: LatLng(emergenciesContent[eventIndex]["latitude"],
                    emergenciesContent[eventIndex]["longitude"]),
                address: emergenciesContent[eventIndex]["address"],
                onPressed: () {
                  if (verticalMode) {
                    scroll.animateTo(MediaQuery.of(context).size.height,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease);
                  }
                  mapController.move(
                      LatLng(emergenciesContent[eventIndex]["latitude"],
                          emergenciesContent[eventIndex]["longitude"]),
                      16);
                  selectedIndex.value = eventIndex;
                }))
    ]);
  }
}

class EventTile extends StatelessWidget {
  final void Function()? onPressed;
  final String? address;
  final String reporterPhoneNumber;
  final LatLng location;
  const EventTile(
      {super.key,
      this.onPressed,
      this.address,
      required this.location,
      required this.reporterPhoneNumber});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onPressed,
        child: ListTile(
            leading: const Icon(Icons.location_pin),
            title: Text(address ?? "Địa điểm cháy"),
            subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      "Vị trí GPS | Vĩ độ: ${location.latitude}; Kinh độ: ${location.longitude}"),
                  Text("Báo cáo bởi: $reporterPhoneNumber")
                ])));
  }
}

class MapView extends StatelessWidget {
  final MapController mapController;
  final ValueNotifier<int> selectedIndex;
  final LatLng initialCenter;
  final List<LatLng> points;
  const MapView(
      {super.key,
      required this.initialCenter,
      required this.points,
      required this.selectedIndex,
      required this.mapController});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
        mapController: mapController,
        options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: 5,
            interactionOptions:
                const InteractionOptions(enableScrollWheel: false)),
        children: [
          TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'dev.neurs.e14_station'),
          PolyWidgetLayer(polyWidgets: [
            for (var point in points)
              PolyWidget(
                  center: point,
                  widthInMeters: 100,
                  heightInMeters: 200,
                  child: const Icon(Icons.location_pin, color: Colors.red))
          ])
        ]);
  }
}

class InfoDisplay extends StatelessWidget {
  final int reportedTime;
  final String address, reporterPhoneNumber;
  final LatLng location;
  final String locationApproximate;
  const InfoDisplay(
      {super.key,
      required this.address,
      required this.location,
      required this.reporterPhoneNumber,
      required this.reportedTime,
      required this.locationApproximate});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> fillIn = [
      {"title": "Địa chỉ (Gần đúng)", "content": address},
      {
        "title": "Vị trí",
        "content": "${location.latitude}, ${location.longitude}"
      },
      {"title": "Độ sai vị trí", "content": "${locationApproximate}m"},
      {"title": "SĐT người báo", "content": reporterPhoneNumber},
      {
        "title": "Thời gian báo",
        "content": DateTime.fromMillisecondsSinceEpoch(reportedTime).toString()
      }
    ];
    return Wrap(spacing: 50, runSpacing: 50, children: [
      for (var fill in fillIn)
        Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text(fill["title"]!, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 5),
                IconButton(
                    onPressed: () => Clipboard.setData(
                        ClipboardData(text: fill["content"]!)),
                    icon: const Icon(Icons.copy))
              ]),
              Text(fill["content"]!,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold))
            ])
    ]);
  }
}
