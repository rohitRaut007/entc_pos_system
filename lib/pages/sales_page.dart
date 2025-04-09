import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/sale_order.dart';
import 'transaction_details_page.dart';
import 'package:intl/intl.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;
  String _sortOption = 'Latest';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<SaleOrder>('sales').listenable(),
      builder: (context, Box<SaleOrder> box, _) {
        List<SaleOrder> sales = box.values.toList();

        // Apply filters
        sales = sales.where((sale) {
          final matchesSearch = sale.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              sale.customerMobile.contains(_searchQuery);

          final inDateRange = (_startDate == null || sale.transactionDateTime.isAfter(_startDate!)) &&
              (_endDate == null || sale.transactionDateTime.isBefore(_endDate!.add(const Duration(days: 1))));

          return matchesSearch && inDateRange;
        }).toList();

        // Sort sales
        if (_sortOption == 'Latest') {
          sales.sort((a, b) => b.transactionDateTime.compareTo(a.transactionDateTime));
        } else if (_sortOption == 'Amount') {
          sales.sort((a, b) => b.orderAmount.compareTo(a.orderAmount));
        }

        final totalSales = sales.fold<double>(0, (sum, item) => sum + item.orderAmount);

        return Column(
          children: [
            _buildFilters(context),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Total Sales: ₹${totalSales.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: sales.isEmpty
                  ? const Center(
                      child: Text(
                        'No matching sales found.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: sales.length,
                      itemBuilder: (context, index) {
                        final sale = sales[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TransactionDetailsPage(saleOrder: sale),
                              ),
                            );
                          },
                          child: Card(
                            color: const Color(0xff272833),
                            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.person, color: Colors.white60, size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        sale.customerName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '₹${sale.orderAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.greenAccent,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone, color: Colors.white54, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        sale.customerMobile,
                                        style: const TextStyle(color: Colors.white54),
                                      ),
                                      const Spacer(),
                                      Text(
                                        DateFormat('dd MMM yyyy, hh:mm a').format(sale.transactionDateTime),
                                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Chip(
                                      backgroundColor: sale.paymentStatus == 'Paid'
                                          ? Colors.green.withOpacity(0.8)
                                          : Colors.orange.withOpacity(0.8),
                                      label: Text(
                                        sale.paymentStatus == 'Paid' ? 'Paid' : 'Credit',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Search Field
          SizedBox(
            width: 180,
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search name/mobile',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Color(0xff1f1f29),
                isDense: true,
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Date Range Picker
          ElevatedButton.icon(
            icon: const Icon(Icons.date_range, size: 18),
            label: Text(
              _startDate != null && _endDate != null
                  ? '${DateFormat('dd MMM').format(_startDate!)} - ${DateFormat('dd MMM').format(_endDate!)}'
                  : 'Date Range',
            ),
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2023),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _startDate = picked.start;
                  _endDate = picked.end;
                });
              }
            },
          ),

          // Sort Option
          DropdownButton<String>(
            dropdownColor: const Color(0xff1f1f29),
            value: _sortOption,
            style: const TextStyle(color: Colors.white),
            underline: Container(),
            items: const [
              DropdownMenuItem(value: 'Latest', child: Text('Latest')),
              DropdownMenuItem(value: 'Amount', child: Text('Amount High → Low')),
            ],
            onChanged: (value) => setState(() => _sortOption = value!),
          ),

          // Clear Button
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _startDate = null;
                _endDate = null;
                _sortOption = 'Latest';
              });
            },
            child: const Text('Clear Filters', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
