import 'package:flutter/material.dart';
import 'package:registration_login/screen/home_screen.dart';
import 'package:registration_login/screen/login_screen.dart';
import 'package:registration_login/screen/registration_screen.dart';
import 'package:registration_login/screen/splash_screen.dart';
import 'package:registration_login/screen/background_geolocation_screen.dart';
import 'package:registration_login/screen/fragment/children_screen.dart';
import 'package:registration_login/screen/fragment/map_fragment.dart';
import 'package:registration_login/screen/fragment/child_start_fragment.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';

//Or go_router
void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    // await Hive.deleteBoxFromDisk('shopping_box');
    await Hive.openBox('shopping_box');
    //GoRouter.setUrlPathStrategy(UrlPathStrategy.path);
    final GoRouter _router = GoRouter(
        urlPathStrategy: UrlPathStrategy.path,
        routes: <GoRoute>[
            GoRoute(
                path: '/BackgroundGeolocation',
                builder: (BuildContext context, GoRouterState state)=>MyApp(),
            ),
            GoRoute(
                path: '/',
                builder: (BuildContext context, GoRouterState state){
                    return HomeScreen();
                },
                routes: [
                    GoRoute(
                        path:'contact_us',
                        builder: (BuildContext context, GoRouterState state){
                            return HomeScreen(path:state.path);
                        },
                    ),
                    GoRoute(
                        path:'setting',
                        builder: (BuildContext context, GoRouterState state){
                            return HomeScreen(path:state.path);
                        },
                    ),
                    GoRoute(
                        path:'children',
                        builder: (BuildContext context, GoRouterState state){
                            return HomeScreen(path:state.path);
                        },
                    ),
                    GoRoute(
                        path:'children/create',
                        builder: (BuildContext context, GoRouterState state){
                            return ChildStartFragment();
                        },
                    ),
                    GoRoute(
                        path:'map/:lat/:lon',
                        builder: (BuildContext context, GoRouterState state){
                            return MapFragment(options:{
'lat':double.parse(state.params['lat'].toString()),
'lon':double.parse(state.params['lon'].toString())
});
                        },
                    )
                ]
            ),
        ],
    );

    runApp(new MaterialApp.router(
        debugShowCheckedModeBanner: false,
        //home: HomeScreen(),
        //home: SplashScreen(),
        //routes: routes
        routeInformationProvider: _router.routeInformationProvider,
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        title: 'PMA Ancash',
    ));

}
//https://medium.com/flutter/learning-flutters-new-navigation-and-routing-system-7c9068155ade