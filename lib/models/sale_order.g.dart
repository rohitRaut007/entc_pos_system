// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_order.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleOrderAdapter extends TypeAdapter<SaleOrder> {
  @override
  final int typeId = 15;

  @override
  SaleOrder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleOrder(
      id: fields[0] as String,
      date: fields[1] as String,
      time: fields[2] as String,
      customerName: fields[3] as String,
      customerMobile: fields[4] as String,
      items: (fields[5] as List).cast<OrderItem>(),
      orderAmount: fields[6] as double,
      transactionId: fields[7] as String,
      transactionSynced: fields[8] as bool,
      transactionDateTime: fields[9] as DateTime,
      paymentMethod: fields[10] == null ? '' : fields[10] as String,
      paymentStatus: fields[11] == null ? 'Unpaid' : fields[11] as String,
      paidAmount: fields[12] == null ? 0.0 : fields[12] as double,
      creditAmount: fields[13] == null ? 0.0 : fields[13] as double,
      isSettled: fields[14] == null ? false : fields[14] as bool,
      parkOrderId: fields[15] == null ? '' : fields[15] as String,
      settlementDateTime: fields[16] as DateTime?,
      gstin: fields[17] == null ? '' : fields[17] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SaleOrder obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.customerName)
      ..writeByte(4)
      ..write(obj.customerMobile)
      ..writeByte(5)
      ..write(obj.items)
      ..writeByte(6)
      ..write(obj.orderAmount)
      ..writeByte(7)
      ..write(obj.transactionId)
      ..writeByte(8)
      ..write(obj.transactionSynced)
      ..writeByte(9)
      ..write(obj.transactionDateTime)
      ..writeByte(10)
      ..write(obj.paymentMethod)
      ..writeByte(11)
      ..write(obj.paymentStatus)
      ..writeByte(12)
      ..write(obj.paidAmount)
      ..writeByte(13)
      ..write(obj.creditAmount)
      ..writeByte(14)
      ..write(obj.isSettled)
      ..writeByte(15)
      ..write(obj.parkOrderId)
      ..writeByte(16)
      ..write(obj.settlementDateTime)
      ..writeByte(17)
      ..write(obj.gstin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleOrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
