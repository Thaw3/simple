import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:simple/widgets/robot_price_widgets.dart';

// --- RENAMED: Data Model ---
// Renamed from ProductDataFromCsv to the more generic 'Product'.
class Product {
  final String title;
  final double initialPricePerItem;
  final Map<String, ModelData> modelsWithPrices;
  final String fallbackImageUrl;

  Product({
    required this.title,
    required this.initialPricePerItem,
    required this.modelsWithPrices,
    required this.fallbackImageUrl,
  });

  @override
  String toString() {
    return 'Product{title: $title, initialPrice: $initialPricePerItem, models: ${modelsWithPrices.length}, fallbackImg: $fallbackImageUrl}';
  }
}

// --- RENAMED: JSON-only Loader ---
// This is the template-like handler, renamed from JsonProductLoader to ProductLoader.
class ProductLoader {
  /// Loads and parses a list of products from a JSON asset file.
  Future<List<Product>> loadProducts(String assetPath) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> productListJson = json.decode(jsonString);

      if (productListJson.isEmpty) {
        print("JSON file is empty: $assetPath");
        return [];
      }

      final List<Product> products = [];

      for (final productJson in productListJson) {
        if (productJson is! Map<String, dynamic>) {
          print("Warning: Skipping non-object item in JSON array from $assetPath");
          continue;
        }

        final String title = (productJson['title'] as String?)?.trim() ?? '';
        final double initialPrice = (productJson['initialPricePerItem'] as num?)?.toDouble() ?? 0.0;
        final String fallbackImageUrl = (productJson['fallbackImageUrl'] as String?)?.trim() ?? '';

        if (title.isEmpty) {
          print("Warning: Skipping product with empty title in $assetPath");
          continue;
        }

        final Map<String, ModelData> models = {};
        final List<dynamic>? modelsJson = productJson['models'] as List<dynamic>?;

        if (modelsJson != null && modelsJson.isNotEmpty) {
          for (final modelJson in modelsJson) {
            if (modelJson is! Map<String, dynamic>) {
              print("Warning: Skipping non-object item in 'models' list for product '$title' in $assetPath");
              continue;
            }

            final String modelName = (modelJson['modelName'] as String?)?.trim() ?? '';
            final double? modelPrice = (modelJson['modelPrice'] as num?)?.toDouble();
            final String modelImageUrl = (modelJson['modelImageUrl'] as String?)?.trim() ?? '';
            final String modelDescription = (modelJson['modelDescription'] as String?)?.trim() ?? '';

            if (modelName.isNotEmpty && modelPrice != null && modelImageUrl.isNotEmpty && modelDescription.isNotEmpty) {
              models[modelName] = ModelData(
                price: modelPrice,
                imageUrl: modelImageUrl,
                description: modelDescription,
              );
            } else {
              print("Warning: Incomplete model data for '$title' - '$modelName' in $assetPath. Skipping this model.");
            }
          }
        }

        if (models.isEmpty) {
          print("Warning: Product '$title' from $assetPath has no valid models. Skipping product.");
          continue;
        }

        String finalFallbackImage = fallbackImageUrl.isNotEmpty ? fallbackImageUrl : "https://via.placeholder.com/150?text=No+Image";

        products.add(
          Product( // Using the new 'Product' class
            title: title,
            initialPricePerItem: initialPrice,
            fallbackImageUrl: finalFallbackImage,
            modelsWithPrices: models,
          ),
        );
      }

      print("Successfully loaded ${products.length} products from $assetPath.");
      return products;
    } catch (e, s) {
      print("Error loading or parsing JSON from $assetPath: $e");
      print("Stacktrace: $s");
      return [];
    }
  }
}