import 'package:simple/widgets/data_set_collector_widget.dart';
import 'package:flutter/material.dart';

class DatasetCollector extends StatefulWidget {
  const DatasetCollector({super.key});

  @override
  State<DatasetCollector> createState() => _DatasetCollectorState();
}

class _DatasetCollectorState extends State<DatasetCollector> {
  int Epochs = 10;
  final List<int> custom_Batch_Sizes = [16, 32, 64, 128, 256, 512];
  int Batch_Index = 0;
  double Learning_Rate = 0.00001; // Default learning rate
  List<String> classes = ['Class 1', 'Class 2']; // List of class names

  void removeClass(String className) {
    setState(() {
      classes.remove(className); // Remove the class from the list
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$className deleted')));
  }

  void addNewClass() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController classNameController = TextEditingController(
          text: "Class ${classes.length + 1}",
        );
        return AlertDialog(
          title: const Text('Add New Class'),
          content: TextField(
            controller: classNameController,
            decoration: const InputDecoration(hintText: 'Enter new class name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  classes.add(classNameController.text); // Add the new class
                });
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          classBuilder(),
          const SizedBox(height: 20),
          Training_Builder(),
          const SizedBox(height: 20),
          Preview_Builder(),
        ],
      ),
    );
  }

  Widget Preview_Builder() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text(
              "Preview",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Train your model to see predictions here.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Start Preview"),
            ),
          ],
        ),
      ),
    );
  }

  Widget Training_Builder() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    "Training",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text("Train Model", style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Each class needs at least one sample to train.",
                    style: TextStyle(fontSize: 12, color: Colors.red[600]),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Advanced",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.arrow_drop_down),
                                onPressed: () {
                                  // Refresh logic here
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Epochs"),
                                  Text(Epochs.toString()),
                                ],
                              ),
                              Slider(
                                value: Epochs.toDouble(),
                                min: 10,
                                max: 200,
                                divisions: 19,
                                onChanged: (double value) {
                                  setState(() {
                                    Epochs = value.toInt();
                                  });
                                },
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Batch Size"),
                                  Text(
                                    custom_Batch_Sizes[Batch_Index].toString(),
                                  ),
                                ],
                              ),
                              Slider(
                                value: Batch_Index.toDouble(),
                                min: 0,
                                max: (custom_Batch_Sizes.length - 1).toDouble(),
                                divisions: custom_Batch_Sizes.length - 1,
                                onChanged: (double value) {
                                  setState(() {
                                    Batch_Index = value.toInt();
                                  });
                                },
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Learning Rate"),
                                  Text(Learning_Rate.toStringAsFixed(5)),
                                ],
                              ),
                              Slider(
                                value: Learning_Rate.toDouble(),
                                min: 0.00001,
                                max: 0.1,
                                onChanged: (double value) {
                                  setState(() {
                                    Learning_Rate = value.toDouble();
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Other Actions"),
                              PopupMenuButton(
                                itemBuilder:
                                    (context) => [
                                      const PopupMenuItem(child: Text("")),
                                    ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget classBuilder() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Classes",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: classes.length,
              itemBuilder: (context, index) {
                return ClassWidget(
                  className: classes[index],
                  onDelete: removeClass, // Pass the callback to delete a class
                );
              },
            ),

            const SizedBox(height: 10),

            Center(
              child: ElevatedButton(
                onPressed: addNewClass,
                child: Text("Add a Class"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
