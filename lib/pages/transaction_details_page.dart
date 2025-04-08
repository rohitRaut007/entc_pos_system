import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sale_order.dart';
import '../models/order_item.dart';

class TransactionDetailsPage extends StatelessWidget {
  final SaleOrder saleOrder;

  const TransactionDetailsPage({super.key, required this.saleOrder});

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xff17181f);
    final cardColor = const Color(0xff1f2028);
    final successColor = Colors.amber;

    return Scaffold(
      backgroundColor: themeColor,
      body: SafeArea(
        child: Column(
          children: [
            // Back Button Row
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Transaction Details',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 48, color: successColor),
                        const SizedBox(height: 12),
                        const Text(
                          'Payment Successful',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Thank you for your order!',
                          style: TextStyle(fontSize: 14, color: Colors.white54),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xff2c2d36),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '#${saleOrder.transactionId}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const Divider(height: 32, thickness: 1, color: Colors.white10),

                        _buildDetailRow(Icons.calendar_today, 'Time / Date',
                            DateFormat('dd-MM-yyyy, HH:mm').format(saleOrder.transactionDateTime)),
                        _buildDetailRow(Icons.person, 'Customer Name', saleOrder.customerName),
                        _buildDetailRow(Icons.phone, 'Mobile Number', saleOrder.customerMobile),
                        _buildDetailRow(Icons.payments_outlined, 'Payment Method', 'Cash'), // dynamic if needed
                        _buildDetailRow(Icons.confirmation_number, 'Ref Number', saleOrder.transactionId),

                        const SizedBox(height: 16),
                        const Divider(thickness: 1, color: Colors.white10),

                        _buildAmountRow('Amount', saleOrder.orderAmount),
                        _buildAmountRow('Fee', 0),
                        _buildAmountRow('Total', saleOrder.orderAmount),

                        const SizedBox(height: 16),
                        const Divider(thickness: 1, color: Colors.white10),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Ordered Items',
                            style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...saleOrder.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.productName} (${item.quantity} x ₹${item.price.toStringAsFixed(2)})',
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                  Text(
                                    '₹${(item.quantity * item.price).toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white54),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text('₹${amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
