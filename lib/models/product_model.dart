// lib/models/product_model.dart
class Product {
  final int? id;
  final String name;
  final String category;
  final double costPrice;
  final double sellingPrice;
  final int quantity;
  final int lowStockThreshold;
  final String imageEmoji; // Category emoji used as visual identifier

  const Product({
    this.id,
    required this.name,
    required this.category,
    required this.costPrice,
    required this.sellingPrice,
    required this.quantity,
    this.lowStockThreshold = 10,
    this.imageEmoji = '',
  });

  bool get isLowStock => quantity > 0 && quantity <= lowStockThreshold;
  bool get isOutOfStock => quantity <= 0;
  double get stockValue => costPrice * quantity;

  /// Returns emoji based on category for product visual
  String get displayEmoji {
    if (imageEmoji.isNotEmpty) return imageEmoji;
    switch (category.toLowerCase()) {
      case 'drinks': return '🥤';
      case 'snacks': return '🍪';
      case 'grocery': return '🛒';
      case 'dairy': return '🥛';
      case 'vegetables': return '🥦';
      case 'fruits': return '🍎';
      case 'medicine': return '💊';
      default: return '📦';
    }
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      costPrice: (map['costPrice'] as num).toDouble(),
      sellingPrice: (map['sellingPrice'] as num).toDouble(),
      quantity: map['quantity'] as int,
      lowStockThreshold: map['lowStockThreshold'] as int? ?? 10,
      imageEmoji: map['imageEmoji'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category': category,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'quantity': quantity,
      'lowStockThreshold': lowStockThreshold,
      'imageEmoji': imageEmoji,
    };
  }

  Product copyWith({
    int? id, String? name, String? category,
    double? costPrice, double? sellingPrice,
    int? quantity, int? lowStockThreshold, String? imageEmoji,
  }) {
    return Product(
      id: id ?? this.id, name: name ?? this.name,
      category: category ?? this.category,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      quantity: quantity ?? this.quantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      imageEmoji: imageEmoji ?? this.imageEmoji,
    );
  }
}
