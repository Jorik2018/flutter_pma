import 'package:flutter/material.dart';
import 'package:registration_login/screen/home_screen.dart';
import 'package:registration_login/screen/login_screen.dart';
import 'package:registration_login/screen/registration_screen.dart';
import 'package:registration_login/screen/splash_screen.dart';
import 'package:registration_login/screen/background_geolocation_screen.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';

var routes = <String, WidgetBuilder>{
    "/RegistrationScreen": (BuildContext context) => RegistrationScreen(),
    "/LoginScreen": (BuildContext context) => LoginScreen(),
    "/HomeScreen": (BuildContext context) => HomeScreen(),
    "/BackgroundGeolocation": (BuildContext context) => MyApp(),
};
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
                path: '/',
                builder: (BuildContext context, GoRouterState state) {
                    return HomeScreen();
                },
            ),
            GoRoute(
                path: '/BackgroundGeolocation',
                builder: (BuildContext context, GoRouterState state)=>MyApp(),
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