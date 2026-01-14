class Transaction {
  final int? id;
  final String transactionCode;
  final DateTime transactionDate;
  final double totalAmount;
  final int totalItems;
  final String? customerName;
  final String? notes;

  Transaction({
    this.id,
    required this.transactionCode,
    required this.transactionDate,
    required this.totalAmount,
    required this.totalItems,
    this.customerName,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionCode': transactionCode,
      'transactionDate': transactionDate.toIso8601String(),
      'totalAmount': totalAmount,
      'totalItems': totalItems,
      'customerName': customerName,
      'notes': notes,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      transactionCode: map['transactionCode'],
      transactionDate: DateTime.parse(map['transactionDate']),
      totalAmount: map['totalAmount'],
      totalItems: map['totalItems'],
      customerName: map['customerName'],
      notes: map['notes'],
    );
  }

  Transaction copyWith({
    int? id,
    String? transactionCode,
    DateTime? transactionDate,
    double? totalAmount,
    int? totalItems,
    String? customerName,
    String? notes,
  }) {
    return Transaction(
      id: id ?? this.id,
      transactionCode: transactionCode ?? this.transactionCode,
      transactionDate: transactionDate ?? this.transactionDate,
      totalAmount: totalAmount ?? this.totalAmount,
      totalItems: totalItems ?? this.totalItems,
      customerName: customerName ?? this.customerName,
      notes: notes ?? this.notes,
    );
  }
}

class TransactionItem {
  final int? id;
  final int transactionId;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final double subtotal;

  TransactionItem({
    this.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionId': transactionId,
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'],
      transactionId: map['transactionId'],
      productId: map['productId'],
      productName: map['productName'],
      price: map['price'],
      quantity: map['quantity'],
      subtotal: map['subtotal'],
    );
  }

  TransactionItem copyWith({
    int? id,
    int? transactionId,
    int? productId,
    String? productName,
    double? price,
    int? quantity,
    double? subtotal,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      subtotal: subtotal ?? this.subtotal,
    );
  }
}

class CartItem {
  final int productId;
  final String productName;
  final double price;
  int quantity;
  final int availableStock;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.availableStock,
  });

  double get subtotal => price * quantity;
}
