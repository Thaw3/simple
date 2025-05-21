import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple/pages/database_connection.dart';
import 'package:simple/pages/homepage.dart';
import 'package:simple/widgets/database_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DatabaseProvider()),
      ],
      child: MaterialApp(
        title: 'Main Page with Drawer',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: MainPage(),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [HomeScreen(), DatabaseConnection()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My App')),
      drawer: Drawer(
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
              leading: Icon(Icons.storage),
              title: Text('Database Connection'),
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
