import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple/states/totals_notifier.dart'; // For TotalsNotifier and CardInvoiceData
import 'package:simple/widgets/robot_price_widgets.dart'; // For ProductCard
import 'package:simple/services/robot_csv_handler.dart'; // For CsvProductLoader and ProductDataFromCsv
import 'package:simple/widgets/invoice_slip_widget.dart'; // For InvoiceSlipWidget

// This StatelessWidget sets up the ChangeNotifierProvider at the root of this page/feature.
class RobotPriceCalculatorPage extends StatelessWidget {
  const RobotPriceCalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TotalsNotifier(),
      child: const RobotPriceCalculatorView(), // The actual UI and logic
    );
  }
}

// This StatefulWidget contains the main view logic for displaying products and the FAB.
class RobotPriceCalculatorView extends StatefulWidget {
  const RobotPriceCalculatorView({super.key});

  @override
  State<RobotPriceCalculatorView> createState() => _RobotPriceCalculatorViewState();
}

class _RobotPriceCalculatorViewState extends State<RobotPriceCalculatorView> {
  late Future<List<ProductDataFromCsv>> _productsFuture;
  final CsvProductLoader _loader = CsvProductLoader();
  final String csvAssetPath = 'assets/csv/robot_products.csv'; // Define your CSV path

  @override
  void initState() {
    super.initState();
    // Load product data from CSV when the widget is initialized
    _productsFuture = _loader.loadProductsFromCsv(csvAssetPath);
  }

  // Method to display the invoice slip using a modal bottom sheet
  void _showInvoiceSlip(BuildContext context) {
    // Access the TotalsNotifier to get the current state of all card data
    // listen: false because we are only reading the data once to build the invoice,
    // not reacting to live changes within this specific method.
    final totalsNotifier = Provider.of<TotalsNotifier>(context, listen: false);

    // Get all card data and filter out items that haven't been interacted with
    // (e.g., quantity is still 0 or default, or total is 0)
    final List<CardInvoiceData> invoiceItems = totalsNotifier.allCardDataForInvoice
        .where((data) => data.itemCount > 0 && data.currentTotal > 0)
        .toList();

    // Get the calculated grand total from the notifier
    final List<MissingItemInfo> missingItems = totalsNotifier.missingRequiredItems;

    final double grandTotal = totalsNotifier.grandTotal;

    // If there are no items to show in the invoice, display a SnackBar message
    if (invoiceItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No items selected to display in invoice.')),
        );
        return; // Don't show the bottom sheet if there's nothing to display
    }

    // Show the modal bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to take up more screen height
      backgroundColor: Colors.transparent, // Make the sheet's background transparent to see custom container's rounded corners
      builder: (BuildContext bottomSheetContext) { // Use a different context name to avoid shadowing
        // DraggableScrollableSheet provides better control over height and drag behavior
        return DraggableScrollableSheet(
          initialChildSize: 0.8, // Start at 80% of the screen height
          minChildSize: 0.3,   // Minimum height the sheet can be dragged down to
          maxChildSize: 0.9,   // Maximum height the sheet can be dragged up to
          expand: false,       // The sheet does not expand to fill the entire screen initially
          builder: (_, scrollController) {
            // The content inside DraggableScrollableSheet needs to be scrollable itself
            // if it might exceed the sheet's current size.
            return SingleChildScrollView(
              controller: scrollController, // Pass the controller for drag-to-scroll behavior
              child: InvoiceSlipWidget(
                selectedItems: invoiceItems,
                missingItems: missingItems,
                grandTotal: grandTotal,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar was removed as per previous request
      body: FutureBuilder<List<ProductDataFromCsv>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Handle error state
          else if (snapshot.hasError) {
            print("FutureBuilder Error in RobotPriceCalculatorView: ${snapshot.error}");
            print("Stacktrace: ${snapshot.stackTrace}");
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Error loading product data from '$csvAssetPath'.\nPlease check the console for details.\nError: ${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[700]),
                ),
              )
            );
          }
          // Handle no data or empty data state
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
             return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("No products found in '$csvAssetPath'. Please check the CSV file content."),
              )
            );
          }
          // Handle successful data loading
          else {
            final products = snapshot.data!;
            return SingleChildScrollView(
              // Add padding around the list and extra at the bottom for the FAB
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              child: Column(
                children: products.map((productData) {
                    // Each ProductCard will use its 'title' to communicate with TotalsNotifier
                    return ProductCard(
                      key: ValueKey(productData.title), // Unique key for widget identity
                      title: productData.title,
                      initialPricePerItem: productData.initialPricePerItem,
                      imageUrl: productData.fallbackImageUrl,
                      modelsWithPrices: productData.modelsWithPrices,
                      // onTotalUpdated callback is no longer needed;
                      // ProductCard now interacts with TotalsNotifier directly via Provider
                    );
                  }).toList(),
              ),
            );
          }
        },
      ),
      // Floating Action Button to show the invoice slip
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showInvoiceSlip(context), // Call the method to display the bottom sheet
        icon: const Icon(Icons.receipt_long_outlined), // Icon for the FAB
        label: const Text("View Invoice"),       // Text label for the FAB
        tooltip: "View invoice summary",       // Tooltip for accessibility
      ),
      // Position of the Floating Action Button
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat, // Positioned at the bottom right corner
    );
  }
}