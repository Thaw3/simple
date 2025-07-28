import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const AppDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  // This widget builds the app drawer with a gradient background and various menu items
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: Text(
                'Welcome!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text('', style: TextStyle(color: Colors.white70)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.blueAccent),
              ),
            ),

            // List of menu items in the drawer
            _buildDrawerTile(context, Icons.home, 'Home', 0),
            Divider(),
            _buildDrawerTile(
              context,
              Icons.calculate_outlined,
              'Robot Price Calculator',
              1,
            ),
            Divider(),
            _buildDrawerTile(context, Icons.storage, 'Database Connection', 2),

            _buildDrawerTile(
              context,
              Icons.private_connectivity,
              'MQTT Connection',
              3,
            ),
            _buildDrawerTile(context, Icons.message_sharp, 'Monitor MQTT', 4),
            Divider(),
            _buildDrawerTile(
              context,
              Icons.camera_alt,
              'AI Model Prediction',
              5,
            ),
            Divider(),
            _buildDrawerTile(
              context,
              Icons.dataset_linked,
              'Dataset Collection',
              6,
            ),
          ],
        ),
      ),
    );
  }

  // This method builds a single tile in the drawer
  Widget _buildDrawerTile(
    BuildContext context,
    IconData icon,
    String title,
    int index,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color:
            selectedIndex == index
                ? const Color.fromARGB(255, 96, 149, 240)
                : Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight:
              selectedIndex == index ? FontWeight.bold : FontWeight.normal,
          color: selectedIndex == index ? Colors.blueAccent : Colors.black,
        ),
      ),
      selected: selectedIndex == index,
      selectedTileColor: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: () {
        Navigator.pop(context);
        onItemSelected(index);
      },
    );
  }
}
