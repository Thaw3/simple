import 'package:flutter/material.dart';
import 'package:simple/widgets/robot_price_widgets.dart'; // Adjust path if needed
import 'package:simple/services/robot_csv_handler.dart'; // Adjust path if needed

class RobotPriceCalculator extends StatefulWidget {
  const RobotPriceCalculator({super.key});

  @override
  State<RobotPriceCalculator> createState() => _RobotPriceCalculatorState();
}

class _RobotPriceCalculatorState extends State<RobotPriceCalculator> {
  late Future<List<ProductDataFromCsv>> _productsFuture;
  final CsvProductLoader _loader = CsvProductLoader();
  final String csvAssetPath = 'assets/csv/robot_products.csv'; // Define your CSV path here

  @override
  void initState() {
    super.initState();
    _productsFuture = _loader.loadProductsFromCsv(csvAssetPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<ProductDataFromCsv>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print("FutureBuilder Error: ${snapshot.error}");
            print("FutureBuilder StackTrace: ${snapshot.stackTrace}");
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Error loading product data from '$csvAssetPath'. Please check the console for details and ensure the CSV file is correctly formatted and placed in assets.\nError: ${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[700]),
                ),
              )
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("No products found in '$csvAssetPath'. Please check the CSV file content."),
              )
            );
          } else {
            final products = snapshot.data!;
            return SingleChildScrollView( // Moved SingleChildScrollView here
              padding: const EdgeInsets.all(16),
              child: Column(
                children: products.map((productData) { // Using spread operator for cleaner list building
                    return ProductCard(
                      // Using a unique key is good practice if list items can change dynamically
                      key: ValueKey(productData.title), 
                      title: productData.title,
                      initialPricePerItem: productData.initialPricePerItem,
                      imageUrl: productData.fallbackImageUrl,
                      // No 'description' prop passed to ProductCard here
                      modelsWithPrices: productData.modelsWithPrices,
                    );
                  }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}