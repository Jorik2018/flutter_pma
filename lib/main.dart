import 'package:flutter/material.dart';
import 'package:flutter_pma/screen/home_screen.dart';
//import 'package:flutter_pma/screen/background_geolocation_screen.dart';
import 'package:flutter_pma/screen/fragment/map_fragment.dart';
import 'package:flutter_pma/screen/fragment/child_start_fragment.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_pma/utils/redirect_stub.dart' // Stub implementation
    if (dart.library.html) 'package:flutter_pma/utils/redirect_web.dart'
    if (dart.library.io) 'package:flutter_pma/utils/redirect_other.dart';
import 'package:flutter_pma/redux.dart';
import 'package:redux/redux.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_pma/utils/util.dart';

void main() async {

  await dotenv.load();

  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  var boxApp=await Hive.openBox('app');
  
  final store = Store<dynamic>(counterReducer, initialState: "");
  String? code;
  if (!kIsWeb) {
    // It will handle app links while the app is already started - be it in
    // the foreground or in the background.
    uriLinkStream.listen((Uri? uri) {
      print('got uri: $uri');
    }, onError: (Object err) {
      print('got err: $err');
    });
  }else{
    code=getManager().param('code');
    if(code!=null)
      http2.post('/api/minsa/token',{'code':code}).then((response){
        var result= jsonDecode(response.body);
        if(result['error']==null)
          boxApp.put('token',result['access_token']);
      });
  }
  String? token=boxApp.get('token');
  if(code==null&&token==null){
    getManager().go(Util.API_URL+'/api/oauth/authorize?response_type=code&client_id=' +
            dotenv.env['OAUTH_CLIENT_ID']! +
            '&scope=profile');
  }
  if(token!=null){
    http2.headers['Authorization']='Bearer $token';
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
                return ChildStartFragment(id:null);
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
//https://medium.com/flutter/learning-flutters-new-navigation-and-routing-system-7c9068155ade