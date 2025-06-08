// lib/widgets/invoice_slip_widget.dart
import 'package:flutter/material.dart';
// This import now gives us access to both CardInvoiceData and MissingItemInfo
import 'package:simple/states/totals_notifier.dart';

class InvoiceSlipWidget extends StatelessWidget {
  // --- START: UPDATED PROPERTIES ---
  // This widget now accepts two separate lists.
  final List<CardInvoiceData> selectedItems;
  final List<MissingItemInfo> missingItems;
  final double grandTotal;

  const InvoiceSlipWidget({
    Key? key,
    required this.selectedItems,
    required this.missingItems,
    required this.grandTotal,
  }) : super(key: key);
  // --- END: UPDATED PROPERTIES ---

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, -3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Important for BottomSheet
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- START: UPDATED UI LOGIC ---
          Text(
            'Components List', // A more descriptive title
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Section 1: Display the items the user has already selected.
          // This only shows up if they've selected at least one item.
          if (selectedItems.isNotEmpty) ...[
            Text('Selected Components:', style: Theme.of(context).textTheme.titleMedium),
            _buildSelectedItemsTable(context, selectedItems),
            const SizedBox(height: 24),
          ],

          // Section 2: Display the required items the user still needs to add.
          // This only shows up if there are any missing required items.
          if (missingItems.isNotEmpty) ...[
            Text(
              'Required Components to Add:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red.shade700)
            ),
            _buildMissingItemsList(context, missingItems),
            const SizedBox(height: 24),
          ],

          // A helpful message if the cart is completely empty.
          if (selectedItems.isEmpty && missingItems.isNotEmpty)
             Padding(
               padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
               child: Text(
                 "Your configuration is empty. Please add components to build your robot.",
                 textAlign: TextAlign.center,
                 style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
               ),
             ),

          // Section 3: Display the total price of the selected items.
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CURRENT TOTAL:', // Changed from 'GRAND TOTAL'
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${grandTotal.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the bottom sheet
            },
            child: const Text('Close'),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
          // --- END: UPDATED UI LOGIC ---
        ],
      ),
    );
  }

  /// Helper widget to build the table for items that have been selected.
  /// This keeps the main `build` method clean.
  Widget _buildSelectedItemsTable(BuildContext context, List<CardInvoiceData> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        // Table Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text('Item (Model)', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text('Total \$', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        const Divider(),
        // Item Rows
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // Important: The parent is already scrollable
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.productName, style: TextStyle(fontWeight: FontWeight.w500)),
                        if (item.selectedModelName != null && item.selectedModelName!.isNotEmpty)
                          Text(item.selectedModelName!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  Expanded(flex: 1, child: Text(item.itemCount.toString(), textAlign: TextAlign.center)),
                  Expanded(flex: 2, child: Text(item.currentTotal.toStringAsFixed(2), textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w500))),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// Helper widget to build the list of missing required items.
  Widget _buildMissingItemsList(BuildContext context, List<MissingItemInfo> items) {
    return Column(
      children: [
        const Divider(color: Colors.red, thickness: 1),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item.name, style: TextStyle(fontWeight: FontWeight.w500))),
                  const SizedBox(width: 8),
                  // This displays the helpful "Need X more" text
                  Text('Need ${item.numberStillNeeded} more', style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}