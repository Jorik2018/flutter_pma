
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pma/screen/fragment/about_us_fragment.dart';
import 'package:flutter_pma/screen/fragment/contact_us_fragment.dart';
import 'package:flutter_pma/screen/fragment/home_fragment.dart';
import 'package:flutter_pma/screen/fragment/setting_fragment.dart';
import 'package:flutter_pma/screen/fragment/child_start_fragment.dart';
import 'package:flutter_pma/screen/fragment/children_screen.dart';
import 'package:flutter_pma/screen/fragment/map_fragment.dart';
import 'package:flutter_pma/utils/util.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class DrawerItem {
    String title;
    IconData icon;
    DrawerItem(this.title, this.icon);
}

class HomeScreen extends StatefulWidget {
    final drawerItems = [
        new DrawerItem("Home", Icons.home),
        new DrawerItem("Setting", Icons.settings),
        new DrawerItem("About us", Icons.print),
        new DrawerItem("Contact us", Icons.contacts),
        new DrawerItem("Children", Icons.people)
    ];

  String? path;

  Store? store;

  HomeScreen({this.path,this.store});

    @override
    _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

    int _selectedIndex = 0;
    List<Widget> Function()? addActions;

    @override
    Widget build(BuildContext context) {

        if(widget.path=='children')_selectedIndex=4;

        var drawerOptions = <Widget>[];
        for (var i = 0; i < widget.drawerItems.length; i++) {
            var d = widget.drawerItems[i];
            drawerOptions.add(
                new Column(
                    children: <Widget>[
                        new ListTile(
                            leading: new Icon(
                                d.icon,
                                color: Colors.blue
                            ),
                            title: new Text(
                                d.title,
                                style: new TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold
                                )
                            ),
                            selected: i == _selectedIndex,
                            onTap: () => _onSelectItem(i,pop:true),
                        ),
                        new Divider(
                            color: Colors.blue,
                            height: 2.0,
                        )
                    ],
                )
            );
        }
        return new Scaffold(
            appBar: new AppBar(
                backgroundColor: Colors.green, 
                title: new Text(_selectedIndex<widget.drawerItems.length?widget.drawerItems[_selectedIndex].title:'Not Found!'),
                elevation: defaultTargetPlatform== TargetPlatform.android?5.0:0.0,
                actions:actions
            ),
            drawer: new Drawer(
                child: new ListView(
                    children: <Widget>[
                        new UserAccountsDrawerHeader(
                            accountName: new Text(Util.userName),
                            accountEmail: new Text(Util.emailId),
                            currentAccountPicture: new CircleAvatar(
                                maxRadius: 24.0,
                                backgroundColor: Colors.transparent,
                                child: new Center(
                                    child: new Image.network(
                                        Util.profilePic,
                                        height: 58.0,
                                        width: 58.0,
                                    )
                                )
                                // backgroundImage: new Image.network(src),
                            ),
                        ),
                        /*StoreConnector<int, String>(
                  converter: (store) => store.state.toString(),
                  builder: (context, count) {
                    return Text('$count');
                  },
                ),*/
                        new Column(
                            children: drawerOptions
                        )
                    ],
                ),
            ),
            body: _setDrawerItemWidget(_selectedIndex),
            
        );
    }

    List<Widget> actions=[];

    _setDrawerItemWidget(int pos) {
        switch (pos) {
            case 0:
                return new HomeFragment();
            case 1:
                return new SettingFragment();
            case 2:
                return new AboutUsFragment();
            case 3:
                return new ContactUsFragment();
            case 4:
                return new ChildrenScreen(buildAction:_buildAction);
                //setState(() {
                  //getActions=childrenScreen.getActions();
                //});
                  //return new ChildStartFragment(
                 // navigateTo:_onSelectItem
                //);
            case 5:
                return new MapFragment(options:options);
            default:
                return new Text("Error");
        }
    }

    Map? options;

    _buildAction({List<Widget>? actions}){
      
      setState(() {
        debugPrint('_buildAction in home');
        this.actions=actions!=null?actions:[];
      });
    }

    _onSelectItem(int index,{bool pop:false,Map? options}) {
      if(index==4){
        context.go('/children');
        return;
      }
      this.options=options;
      //debugPrint('index: $index');
      setState(() => _selectedIndex = index);
      if(pop)
      Navigator.of(context).pop(); // close the drawer
    }

}
