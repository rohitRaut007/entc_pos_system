// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvoiceDataAdapter extends TypeAdapter<InvoiceData> {
  @override
  final int typeId = 10;

  @override
  InvoiceData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvoiceData(
      invoiceNumber: fields[0] as String,
      buyerName: fields[1] as String,
      buyerMobile: fields[2] as String,
      buyerGst: fields[3] as String,
      date: fields[4] as DateTime,
      items: (fields[5] as List).cast<InvoiceItem>(),
      isQuotation: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceData obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.invoiceNumber)
      ..writeByte(1)
      ..write(obj.buyerName)
      ..writeByte(2)
      ..write(obj.buyerMobile)
      ..writeByte(3)
      ..write(obj.buyerGst)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.items)
      ..writeByte(6)
      ..write(obj.isQuotation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InvoiceItemAdapter extends TypeAdapter<InvoiceItem> {
  @override
  final int typeId = 11;

  @override
  InvoiceItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvoiceItem(
      name: fields[0] as String,
      quantity: fields[1] as int,
      price: fields[2] as double,
      gstRate: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.gstRate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
