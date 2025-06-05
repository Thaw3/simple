// lib/widgets/invoice_slip_widget.dart
import 'package:flutter/material.dart';
import 'package:simple/states/totals_notifier.dart'; // For CardInvoiceData

class InvoiceSlipWidget extends StatelessWidget {
  final List<CardInvoiceData> items;
  final double grandTotal;

  const InvoiceSlipWidget({
    Key? key,
    required this.items,
    required this.grandTotal,
  }) : super(key: key);

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
          Text(
            'Invoice Summary',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Divider(),
          // Table Header (Optional but good for clarity)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('Item (Model)', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Unit \$', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Total \$', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const Divider(),
          // ListView for scrollable items if there are many
          Flexible( // Use Flexible to allow ListView to take available space within Column
            child: ListView.builder(
              shrinkWrap: true, // Important when ListView is inside Column with MainAxisSize.min
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
                      Expanded(
                        flex: 1,
                        child: Text(item.itemCount.toString(), textAlign: TextAlign.center),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(item.unitPrice.toStringAsFixed(2), textAlign: TextAlign.right),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(item.currentTotal.toStringAsFixed(2), textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GRAND TOTAL:',
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
          SizedBox(height: MediaQuery.of(context).padding.bottom), // Respect safe area at bottom
        ],
      ),
    );
  }
}