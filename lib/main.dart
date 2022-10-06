import 'package:flutter/material.dart';
import 'package:flutter_pma/screen/home_screen.dart';
//import 'package:flutter_pma/screen/background_geolocation_screen.dart';
import 'package:flutter_pma/screen/fragment/map_fragment.dart';
import 'package:flutter_pma/screen/fragment/child_start_fragment.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_pma/utils/redirect.dart';
import 'package:flutter_pma/utils/redirect_stub.dart' // Stub implementation
    if (dart.library.html) 'package:flutter_pma/utils/redirect_web.dart'
    if (dart.library.io) 'package:flutter_pma/utils/redirect_other.dart';
import 'package:flutter_pma/redux.dart';
import 'package:redux/redux.dart';
import 'package:uni_links/uni_links.dart';

_launchURL(url) async {
  if (kIsWeb) {
    Redirector r=getManager();
    r.go(url);
  } else {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch ' + url;
    }
  }
}

//Or go_router
void main() async {
  String myurl = Uri.base.toString();
  String? code = Uri.base.queryParameters["code"];
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // await Hive.deleteBoxFromDisk('shopping_box');
  await Hive.openBox('shopping_box');
  //GoRouter.setUrlPathStrategy(UrlPathStrategy.path);

  /*if (code == null) {
    const client_id = '7GkIlgUp8Pin4P5GMax3x3ey';
    _launchURL(
        'http://127.0.0.1:5000/oauth/authorize?response_type=code&client_id=' +
            client_id +
            '&scope=profile');
  } else */
  {
    final store = Store<dynamic>(counterReducer, initialState: "");

    if (!kIsWeb) {
      // It will handle app links while the app is already started - be it in
      // the foreground or in the background.
      uriLinkStream.listen((Uri? uri) {
        print('got uri: $uri');
      }, onError: (Object err) {
        print('got err: $err');
      });
    }

    final GoRouter _router = GoRouter(
      urlPathStrategy: UrlPathStrategy.path,
      routes: <GoRoute>[
       /* GoRoute(
          path: '/BackgroundGeolocation',
          builder: (BuildContext context, GoRouterState state) => MyApp(),
        ),*/
        GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) {
              return HomeScreen(store: store);
            },
            routes: [
              GoRoute(
                path: 'contact_us',
                builder: (BuildContext context, GoRouterState state) {
                  return HomeScreen(path: state.path);
                },
              ),
              GoRoute(
                path: 'setting',
                builder: (BuildContext context, GoRouterState state) {
                  return HomeScreen(path: state.path);
                },
              ),
              GoRoute(
                path: 'children',
                builder: (BuildContext context, GoRouterState state) {
                  return HomeScreen(path: state.path);
                },
              ),
              GoRoute(
                path: 'children/create',
                builder: (BuildContext context, GoRouterState state) {
                  return ChildStartFragment();
                },
              ),
              GoRoute(
                path: 'children/:id/edit',
                builder: (BuildContext context, GoRouterState state) {
                  return ChildStartFragment(id:state.params['id'] != null?state.params['id'].toString():null);
                },
              ),
              GoRoute(
                path: 'map/:lat/:lon',
                builder: (BuildContext context, GoRouterState state) {
                  return MapFragment(options: {
                    'lat': double.parse(state.params['lat'].toString()),
                    'lon': double.parse(state.params['lon'].toString())
                  });
                },
              )
            ]),
      ],
    );

    runApp(new MaterialApp.router(
      debugShowCheckedModeBanner: false,
      //home: HomeScreen(),
      //home: SplashScreen(),
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
      title: 'PMA Ancash',
    ));
  }
}
//https://medium.com/flutter/learning-flutters-new-navigation-and-routing-system-7c9068155ade