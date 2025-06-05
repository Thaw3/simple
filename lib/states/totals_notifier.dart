// lib/state/totals_notifier.dart
import 'package:flutter/foundation.dart'; // For ChangeNotifier

class CardInvoiceData {
  final String productId;
  final String productName; // The main title from ProductCard
  final String? selectedModelName;
  final int itemCount;
  final double unitPrice; // Price of the selected model
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
  // Map to store detailed data from each ProductCard instance
  // Key: productId (e.g., product title)
  final Map<String, CardInvoiceData> _cardDataMap = {};

  double get grandTotal {
    double sum = 0.0;
    _cardDataMap.forEach((key, data) {
      sum += data.currentTotal;
    });
    return sum;
  }

  // Getter to get all card data for building the invoice
  List<CardInvoiceData> get allCardDataForInvoice => _cardDataMap.values.toList();

  // Method for ProductCard to update its detailed data
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