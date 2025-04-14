import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'order_item.dart';

part 'sale_order.g.dart';

@HiveType(typeId: 15)
class SaleOrder extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String date;

  @HiveField(2)
  String time;

  @HiveField(3)
  String customerName;

  @HiveField(4)
  String customerMobile;

  @HiveField(5)
  List<OrderItem> items;

  @HiveField(6)
  double orderAmount;

  @HiveField(7)
  String transactionId;

  @HiveField(8)
  bool transactionSynced;

  @HiveField(9)
  DateTime transactionDateTime;

  @HiveField(10, defaultValue: "")
  String paymentMethod;

  @HiveField(11, defaultValue: "Unpaid")
  String paymentStatus;

  @HiveField(12, defaultValue: 0.0)
  double paidAmount;

  @HiveField(13, defaultValue: 0.0)
  double creditAmount;

  @HiveField(14, defaultValue: false)
  bool isSettled;

  @HiveField(15, defaultValue: "")
  String parkOrderId;

  @HiveField(16)
  DateTime? settlementDateTime;

  SaleOrder({
    required this.id,
    required this.date,
    required this.time,
    required this.customerName,
    required this.customerMobile,
    required this.items,
    required this.orderAmount,
    required this.transactionId,
    required this.transactionSynced,
    required this.transactionDateTime,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paidAmount,
    required this.creditAmount,
    this.isSettled = false,
    this.parkOrderId = '',
    this.settlementDateTime,
  });

  SaleOrder copyWith({
    String? id,
    String? date,
    String? time,
    String? customerName,
    String? customerMobile,
    List<OrderItem>? items,
    double? orderAmount,
    String? transactionId,
    bool? transactionSynced,
    DateTime? transactionDateTime,
    String? paymentMethod,
    String? paymentStatus,
    double? paidAmount,
    double? creditAmount,
    bool? isSettled,
    String? parkOrderId,
    DateTime? settlementDateTime,
  }) {
    return SaleOrder(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      customerName: customerName ?? this.customerName,
      customerMobile: customerMobile ?? this.customerMobile,
      items: items ?? this.items,
      orderAmount: orderAmount ?? this.orderAmount,
      transactionId: transactionId ?? this.transactionId,
      transactionSynced: transactionSynced ?? this.transactionSynced,
      transactionDateTime: transactionDateTime ?? this.transactionDateTime,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paidAmount: paidAmount ?? this.paidAmount,
      creditAmount: creditAmount ?? this.creditAmount,
      isSettled: isSettled ?? this.isSettled,
      parkOrderId: parkOrderId ?? this.parkOrderId,
      settlementDateTime: settlementDateTime ?? this.settlementDateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'time': time,
      'customerName': customerName,
      'customerMobile': customerMobile,
      'items': items.map((x) => x.toMap()).toList(),
      'orderAmount': orderAmount,
      'transactionId': transactionId,
      'transactionSynced': transactionSynced,
      'transactionDateTime': transactionDateTime.toIso8601String(),
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'paidAmount': paidAmount,
      'creditAmount': creditAmount,
      'isSettled': isSettled,
      'parkOrderId': parkOrderId,
      'settlementDateTime': settlementDateTime?.toIso8601String(),
    };
  }

  factory SaleOrder.fromMap(Map<String, dynamic> map) {
    return SaleOrder(
      id: map['id'],
      date: map['date'],
      time: map['time'],
      customerName: map['customerName'],
      customerMobile: map['customerMobile'],
      items: List<OrderItem>.from(map['items']?.map((x) => OrderItem.fromMap(x)) ?? []),
      orderAmount: map['orderAmount'],
      transactionId: map['transactionId'],
      transactionSynced: map['transactionSynced'],
      transactionDateTime: DateTime.parse(map['transactionDateTime']),
      paymentMethod: map['paymentMethod'],
      paymentStatus: map['paymentStatus'],
      paidAmount: map['paidAmount'] ?? 0.0,
      creditAmount: map['creditAmount'] ?? 0.0,
      isSettled: map['isSettled'] ?? false,
      parkOrderId: map['parkOrderId'] ?? '',
      settlementDateTime: map['settlementDateTime'] != null
          ? DateTime.parse(map['settlementDateTime'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SaleOrder.fromJson(String source) => SaleOrder.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SaleOrder(id: $id, date: $date, time: $time, customerName: $customerName, customerMobile: $customerMobile, items: $items, orderAmount: $orderAmount, paidAmount: $paidAmount, creditAmount: $creditAmount, transactionId: $transactionId, transactionSynced: $transactionSynced, transactionDateTime: $transactionDateTime, isSettled: $isSettled, parkOrderId: $parkOrderId, settlementDateTime: $settlementDateTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SaleOrder &&
        other.id == id &&
        other.date == date &&
        other.time == time &&
        other.customerName == customerName &&
        other.customerMobile == customerMobile &&
        listEquals(other.items, items) &&
        other.orderAmount == orderAmount &&
        other.transactionId == transactionId &&
        other.transactionSynced == transactionSynced &&
        other.transactionDateTime.isAtSameMomentAs(transactionDateTime) &&
        other.paymentMethod == paymentMethod &&
        other.paymentStatus == paymentStatus &&
        other.paidAmount == paidAmount &&
        other.creditAmount == creditAmount &&
        other.isSettled == isSettled &&
        other.parkOrderId == parkOrderId &&
        other.settlementDateTime == settlementDateTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        date.hashCode ^
        time.hashCode ^
        customerName.hashCode ^
        customerMobile.hashCode ^
        items.hashCode ^
        orderAmount.hashCode ^
        transactionId.hashCode ^
        transactionSynced.hashCode ^
        transactionDateTime.hashCode ^
        paymentMethod.hashCode ^
        paymentStatus.hashCode ^
        paidAmount.hashCode ^
        creditAmount.hashCode ^
        isSettled.hashCode ^
        parkOrderId.hashCode ^
        settlementDateTime.hashCode;
  }
}
