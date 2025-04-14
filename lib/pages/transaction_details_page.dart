import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sale_order.dart';
import '../models/order_item.dart';

class TransactionDetailsPage extends StatefulWidget {
  final SaleOrder saleOrder;

  const TransactionDetailsPage({super.key, required this.saleOrder});

  @override
  _TransactionDetailsPageState createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  DateTime? settlementDateTime;

  // Method to handle settlement
 void _settleTransaction() {
  final now = DateTime.now();
  setState(() {
    settlementDateTime = now;
    widget.saleOrder.paidAmount = widget.saleOrder.orderAmount;
    widget.saleOrder.creditAmount = 0;
    widget.saleOrder.settlementDateTime = now; // <- update model
  });

  // Save to Hive
  widget.saleOrder.save(); // Assuming it's a HiveObject
}


  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xff17181f);
    final cardColor = const Color(0xff1f2028);
    final successColor = Colors.amber;

    final double creditAmount = widget.saleOrder.orderAmount - widget.saleOrder.paidAmount;

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
                        Text(
                          creditAmount > 0 ? 'Partially Paid' : 'Payment Successful',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          creditAmount > 0 ? 'Balance pending from customer.' : 'Thank you for your order!',
                          style: const TextStyle(fontSize: 14, color: Colors.white54),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xff2c2d36),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '#${widget.saleOrder.transactionId}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const Divider(height: 32, thickness: 1, color: Colors.white10),

                        _buildDetailRow(Icons.calendar_today, 'Time / Date',
                            DateFormat('dd-MM-yyyy, HH:mm').format(widget.saleOrder.transactionDateTime)),
                        _buildDetailRow(Icons.person, 'Customer Name', widget.saleOrder.customerName),
                        _buildDetailRow(Icons.phone, 'Mobile Number', widget.saleOrder.customerMobile),
                        _buildDetailRow(Icons.payments_outlined, 'Payment Method', 'Cash'), // optional to make dynamic
                        _buildDetailRow(Icons.confirmation_number, 'Ref Number', widget.saleOrder.transactionId),

                        const SizedBox(height: 16),
                        const Divider(thickness: 1, color: Colors.white10),

                        _buildAmountRow('Total Amount', widget.saleOrder.orderAmount),
                        _buildAmountRow('Paid Amount', widget.saleOrder.paidAmount),
                        if (creditAmount > 0)
                          _buildAmountRow('Credit Amount', creditAmount),

                        // Settlement Button for Credit Transactions
                        if (creditAmount > 0) ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _settleTransaction,
                            child: const Text('Settle Remaining Amount'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),
                        const Divider(thickness: 1, color: Colors.white10),

                        // Settlement Date/Time Display
                        if (widget.saleOrder.settlementDateTime != null)
                          _buildDetailRow(
                            Icons.access_time,
                            'Settlement Time',
                            DateFormat('dd-MM-yyyy, HH:mm').format(widget.saleOrder.settlementDateTime!),
                          ),


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
                        ...widget.saleOrder.items.map((item) => Padding(
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
