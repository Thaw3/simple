import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
// Import ModelData from where ProductCard defines it
import 'package:simple/widgets/robot_price_widgets.dart'; // Adjust path if needed (simple is your package name)

// ProductDataFromCsv class: Does not have a general 'description' field
class ProductDataFromCsv {
  final String title;
  final double initialPricePerItem;
  final Map<String, ModelData> modelsWithPrices; // Each ModelData has its own description
  final String fallbackImageUrl;

  ProductDataFromCsv({
    required this.title,
    required this.initialPricePerItem,
    required this.modelsWithPrices,
    required this.fallbackImageUrl,
  });

  @override
  String toString() {
    return 'ProductDataFromCsv{title: $title, initialPrice: $initialPricePerItem, models: ${modelsWithPrices.length}, fallbackImg: $fallbackImageUrl}';
  }
}

class CsvProductLoader {
  // Expected CSV header: title,initialPricePerItem,fallbackImageUrl,modelName,modelPrice,modelImageUrl,modelDescription
  Future<List<ProductDataFromCsv>> loadProductsFromCsv(String assetPath) async {
    try {
      final String csvString = await rootBundle.loadString(assetPath);
      final List<List<dynamic>> rowsAsListOfValues =
          const CsvToListConverter(eol: '\n', fieldDelimiter: ',').convert(csvString);

      if (rowsAsListOfValues.length < 2) { // Header + at least one data row
        print("CSV file is empty or only has a header: $assetPath");
        return [];
      }

      final Map<String, List<List<dynamic>>> groupedByTitle = {};
      // Skip header row (index 0)
      for (int i = 1; i < rowsAsListOfValues.length; i++) {
        final row = rowsAsListOfValues[i];
        // Expecting 7 columns for: title,initialPricePerItem,fallbackImageUrl,modelName,modelPrice,modelImageUrl,modelDescription
        if (row.length < 7) {
          print("Skipping malformed row in $assetPath (expected 7 columns, got ${row.length}): $row");
          continue;
        }
        final String title = row[0].toString().trim();
        if (title.isEmpty) {
            print("Skipping row with empty title in $assetPath: $row");
            continue;
        }
        groupedByTitle.putIfAbsent(title, () => []).add(row);
      }

      final List<ProductDataFromCsv> products = [];
      groupedByTitle.forEach((title, productRows) {
        if (productRows.isEmpty) return;

        final firstRowInGroup = productRows[0];
        final double initialPrice = double.tryParse(firstRowInGroup[1].toString().trim()) ?? 0.0;
        final String fallbackImage = firstRowInGroup[2].toString().trim();

        final Map<String, ModelData> models = {};
        for (final row in productRows) {
          final String modelName = row[3].toString().trim(); // col 3
          if (modelName.isNotEmpty) {
            final double? modelPrice = double.tryParse(row[4].toString().trim()); // col 4
            final String modelImageUrl = row[5].toString().trim(); // col 5
            final String modelSpecificDescription = row[6].toString().trim(); // col 6

            if (modelPrice != null && modelImageUrl.isNotEmpty && modelSpecificDescription.isNotEmpty) {
              models[modelName] = ModelData(
                price: modelPrice,
                imageUrl: modelImageUrl,
                description: modelSpecificDescription, // Now required by ModelData
              );
            } else {
              print("Warning: Incomplete model data for '$title' - '$modelName' in $assetPath (price, image, or description missing/empty). Skipping this model.");
            }
          }
        }
        
        if (models.isEmpty) {
            print("Warning: Product '$title' from $assetPath has no valid models after parsing. Skipping product.");
            return; // Skip adding this product if it has no valid models
        }

        String finalFallbackImage = fallbackImage.isNotEmpty ? fallbackImage : "https://via.placeholder.com/150?text=No+Image";

        products.add(
          ProductDataFromCsv(
            title: title,
            initialPricePerItem: initialPrice,
            fallbackImageUrl: finalFallbackImage,
            modelsWithPrices: models,
          ),
        );
      });
      print("Successfully loaded ${products.length} products from $assetPath.");
      return products;
    } catch (e, s) {
      print("Error loading or parsing CSV from $assetPath: $e");
      print("Stacktrace: $s");
      return [];
    }
  }
}