import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple/widgets/database_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context);
    return Scaffold(
      body: Center(
        child: Column(children: [Text("Status: ${provider.status}")]),
      ),
    );
  }
}
