class Product {
  final int? id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String? description;
  final String? createdAt;
  final int? soldCount;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.description,
    this.createdAt,
    this.soldCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'description': description,
      'createdAt': createdAt ?? DateTime.now().toIso8601String(),
      'soldCount': soldCount ?? 0,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      price: map['price'],
      stock: map['stock'],
      description: map['description'],
      createdAt: map['createdAt'],
      soldCount: map['soldCount'] ?? 0,
    );
  }

  Product copyWith({
    int? id,
    String? name,
    String? category,
    double? price,
    int? stock,
    String? description,
    String? createdAt,
    int? soldCount,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      soldCount: soldCount ?? this.soldCount,
    );
  }
}
