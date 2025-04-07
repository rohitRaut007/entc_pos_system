import 'dart:convert';
import 'package:equatable/equatable.dart';
import '../models/order_item.dart';

class Transaction extends Equatable {
  final String id;
  final String customerName;
  final String customerMobile;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime transactionDateTime;

  const Transaction({
    required this.id,
    required this.customerName,
    required this.customerMobile,
    required this.items,
    required this.totalAmount,
    required this.transactionDateTime,
  });

  Transaction copyWith({
    String? id,
    String? customerName,
    String? customerMobile,
    List<OrderItem>? items,
    double? totalAmount,
    DateTime? transactionDateTime,
  }) {
    return Transaction(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerMobile: customerMobile ?? this.customerMobile,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      transactionDateTime: transactionDateTime ?? this.transactionDateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'customerMobile': customerMobile,
      'items': items.map((x) => x.toMap()).toList(),
      'totalAmount': totalAmount,
      'transactionDateTime': transactionDateTime.millisecondsSinceEpoch,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      customerName: map['customerName'] ?? '',
      customerMobile: map['customerMobile'] ?? '',
      items: List<OrderItem>.from(map['items']?.map((x) => OrderItem.fromMap(x))),
      totalAmount: map['totalAmount']?.toDouble() ?? 0.0,
      transactionDateTime: DateTime.fromMillisecondsSinceEpoch(map['transactionDateTime']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Transaction.fromJson(String source) => Transaction.fromMap(json.decode(source));

  @override
  List<Object> get props => [
        id,
        customerName,
        customerMobile,
        items,
        totalAmount,
        transactionDateTime,
      ];

  @override
  String toString() {
    return 'Transaction(id: $id, customerName: $customerName, customerMobile: $customerMobile, items: $items, totalAmount: $totalAmount, transactionDateTime: $transactionDateTime)';
  }
}
