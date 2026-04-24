// lib/models/sale_model.dart
// Represents a single sale transaction

class Sale {
  final int? id;
  final int productId;
  final String productName;   
  final int quantity;
  final double totalPrice;
  final DateTime date;
  final bool isCredit;       

  const Sale({
    this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.totalPrice,
    required this.date,
    this.isCredit = false,
  });

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] as int?,
      productId: map['productId'] as int,
      productName: map['productName'] as String? ?? '',
      quantity: map['quantity'] as int,
      totalPrice: (map['totalPrice'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      isCredit: (map['isCredit'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'date': date.toIso8601String(),
      'isCredit': isCredit ? 1 : 0,
    };
  }
}


// lib/models/customer_model.dart
// Represents a customer who buys on credit

class Customer {
  final int? id;
  final String name;
  final String phone;
  final String address;
  final int avatarIndex;      // 0-3 for avatar selection
  final DateTime createdAt;

  const Customer({
    this.id,
    required this.name,
    required this.phone,
    this.address = '',
    this.avatarIndex = 0,
    required this.createdAt,
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String? ?? '',
      avatarIndex: map['avatarIndex'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'avatarIndex': avatarIndex,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Customer copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    int? avatarIndex,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


// lib/models/credit_model.dart
// Represents a credit entry (debt or payment)

class Credit {
  final int? id;
  final int customerId;
  final int? saleId;          // Linked sale (null for manual payment entries)
  final double amount;        // Positive = debt, Negative = payment
  final bool isPaid;
  final DateTime date;
  final String note;          // "Credit Given" or "Payment Received"

  const Credit({
    this.id,
    required this.customerId,
    this.saleId,
    required this.amount,
    this.isPaid = false,
    required this.date,
    this.note = '',
  });

  factory Credit.fromMap(Map<String, dynamic> map) {
    return Credit(
      id: map['id'] as int?,
      customerId: map['customerId'] as int,
      saleId: map['saleId'] as int?,
      amount: (map['amount'] as num).toDouble(),
      isPaid: (map['isPaid'] as int) == 1,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'customerId': customerId,
      'saleId': saleId,
      'amount': amount,
      'isPaid': isPaid ? 1 : 0,
      'date': date.toIso8601String(),
      'note': note,
    };
  }
}


// lib/models/customer_summary.dart
// Aggregated view of a customer's credit status

class CustomerSummary {
  final Customer customer;
  final double totalCredit;       // Sum of all credits given
  final double totalPaid;         // Sum of all payments received
  final DateTime? lastActivityDate;

  const CustomerSummary({
    required this.customer,
    required this.totalCredit,
    required this.totalPaid,
    this.lastActivityDate,
  });

  /// Current outstanding balance
  double get outstanding => totalCredit - totalPaid;

  /// True if customer has no pending amount
  bool get isCleared => outstanding <= 0;

  /// Days since last activity
  int get daysPending {
    if (lastActivityDate == null) return 0;
    return DateTime.now().difference(lastActivityDate!).inDays;
  }
}
