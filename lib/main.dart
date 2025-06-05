import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple/pages/database_connection.dart';
import 'package:simple/pages/homepage.dart';
import 'package:simple/widgets/database_provider.dart';
import 'package:simple/widgets/app_drawer.dart';
import 'package:simple/pages/image_classification.dart';
import 'package:simple/pages/robot_price_calculator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 2;

  final List<Widget> _pages = [HomeScreen(), ImageClassification(), RobotPriceCalculatorPage(), DatabaseConnection()];

  void _onDrawerItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  final List<String> _titles = [
    'Home',
    'Image Classification',
    'Robot Price Calculator',
    'Database Connection',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          // IconButton(
          //   icon: Icon(_getAppBarIcon(_selectedIndex)),
          //   onPressed: () {
          //     // optional action
          //   },
          // ),
        ],
      ),
      drawer: AppDrawer(
        selectedIndex: _selectedIndex,
        onItemSelected: _onDrawerItemSelected,
      ),
      body: _pages[_selectedIndex],
    );
  }
  // IconData _getAppBarIcon(int index) {
  //   switch (index) {
  //     case 0:
  //       return Icons.home;
  //     case 1:
  //       return Icons.image;
  //     case 2:
  //       return Icons.storage;
  //     default:
  //       return Icons.help;
  //   }
  // }
}
