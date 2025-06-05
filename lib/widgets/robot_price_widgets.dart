import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter

// ModelData class: Each model has its own required description
class ModelData {
  final double price;
  final String imageUrl;
  final String description; // Non-nullable: Each model has its own description

  ModelData({
    required this.price,
    required this.imageUrl,
    required this.description, // Required
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelData &&
          runtimeType == other.runtimeType &&
          price == other.price &&
          imageUrl == other.imageUrl &&
          description == other.description;

  @override
  int get hashCode => price.hashCode ^ imageUrl.hashCode ^ description.hashCode;
}

class ProductCard extends StatefulWidget {
  final String title;
  final double initialPricePerItem; // Fallback if modelsWithPrices is empty
  final Map<String, ModelData> modelsWithPrices; // Each ModelData contains its own description
  final String imageUrl; // Fallback image for the card itself

  const ProductCard({
    Key? key,
    required this.title,
    required this.initialPricePerItem,
    required this.modelsWithPrices,
    required this.imageUrl, // No general description prop
  }) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final _priceController = TextEditingController();
  String? _selectedModelName;
  late String _selectedModelImageUrl;
  late String _currentDescription; // Will always come from the selected ModelData
  int _itemCount = 0;
  double _totalPrice = 0.0;

  List<String> get _modelNames => widget.modelsWithPrices.keys.toList();

  @override
  void initState() {
    super.initState();

    if (widget.modelsWithPrices.isNotEmpty) {
      _selectedModelName = _modelNames[0];
      final selectedModelData = widget.modelsWithPrices[_selectedModelName!]!;
      _priceController.text = selectedModelData.price.toStringAsFixed(2);
      _selectedModelImageUrl = selectedModelData.imageUrl;
      _currentDescription = selectedModelData.description; // Directly from model
    } else {
      // This case implies the product has no models defined in the CSV,
      // or all models were invalid during parsing.
      _selectedModelName = null;
      _priceController.text = widget.initialPricePerItem.toStringAsFixed(2);
      _selectedModelImageUrl = widget.imageUrl;
      _currentDescription = "No models available for this product."; // Fallback description
      print("WARNING: ProductCard for '${widget.title}' has no models. Using fallback values.");
    }

    _priceController.addListener(_calculateTotalPrice);
    _calculateTotalPrice();
  }

  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool mainPropsChanged = widget.initialPricePerItem != oldWidget.initialPricePerItem ||
        !_mapEquals(widget.modelsWithPrices, oldWidget.modelsWithPrices) ||
        widget.imageUrl != oldWidget.imageUrl;

    if (mainPropsChanged) {
      if (widget.modelsWithPrices.isNotEmpty) {
        String? newSelectedModelName = _selectedModelName;
        if (newSelectedModelName == null || !widget.modelsWithPrices.containsKey(newSelectedModelName)) {
          newSelectedModelName = _modelNames[0];
        }
        _selectedModelName = newSelectedModelName;

        final selectedModelData = widget.modelsWithPrices[_selectedModelName!]!;
        _priceController.text = selectedModelData.price.toStringAsFixed(2);
        _selectedModelImageUrl = selectedModelData.imageUrl;
        _currentDescription = selectedModelData.description;
      } else {
        _selectedModelName = null;
        _priceController.text = widget.initialPricePerItem.toStringAsFixed(2);
        _selectedModelImageUrl = widget.imageUrl;
        _currentDescription = "No models available for this product.";
      }
      _calculateTotalPrice();
    }
  }

  bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final K key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) {
        return false;
      }
    }
    return true;
  }

  @override
  void dispose() {
    _priceController.removeListener(_calculateTotalPrice);
    _priceController.dispose();
    super.dispose();
  }

  void _calculateTotalPrice() {
    final price = double.tryParse(_priceController.text) ?? 0.0;
    setState(() {
      _totalPrice = price * _itemCount;
    });
  }

  void _updateStateForSelectedModel(String? modelName) {
    if (modelName != null && widget.modelsWithPrices.containsKey(modelName)) {
      setState(() {
        _selectedModelName = modelName;
        final modelData = widget.modelsWithPrices[modelName]!;
        _priceController.text = modelData.price.toStringAsFixed(2);
        _selectedModelImageUrl = modelData.imageUrl;
        _currentDescription = modelData.description; // Directly from model
      });
    }
  }

  void _incrementCount() {
    setState(() {
      _itemCount++;
      _calculateTotalPrice();
    });
  }

  void _decrementCount() {
    if (_itemCount > 0) {
      setState(() {
        _itemCount--;
        _calculateTotalPrice();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Side
            Expanded(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: widget.modelsWithPrices.isNotEmpty
                          ? 'Price (selected model)'
                          : 'Price per item',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),
                  SizedBox(height: 8),
                  if (widget.modelsWithPrices.isNotEmpty)
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Choose Model',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      value: _selectedModelName,
                      items: _modelNames.map((String modelName) {
                        final modelPrice = widget.modelsWithPrices[modelName]!.price;
                        return DropdownMenuItem<String>(
                          value: modelName,
                          child: Text(
                            '$modelName (\$${modelPrice.toStringAsFixed(2)})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        _updateStateForSelectedModel(newValue);
                      },
                      isExpanded: true,
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'No specific models to choose from.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  SizedBox(height: 8),
                  Text(
                    _currentDescription, // Uses the model-specific description
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                    maxLines: 4, // Allow more lines for description
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Total Price: \$${_totalPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green[700],
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            // Right Side
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      _selectedModelImageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, size: 40, color: Colors.grey[600]),
                              SizedBox(height: 4),
                              Text("Image not found", style: TextStyle(fontSize: 10, color: Colors.grey[600]))
                            ],
                          ),
                        );
                      },
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 120,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Quantity:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: _decrementCount,
                        color: Theme.of(context).colorScheme.primary,
                        tooltip: "Decrease quantity",
                      ),
                      SizedBox(width: 4),
                      Text(
                        '$_itemCount',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18),
                      ),
                      SizedBox(width: 4),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline),
                        onPressed: _incrementCount,
                        color: Theme.of(context).colorScheme.primary,
                        tooltip: "Increase quantity",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}