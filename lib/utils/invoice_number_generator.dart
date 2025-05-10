import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

Future<String> generateTransactionId() async {
  final now = DateTime.now();
  final currentYear = now.year % 100;
  final previousYear = currentYear - 1;
  final month = now.month.toString().padLeft(2, '0');
  final yearMonthKey = '$previousYear$currentYear$month';

  final box = await Hive.openBox('transaction_counter');

  // If counter doesn't exist for this month, reset to 0
  int currentSerial = box.get(yearMonthKey, defaultValue: 1);

  // Create ID in the format: PREVYEAR-CURRYEAR-MONTH-SERIAL
  final transactionId = '$previousYear$currentYear$month${currentSerial.toString().padLeft(4, '0')}';

  // Increment and store for next use
  await box.put(yearMonthKey, currentSerial + 1);

  return transactionId;
}
