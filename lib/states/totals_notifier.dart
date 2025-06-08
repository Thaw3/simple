// lib/states/totals_notifier.dart
import 'package:flutter/foundation.dart';

/// A helper class to store information about a required item
/// that the user has not selected enough of.
class MissingItemInfo {
  final String name;
  final int requiredCount;
  final int selectedCount;

  /// A computed property to easily see how many more are needed.
  int get numberStillNeeded => requiredCount - selectedCount;

  MissingItemInfo({
    required this.name,
    required this.requiredCount,
    required this.selectedCount,
  });
}

/// A data class holding all the information for a single line item
/// that the user has added to their configuration.
class CardInvoiceData {
  final String productId;
  final String productName;
  final String? selectedModelName;
  final int itemCount;
  final double unitPrice;
  final double currentTotal;

  CardInvoiceData({
    required this.productId,
    required this.productName,
    this.selectedModelName,
    required this.itemCount,
    required this.unitPrice,
    required this.currentTotal,
  });
}

class TotalsNotifier extends ChangeNotifier {
  final Map<String, CardInvoiceData> _cardDataMap = {};

  // =======================================================================
  // == THIS IS THE MAIN PLACE TO EDIT YOUR RULES ==
  // =======================================================================
  static const Map<String, int> _requiredCategoryCounts = {
    'IMU': 1,
    'GPS': 1,
    'Lidar': 1,
    'Servo Hub Motor': 2, // Example: The robot needs at least 2 motors
    'Mother Board': 1,
    'Robot Controller': 1,
    'Camera': 2, // Example: The robot needs at least 2 cameras
    'Battery & Docking System': 1,
    'Robot Design & Body parts': 1,
    // Add or remove lines here to change your configuration rules.
    // For example, if you didn't need a Lidar, you could comment out that line.
  };
  // =======================================================================


  // --- NEW GETTERS FOR THE UI ---

  /// Returns a list of items the user has actually selected (quantity > 0).
  /// This is for the "Selected Components" section of your invoice.
  List<CardInvoiceData> get selectedItems {
    return _cardDataMap.values.where((data) => data.itemCount > 0).toList();
  }

  List<MissingItemInfo> get missingRequiredItems {
    final List<MissingItemInfo> missing = [];

    // Step 1: Create a tally of how many items from each category have been selected.
    final Map<String, int> selectedCategoryCounts = {};
    for (var item in selectedItems) {
      selectedCategoryCounts.update(
        item.productName,
        (value) => value + item.itemCount, // Add to the existing count
        ifAbsent: () => item.itemCount,      // Or set the initial count
      );
    }
    _requiredCategoryCounts.forEach((requiredName, requiredCount) {
      final selectedCount = selectedCategoryCounts[requiredName] ?? 0;

      if (selectedCount < requiredCount) {
        missing.add(
          MissingItemInfo(
            name: requiredName,
            requiredCount: requiredCount,
            selectedCount: selectedCount,
          ),
        );
      }
    });

    return missing;
  }


  double get grandTotal {
    double sum = 0.0;
    _cardDataMap.forEach((key, data) {
      sum += data.currentTotal;
    });
    return sum;
  }

  /// A simple getter for all card data, regardless of quantity.
  /// Note: You will likely use `selectedItems` and `missingRequiredItems` more often now.
  List<CardInvoiceData> get allCardDataForInvoice => _cardDataMap.values.toList();


  void updateCardData(CardInvoiceData newData) {
    bool needsNotify = false;
    if (!_cardDataMap.containsKey(newData.productId) ||
        _cardDataMap[newData.productId]?.currentTotal != newData.currentTotal ||
        _cardDataMap[newData.productId]?.itemCount != newData.itemCount ||
        _cardDataMap[newData.productId]?.selectedModelName != newData.selectedModelName
        ) {
      _cardDataMap[newData.productId] = newData;
      needsNotify = true;
    }

    if (needsNotify) {
      notifyListeners();
    }
  }

  void removeCardData(String productId) {
    if (_cardDataMap.containsKey(productId)) {
      _cardDataMap.remove(productId);
      notifyListeners();
    }
  }
}