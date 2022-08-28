
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:registration_login/screen/fragment/about_us_fragment.dart';
import 'package:registration_login/screen/fragment/contact_us_fragment.dart';
import 'package:registration_login/screen/fragment/home_fragment.dart';
import 'package:registration_login/screen/fragment/setting_fragment.dart';
import 'package:registration_login/screen/fragment/child_start_fragment.dart';
import 'package:registration_login/screen/fragment/map_fragment.dart';
import 'package:registration_login/utils/util.dart';

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
    @override
    _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

    int _selectedIndex = 0;

    @override
    Widget build(BuildContext context) {
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
                title: new Text(_selectedIndex<widget.drawerItems.length?widget.drawerItems[_selectedIndex].title:'Not Found!'),
                elevation: defaultTargetPlatform== TargetPlatform.android?5.0:0.0,
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
                        new Column(
                            children: drawerOptions
                        )
                    ],
                ),
            ),
            body: _setDrawerItemWidget(_selectedIndex)
        );
    }

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
                return new ChildStartFragment(
                  navigateTo:_onSelectItem
                );
            case 5:
                return new MapFragment(options:options);
            default:
                return new Text("Error");
        }
    }

Map? options;

    _onSelectItem(int index,{bool pop:false,Map? options}) {
      this.options=options;
      debugPrint('index: $index');
      setState(() => _selectedIndex = index);
      if(pop)
      Navigator.of(context).pop(); // close the drawer
    }

}
