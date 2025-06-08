// lib/widgets/robot_price_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simple/states/totals_notifier.dart'; // Ensure this imports CardInvoiceData

// ModelData class: Each model has its own required description
class ModelData {
  final double price;
  final String imageUrl;
  final String description;

  ModelData({
    required this.price,
    required this.imageUrl,
    required this.description,
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
  // widget.title will be used as the productId for TotalsNotifier
  final String title;
  final double initialPricePerItem;
  final Map<String, ModelData> modelsWithPrices;
  final String imageUrl; // Fallback image for the card itself

  const ProductCard({
    Key? key,
    required this.title,
    required this.initialPricePerItem,
    required this.modelsWithPrices,
    required this.imageUrl,
  }) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final _priceController = TextEditingController();
  String? _selectedModelName; // Name of the currently selected model
  late String _selectedModelImageUrl; // URL of the selected model's image
  late String _currentDescription; // Description of the selected model
  int _itemCount = 0; // Quantity of the item
  double _totalPrice = 0.0; // Local total price for this card's UI (qty * unitPrice)

  List<String> get _modelNames => widget.modelsWithPrices.keys.toList();

  @override
  void initState() {
    super.initState();

    // Initialize local state based on props
    if (widget.modelsWithPrices.isNotEmpty) {
      _selectedModelName = _modelNames[0]; // Default to the first model
      final selectedModelData = widget.modelsWithPrices[_selectedModelName!]!;
      _priceController.text = selectedModelData.price.toStringAsFixed(2);
      _selectedModelImageUrl = selectedModelData.imageUrl;
      _currentDescription = selectedModelData.description;
    } else {
      // Fallback if no models are provided (should ideally not happen with current logic)
      _selectedModelName = null;
      _priceController.text = widget.initialPricePerItem.toStringAsFixed(2);
      _selectedModelImageUrl = widget.imageUrl;
      _currentDescription = "No models available for this product.";
    }
    // _totalPrice will be calculated and set by _updateNotifierWithCurrentState initially

    // Add listener to the price controller to react to manual price changes or model changes
    _priceController.addListener(_onPriceOrQuantityChanged);

    // Perform the initial calculation and notification to TotalsNotifier
    // after the first frame has been built, ensuring context is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { // Ensure the widget is still in the widget tree
        _updateNotifierWithCurrentState();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool mainPropsChanged = widget.title != oldWidget.title ||
        widget.initialPricePerItem != oldWidget.initialPricePerItem ||
        !_mapEquals(widget.modelsWithPrices, oldWidget.modelsWithPrices) ||
        widget.imageUrl != oldWidget.imageUrl;

    if (mainPropsChanged) {
      // If the product identifier (title) changes, remove the old entry from the notifier
      if (widget.title != oldWidget.title && mounted) {
        Provider.of<TotalsNotifier>(context, listen: false).removeCardData(oldWidget.title);
      }

      // Re-initialize local state based on new widget properties
      if (widget.modelsWithPrices.isNotEmpty) {
        String? newSelectedModelName = _selectedModelName;
        // If current selected model is no longer valid or was null, try to pick the first one
        if (newSelectedModelName == null || !widget.modelsWithPrices.containsKey(newSelectedModelName)) {
           if (_modelNames.isNotEmpty) {
            newSelectedModelName = _modelNames[0];
          } else {
            newSelectedModelName = null; // No models to select
          }
        }
        
        // Update local state if a valid model is found
        if (newSelectedModelName != null && widget.modelsWithPrices.containsKey(newSelectedModelName)) {
            final selectedModelData = widget.modelsWithPrices[newSelectedModelName]!;
             // This sequence ensures UI updates correctly BEFORE the listener potentially fires
            _selectedModelName = newSelectedModelName; // Update local state for dropdown
            _priceController.text = selectedModelData.price.toStringAsFixed(2); // Triggers listener
            // Manually set other state vars for UI consistency
            setStateIfMounted(() { // Custom helper to check mounted
              _selectedModelImageUrl = selectedModelData.imageUrl;
              _currentDescription = selectedModelData.description;
            });
        } else {
             // Fallback if no valid model can be selected
            _priceController.text = widget.initialPricePerItem.toStringAsFixed(2);
             setStateIfMounted(() {
                _selectedModelName = null;
                _selectedModelImageUrl = widget.imageUrl;
                _currentDescription = "Error selecting model.";
             });
        }
      } else {
        // Case where the new props have no models
        _priceController.text = widget.initialPricePerItem.toStringAsFixed(2);
        setStateIfMounted(() {
            _selectedModelName = null;
            _selectedModelImageUrl = widget.imageUrl;
            _currentDescription = "No models available for this product.";
        });
      }
      // _updateNotifierWithCurrentState is implicitly called by _priceController's listener
      // or should be called explicitly if the price controller isn't changed but state needs update.
      // For simplicity, relying on priceController listener or next user interaction.
      // A more robust way if priceController text doesn't change:
      if (mounted && (widget.modelsWithPrices.isEmpty || _priceController.text == (widget.initialPricePerItem.toStringAsFixed(2)))) {
          _updateNotifierWithCurrentState();
      }

    } else if (_selectedModelName != null &&
               !widget.modelsWithPrices.containsKey(_selectedModelName) &&
               widget.modelsWithPrices.isNotEmpty && mounted) {
        // If only the selected model became invalid (e.g., models list changed),
        // try to select the first available model.
        _updateStateForSelectedModel(_modelNames[0]);
    }
  }
  
  // Helper to call setState only if widget is mounted
  void setStateIfMounted(VoidCallback fn) {
    if (mounted) {
      setState(fn);
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
    _priceController.removeListener(_onPriceOrQuantityChanged);
    _priceController.dispose();
    // Optional: Notify TotalsNotifier that this card is being removed.
    // This is more critical if cards are dynamically added/removed from the list.
    // For a static list loaded from CSV, it might not be strictly necessary
    // unless you want totals to reflect only currently visible/active cards.
    // Provider.of<TotalsNotifier>(context, listen: false).removeCardData(widget.title);
    super.dispose();
  }

  // This method is called when the price (from text field or model change) or quantity changes.
  // It updates the local total and then notifies the TotalsNotifier.
  void _onPriceOrQuantityChanged() {
    if (mounted) {
      _updateNotifierWithCurrentState();
    }
  }

  // Central method to calculate current state and update the TotalsNotifier
  void _updateNotifierWithCurrentState() {
    if (!mounted) return;

    final double unitPriceForSelected = double.tryParse(_priceController.text) ??
                                      (widget.modelsWithPrices.isNotEmpty && _selectedModelName != null && widget.modelsWithPrices.containsKey(_selectedModelName)
                                          ? widget.modelsWithPrices[_selectedModelName!]!.price
                                          : widget.initialPricePerItem);

    final double currentTotalForCard = unitPriceForSelected * _itemCount;

    // Update the local _totalPrice state if it has changed, to update this card's UI
    if (_totalPrice != currentTotalForCard) {
      setState(() { // This setState is for the _totalPrice display on this card
        _totalPrice = currentTotalForCard;
      });
    }

    // Prepare the detailed data object for the notifier
    final cardData = CardInvoiceData(
      productId: widget.title, // Using the card's title as its unique ID
      productName: widget.title,
      selectedModelName: _selectedModelName, // Could be null if no models
      itemCount: _itemCount,
      unitPrice: unitPriceForSelected,
      currentTotal: currentTotalForCard,
    );

    // Send the updated data to the TotalsNotifier
    // context.read<T>() is shorthand for Provider.of<T>(context, listen: false)
    context.read<TotalsNotifier>().updateCardData(cardData);
  }


  // Called when a new model is selected from the dropdown
  void _updateStateForSelectedModel(String? modelName) {
    if (!mounted) return;
    if (modelName != null && widget.modelsWithPrices.containsKey(modelName)) {
      final modelData = widget.modelsWithPrices[modelName]!;

      // Setting _priceController.text will trigger its listener (_onPriceOrQuantityChanged),
      // which in turn calls _updateNotifierWithCurrentState.
      _priceController.text = modelData.price.toStringAsFixed(2);

      // Update other local state variables that affect this card's UI directly
      // and call setState if they change.
      if (_selectedModelName != modelName ||
          _selectedModelImageUrl != modelData.imageUrl ||
          _currentDescription != modelData.description) {
        setState(() {
          _selectedModelName = modelName;
          _selectedModelImageUrl = modelData.imageUrl;
          _currentDescription = modelData.description;
        });
      }
    }
  }

  void _incrementCount() {
    if (!mounted) return;
    setState(() {
      _itemCount++;
    });
    _onPriceOrQuantityChanged(); // Recalculate and notify
  }

  void _decrementCount() {
    if (!mounted) return;
    if (_itemCount > 0) {
      setState(() {
        _itemCount--;
      });
      _onPriceOrQuantityChanged(); // Recalculate and notify
    }
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Makes the dialog background transparent
          insetPadding: EdgeInsets.all(10), // Padding around the dialog
          child: GestureDetector(
            // Tap anywhere on the full-screen image to close it
            onTap: () => Navigator.of(context).pop(),
            child: InteractiveViewer( // Enables pinch-to-zoom and pan
              panEnabled: true,
              boundaryMargin: EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: Hero( // The destination of the animation
                // The tag must be IDENTICAL to the tag of the starting Hero widget
                tag: imageUrl, 
                child: Image.network(imageUrl),
              ),
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    // This widget only sends updates to TotalsNotifier, it doesn't need to
    // rebuild when TotalsNotifier changes, so no context.watch<TotalsNotifier>() here.
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
                        final modelData = widget.modelsWithPrices[modelName];
                        // Basic safety check, though _modelNames should only contain valid keys
                        if (modelData == null) return DropdownMenuItem<String>(child: Text("Error"), value: modelName);
                        final modelPrice = modelData.price;
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
                    _currentDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Total Price: \$${_totalPrice.toStringAsFixed(2)}', // Displays this card's local total
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
                  Hero(tag: _selectedModelImageUrl, child: GestureDetector(
                      onTap: () => _showFullScreenImage(context, _selectedModelImageUrl),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          _selectedModelImageUrl,
                          height: 100,
                          width: 100,
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
                              color: Colors.grey[300],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
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