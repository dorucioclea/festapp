import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fstapp/RouterService.dart';
import 'package:fstapp/appConfig.dart';
import 'package:fstapp/dataServices/AuthService.dart';
import 'package:fstapp/dataServices/DbEvents.dart';
import 'package:fstapp/dataServices/DbNews.dart';
import 'package:fstapp/dataServices/DbPlaces.dart';
import 'package:fstapp/dataServices/DbUsers.dart';
import 'package:fstapp/dataServices/OfflineDataService.dart';
import 'package:fstapp/dataServices/RightsService.dart';
import 'package:fstapp/dataModels/EventModel.dart';
import 'package:fstapp/dataModels/PlaceModel.dart';
import 'package:fstapp/pages/EventPage.dart';
import 'package:fstapp/pages/InfoPage.dart';
import 'package:fstapp/pages/LoginPage.dart';
import 'package:fstapp/pages/MapPage.dart';
import 'package:fstapp/pages/NewsPage.dart';
import 'package:fstapp/pages/SongPage.dart';
import 'package:fstapp/pages/TimetablePage.dart';
import 'package:fstapp/pages/UserPage.dart';
import 'package:fstapp/components/timeline/ScheduleTimelineHelper.dart';
import 'package:fstapp/services/NotificationHelper.dart';
import 'package:fstapp/services/StylesHelper.dart';
import 'package:fstapp/services/TimeHelper.dart';
import 'package:fstapp/services/ToastHelper.dart';
import 'package:fstapp/styles/Styles.dart';
import 'package:fstapp/tests/DataServiceTests.dart';
import 'package:fstapp/components/timeline/ScheduleTabView.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fstapp/dataServices/DataExtensions.dart';
import 'package:fstapp/pages/MySchedulePage.dart';
import 'package:package_info_plus/package_info_plus.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  static const HOME_PAGE = AppConfig.appName;

  const HomePage({super.key});

  final String title = AppConfig.appName;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String userName = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    StylesHelper.setMetaThemeColor(AppConfig.color1);
    loadData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 12, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onDoubleTap: () async {
                          var packageInfo = await PackageInfo.fromPlatform();
                          ToastHelper.Show(
                              "${packageInfo.appName} ${packageInfo.version}+${packageInfo.buildNumber}");
                          if(RightsService.isEditor()) {
                            setState(() {
                              TimeHelper.toggleTimeTravel?.call();
                            });
                          }
                        },
                        child: SvgPicture.asset(
                          height: 82,
                          semanticsLabel: 'Festival Slunovrat logo',
                          'assets/icons/fstapplogo.svg',
                        ),
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          SvgIconButton(
                            onPressed: _mySchedulePressed, // do something,
                            iconPath: 'assets/icons/ikona muj program.svg',
                            iconSize: 42,
                          ),
                          Text("My schedule".tr()),
                        ],
                      ),
                      const SizedBox.square(dimension: 12,),
                      Visibility(
                        visible: !AuthService.isLoggedIn(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                CircularButton(
                                  onPressed: _loginPressed,
                                  backgroundColor: AppConfig.button1Color,
                                  child: const Icon(Icons.login),
                                ),
                                Text("Sign in".tr()),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: AuthService.isLoggedIn(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                CircularButton(
                                  onPressed: _profileButtonPressed,
                                  backgroundColor: AppConfig.profileButtonColor,
                                  child: const Icon(Icons.account_circle_rounded),
                                ),
                                Text(userName),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
              Expanded(
                  child: ScheduleTabView(
                    key: _dots.isEmpty ? UniqueKey() : null,
                    events: _dots,
                    onEventPressed: _eventPressed,
                  )),
              Container(
                constraints: const BoxConstraints(
                  maxWidth: 420,
                ),
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      children: [
                        SvgIconButton(
                          onPressed: _programPressed, // do something,
                          iconPath: 'assets/icons/ikona program.svg',
                        ),
                        Text("Schedule".tr()),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        badges.Badge(
                          showBadge: showMessageCount(),
                          badgeContent: SizedBox(
                              width: 20,
                              height: 20,
                              child: Center(
                                child: Text(messageCountString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16)),
                              )),
                          child: SvgIconButton(
                            onPressed: _newsPressed, // do something,
                            iconPath: 'assets/icons/ikona oznameni.svg',
                          ),
                        ),
                        const Text("News").tr(),
                      ],
                    ),
                    Column(
                      children: [
                        SvgIconButton(
                          onPressed: _mapPressed, // do something,
                          iconPath: 'assets/icons/ikona mapa.svg',
                        ),
                        Text("Map".tr()),
                      ],
                    ),
                    Column(
                      children: [
                        SvgIconButton(
                          onPressed: _infoPressed, // do something,
                          iconPath: 'assets/icons/ikona informace.svg',
                        ),
                        Text("Info".tr()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  void _programPressed() {
    if (!AppConfig.isOwnProgramSupported && !AuthService.isLoggedIn()) {
      ToastHelper.Show("Sign in to view My schedule!".tr());
      return;
    }
    RouterService.navigateOccasion(context, ProgramViewPage.ROUTE).then((value) => loadData());
  }

  Future<void> _mySchedulePressed() async {
    RouterService.navigateOccasion(context, MySchedulePage.ROUTE).then((value) => loadData());
  }

  Future<void> _newsPressed() async {
    RouterService.navigateOccasion(context, NewsPage.ROUTE).then((value) => loadData());
  }

  void _infoPressed() {
    RouterService.navigateOccasion(context, InfoPage.ROUTE).then((value) => loadData());
  }

  void _mapPressed() {
    RouterService.navigateOccasion(context, MapPage.ROUTE).then((value) => loadData());
  }

  void _loginPressed() {
    RouterService.navigate(context, LoginPage.ROUTE).then((value) => loadData());
  }

  void _profileButtonPressed() {
    RouterService.navigateOccasion(context, UserPage.ROUTE).then((value) => loadData());
  }

  _eventPressed(int id) {
    RouterService.navigateOccasion(context, "${EventPage.ROUTE}/$id").then((value) => loadData());
  }

  final List<TimeBlockItem> _dots = [];
  final List<EventModel> _events = [];

  Future<void> loadEventParticipants() async {
    // update sign in status / current participants for events
    await DbEvents.loadEventsParticipantsAndStatus(_events);
    for (var e in _events.filterRootEvents()) {
      var dot = _dots.singleWhere((element) => element.id == e.id!);
      setState(() {
        dot.data["rightText"] = e.toString();
        dot.timeBlockType = TimeBlockHelper.getTimeBlockTypeFromModel(e);
      });
    }
    setState(() {});
  }

  int _messageCount = 0;

  bool showMessageCount() => _messageCount > 0;

  String messageCountString() =>
      _messageCount < 100 ? _messageCount.toString() : "99";

  Future<void> loadData() async {
    //DataServiceTests.test_update_user();
    //await DataService.ImportFromSingleToMultipleEventType();
    //DataServiceTests.test_has_event_allowed_role();

    await loadOfflineData();
    //await RightsService.ensureAccessProcedure(context);

    if (AuthService.isLoggedIn()) {
      DbUsers.getCurrentUserInfo()
          .then((value) => userName = value.name!);
    }

    await DbEvents.updateEvents(_events).whenComplete(() async {
      if(AppConfig.isSplitByPlace) {
        await loadPlacesForEvents(_events, DbPlaces.getPlacesIn);
      }
      _dots.clear();
      _dots.addAll(_events.filterRootEvents().map((e) => TimeBlockItem.fromEventModel(e)));
      if (AuthService.isLoggedIn()) {
        DbNews.countNewMessages().then((value) => {
          setState(() {
            _messageCount = value;
          })
        });
      }
    });
    await loadEventParticipants();
    await OfflineDataService.saveAllEvents(_events);
    await NotificationHelper.checkForNotificationPermission(context);
  }

  FutureOr<void> loadPlacesForEvents(List<EventModel> events, FutureOr<List<PlaceModel>> Function(List<int>) fetchPlaces) async {
    var placeIds = events
        .map((e) => e.place?.id)
        .where((id) => id != null)
        .cast<int>()
        .toSet()
        .toList();

    var places = await fetchPlaces(placeIds);

    var placesById = {for (var place in places) place.id: place};

    // Assign the loaded places to the corresponding events
    for (var event in events) {
      if (event.place?.id != null && placesById.containsKey(event.place!.id)) {
        event.place = placesById[event.place!.id];
      }
    }
  }

  Future<void> loadOfflineData() async {
    if (_events.isEmpty) {
      var offlineEvents = await OfflineDataService.getAllEvents();
      await OfflineDataService.updateEventsWithGroupName(offlineEvents);
      if(AppConfig.isSplitByPlace) {
        await loadPlacesForEvents(offlineEvents, (ids) async => (await OfflineDataService.getAllPlaces()));
      }
      _events.addAll(offlineEvents);
      _dots.clear();
      _dots.addAll(_events.filterRootEvents().map((e) => TimeBlockItem.fromEventModel(e)));
      setState(() {});
    }
    if (AuthService.isLoggedIn()) {
      var userInfo = await OfflineDataService.getUserInfo();
      setState(() {
        userName = userInfo?.name??"";
      });
    }
  }
}