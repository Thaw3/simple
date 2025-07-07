import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const AppDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            selected: selectedIndex == 0,
            onTap: () {
              Navigator.pop(context);
              onItemSelected(0);
            },
          ),
      
          ListTile(
            leading: Icon(Icons.calculate_outlined),
            title: Text('Robot Price Calculator'),
            selected: selectedIndex == 1,
            onTap: () {
              Navigator.pop(context);
              onItemSelected(1);
            },
          ),
          ListTile(
            leading: Icon(Icons.storage),
            title: Text('Database Connection'),
            selected: selectedIndex == 2,
            onTap: () {
              Navigator.pop(context);
              onItemSelected(2);
            },
          ),
          ListTile(
            leading: Icon(Icons.private_connectivity),
            title: Text('MQTT Connection'),
            selected: selectedIndex == 3,
            onTap: () {
              Navigator.pop(context);
              onItemSelected(3);
            },
          ),
          ListTile(
            leading: Icon(Icons.analytics_outlined),
            title: Text('AI Model Prediction'),
            selected: selectedIndex == 4,
            onTap: () {
              Navigator.pop(context);
              onItemSelected(4);
            },
          ),
        ],
      ),
    );
  }
}