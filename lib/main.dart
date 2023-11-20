import 'dart:async';
import 'dart:convert';
import 'package:avapp/config.dart';
import 'package:avapp/services/StorageHelper.dart';
import 'package:get_storage/get_storage.dart';
import 'package:avapp/pages/AdministrationPage.dart';
import 'package:avapp/pages/InfoPage.dart';
import 'package:avapp/pages/MapPage.dart';
import 'package:avapp/pages/UserPage.dart';
import 'package:avapp/pages/NewsPage.dart';
import 'package:avapp/services/DataService.dart';
import 'package:avapp/services/ToastHelper.dart';
import 'package:avapp/widgets/ProgramTabView.dart';
import 'package:avapp/widgets/ProgramTimeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import 'models/EventModel.dart';
import 'pages/EventPage.dart';
import 'pages/HtmlEditorPage.dart';
import 'pages/LoginPage.dart';
import 'pages/ProgramPage.dart';
import 'services/NavigationService.dart';
import 'styles/Styles.dart';
import 'configure_nonweb.dart' if (dart.library.html) 'configure_web.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:badges/badges.dart' as badges;

Future<void> main() async {
  configureUrlFormat();
  await GetStorage.init();

  await Supabase.initialize(
    url: config.supabase_url,
    anonKey: config.anon_key,
  );
  initializeDateFormatting();
  if(!DataService.isLoggedIn())
  {
    DataService.tryAuthUser();
  }
  await DataService.loadOrInitGlobalSettings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        // builder: (context, child) {
        //   final mediaQueryData = MediaQuery.of(context);
        //   final scale = mediaQueryData.textScaleFactor.clamp(1.0, 1.3);
        //   return MediaQuery(
        //     child: child!,
        //     data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
        //   );
        // },
      navigatorKey: NavigationService.navigatorKey,
      title: MyHomePage.HOME_PAGE,
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          fontFamily: 'Futura',
          useMaterial3: false,
          scaffoldBackgroundColor: config.backgroundColor,
          secondaryHeaderColor: const Color(0xFFBA5D3F),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: primarySwatch)
              .copyWith(background: config.backgroundColor)),
        home: const MyHomePage(title: MyHomePage.HOME_PAGE),
        initialRoute: "/",
        routes: {
          MapPage.ROUTE: (context) => const MapPage(),
          EventPage.ROUTE: (context) => const EventPage(),
          InfoPage.ROUTE: (context) => const InfoPage(),
          UserPage.ROUTE: (context) => const UserPage(),
          LoginPage.ROUTE: (context) => const LoginPage(),
          HtmlEditorPage.ROUTE: (context) => const HtmlEditorPage(),
          AdministrationPage.ROUTE: (context) => const AdministrationPage(),
          NewsPage.ROUTE: (context) => const NewsPage(),
        }
    );
  }
}

class MyHomePage extends StatefulWidget {
  static const HOME_PAGE = config.home_page;

  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

String userName = "";
int redrawTabKey = 0;

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  loadData();
}

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        body: SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SvgPicture.asset(
                    width: 100,
                    semanticsLabel: 'Fotofest',
                    'assets/icons/cavlogo_full.svg',
                  ),
                  const Spacer(),
                  Visibility(
                    visible: !DataService.isLoggedIn(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            CircularButton(
                              onPressed: _loginPressed,
                              backgroundColor: config.color4,
                              child: const Icon(Icons.login),
                            ),
                            const Text("Přihlášení"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: DataService.isLoggedIn(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            CircularButton(
                              onPressed: _profileButtonPressed,
                              backgroundColor: config.color4,
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
          Expanded(child: ProgramTabView(events: _dots, onEventPressed: _eventPressed, key: ValueKey<int>(redrawTabKey),)),
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    MainPageButton(
                      onPressed: _programPressed,
                      backgroundColor: config.color1,
                      child: const Icon(Icons.calendar_month),
                    ),
                    const Text("Můj program"),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    badges.Badge(
                      showBadge: showMessageCount(),
                      badgeContent: SizedBox(
                        width: 20, height: 20,
                        child: Center(
                          child: Text(messageCountString(), style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16
                          )
                      ),
                    )
                ),
                      child: MainPageButton(
                        onPressed: _newsPressed,
                        backgroundColor: config.color3,
                        child: const Icon(Icons.newspaper),
                      ),
                    ),
                    const Text("Ohlášky"),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    MainPageButton(
                      onPressed: _mapPressed,
                      backgroundColor: config.color2,
                      child: const Icon(Icons.map),
                    ),
                    const Text("Mapa"),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    MainPageButton(
                      onPressed: _infoPressed,
                      backgroundColor: config.color4,
                      child: const Icon(Icons.info),
                    ),
                    const Text("Info"),
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
  if(!DataService.isLoggedIn())
    {
      ToastHelper.Show("Pro zobrazení mého programu se přihlaš!");
      return;
    }
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const ProgramPage())).then((value) => loadData());
  }

  Future<void> _newsPressed() async {
    Navigator.pushNamed(
        context, NewsPage.ROUTE).then((value) => loadData());
  }

  void _infoPressed() {
    Navigator.pushNamed(
        context, InfoPage.ROUTE).then((value) => loadData());
  }

  void _mapPressed() {
    Navigator.pushNamed(
        context, MapPage.ROUTE).then((value) => loadData());
  }

  void _loginPressed() {
    Navigator.pushNamed(
        context, LoginPage.ROUTE).then((value) => loadData());
  }

  void _profileButtonPressed() {
    Navigator.pushNamed(
        context, UserPage.ROUTE).then((value) => loadData());
  }

  final List<TimeLineItem> _dots = [];
  final List<EventModel> _events = [];

  Future<void> loadEventParticipants() async {
    // update sign in status / current participants for events
    await DataService.loadEventsParticipantsAndStatus(_events);
    for (var e in _events)
    {
        var dot = _dots.singleWhere((element) => element.id == e.id!);
        setState(() {
          dot.rightText = e.toString();
          dot.dotType = TimeLineItem.getIndicatorFromEvent(e);
        });
    }

    redrawTabKey++;
    //update offline
    var encoded = jsonEncode(_events);
    StorageHelper.Set("events", encoded);
  }

  _eventPressed(int id) {
    Navigator.pushNamed(
        context, EventPage.ROUTE, arguments: id).then((value) => loadData());
  }

  int _messageCount = 0;
  bool showMessageCount() => _messageCount>0;
  String messageCountString() => _messageCount<100?_messageCount.toString():"99";
  Future<void> loadData() async {
    
    //get data from offline
    try
    {
      var eventData = StorageHelper.Get("events");
      if(eventData!=null && _events.isEmpty)
      {
          var offlineEventsData = json.decode(eventData);
          setState((){
            _events.addAll(List<EventModel>.from(offlineEventsData.map((o)=>EventModel.fromJson(o))));
            _dots.clear();
            _dots.addAll(_events.map((e) => TimeLineItem.fromEventModel(e)));
          });
      }
    }
    catch(e)
    {
      // make sure not to fail on start
    }

    if(DataService.isLoggedIn())
    {
      await DataService.getCurrentUserInfo().then((value) => userName = value.name!);
    }

    //load online data
    await DataService.updateEvents(_events)
        .whenComplete(() async {
          _dots.clear();
          _dots.addAll(_events.map((e) => TimeLineItem.fromEventModel(e)));
          if(!DataService.isLoggedIn()) {
            return;
          }
          var count = await DataService.countNewMessages();

          setState(() {
            _messageCount = count;
          });
        });

    loadEventParticipants();
  }
}
