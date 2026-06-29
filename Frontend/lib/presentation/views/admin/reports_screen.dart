import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isLoading = true;
  DateTimeRange? _selectedRange;
  Map<String, dynamic> _stats = {};
  List<MapEntry<String, double>> _topVendorEarnings = [];
  List<MapEntry<String, double>> _topCustomerSpending = [];
  List<MapEntry<String, int>> _orderStatusCounts = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final vendorsSnapshot = await FirebaseFirestore.instance.collection('vendors').get();
      final ordersSnapshot = await FirebaseFirestore.instance.collection('orders').get();

      final range = _selectedRange;
      final inRangeOrders = ordersSnapshot.docs.where((doc) {
        final data = doc.data();
        final createdAt = _parseDateTime(data['created_at']);
        if (createdAt == null || range == null) return true;
        return !createdAt.isBefore(range.start) &&
            !createdAt.isAfter(range.end.add(const Duration(days: 1)));
      }).toList();

      final statusCounts = <String, int>{};
      final vendorRevenue = <String, double>{};
      final customerSpend = <String, double>{};
      final vendorNames = <String, String>{};
      final customerNames = <String, String>{};

      double completedRevenue = 0.0;
      double pendingRevenue = 0.0;
      int completedOrders = 0;
      int cancelledOrders = 0;
      double totalRating = 0.0;
      int ratedOrders = 0;

      for (final doc in inRangeOrders) {
        final data = doc.data();
        final status = (data['status'] ?? 'unknown').toString();
        final amount = _asDouble(data['total_amount']);
        final vendorId = (data['vendor_id'] ?? '').toString();
        final customerId = (data['customer_id'] ?? '').toString();
        final vendorName = (data['vendor_name'] ?? vendorId).toString();
        final customerName = (data['customer_name'] ?? customerId).toString();
        final rating = _asNullableDouble(data['rating']);

        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
        if (vendorId.isNotEmpty) {
          vendorRevenue[vendorId] = (vendorRevenue[vendorId] ?? 0.0) + amount;
          vendorNames[vendorId] = vendorName;
        }
        if (customerId.isNotEmpty) {
          customerSpend[customerId] = (customerSpend[customerId] ?? 0.0) + amount;
          customerNames[customerId] = customerName;
        }

        if (status == 'completed') {
          completedRevenue += amount;
          completedOrders += 1;
        } else if (status == 'pending') {
          pendingRevenue += amount;
        } else if (status == 'cancelled') {
          cancelledOrders += 1;
        }

        if (rating != null && rating > 0) {
          totalRating += rating;
          ratedOrders += 1;
        }
      }

      final topVendorEarnings = vendorRevenue.entries
          .map((entry) => MapEntry(vendorNames[entry.key] ?? entry.key, entry.value))
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topCustomerSpending = customerSpend.entries
          .map((entry) => MapEntry(customerNames[entry.key] ?? entry.key, entry.value))
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final orderStatusCounts = statusCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      setState(() {
        _stats = {
          'totalUsers': usersSnapshot.size,
          'totalVendors': vendorsSnapshot.size,
          'totalOrders': inRangeOrders.length,
          'completedOrders': completedOrders,
          'cancelledOrders': cancelledOrders,
          'completedRevenue': completedRevenue,
          'pendingRevenue': pendingRevenue,
          'averageOrderValue': inRangeOrders.isEmpty
              ? 0.0
              : completedRevenue / inRangeOrders.length,
          'averageRating': ratedOrders == 0 ? 0.0 : totalRating / ratedOrders,
          'ratedOrders': ratedOrders,
        };
        _topVendorEarnings = topVendorEarnings.take(8).toList();
        _topCustomerSpending = topCustomerSpending.take(8).toList();
        _orderStatusCounts = orderStatusCounts;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  double? _asNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: _selectedRange,
    );

    if (picked == null) return;
    setState(() {
      _selectedRange = picked;
    });
    await _loadReportData();
  }

  Future<void> _generatePdfReport() async {
    final pdfBytes = await _buildPdfBytes();
    await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
  }

  Future<Uint8List> _buildPdfBytes() async {
    final doc = pw.Document();
    final currency = NumberFormat('#,##0');
    final generatedAt = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
    final range = _selectedRange;
    final rangeText = range == null
        ? 'All time'
        : '${DateFormat('dd MMM yyyy').format(range.start)} - ${DateFormat('dd MMM yyyy').format(range.end)}';

    pw.Widget sectionTitle(String text) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8, top: 12),
          child: pw.Text(
            text,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        );

    pw.Widget statRow(String label, String value) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(label),
              pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          ),
        );

    pw.Widget barRowsFromMap(List<MapEntry<String, num>> items) {
      final maxValue = items.isEmpty
          ? 1.0
          : items.map((e) => e.value.toDouble()).reduce((a, b) => a > b ? a : b);
      return pw.Column(
        children: items.map((entry) {
          final fraction = maxValue == 0 ? 0.0 : entry.value.toDouble() / maxValue;
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Row(
              children: [
                pw.SizedBox(
                  width: 140,
                  child: pw.Text(
                    entry.key,
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                  ),
                ),
                pw.Expanded(
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 220,
                        height: 12,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey300,
                          borderRadius: pw.BorderRadius.circular(2),
                        ),
                        child: pw.Align(
                          alignment: pw.Alignment.centerLeft,
                          child: pw.Container(
                            width: 220 * fraction.clamp(0.0, 1.0),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.blue600,
                              borderRadius: pw.BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(
                  width: 70,
                  child: pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(entry.value.toString()),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Text(
            'Car Wash Platform Report',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text('Generated: $generatedAt'),
          pw.Text('Range: $rangeText'),
          pw.SizedBox(height: 12),
          sectionTitle('Summary'),
          statRow('Total Users', '${_stats['totalUsers'] ?? 0}'),
          statRow('Total Vendors', '${_stats['totalVendors'] ?? 0}'),
          statRow('Total Orders', '${_stats['totalOrders'] ?? 0}'),
          statRow('Completed Orders', '${_stats['completedOrders'] ?? 0}'),
          statRow('Cancelled Orders', '${_stats['cancelledOrders'] ?? 0}'),
          statRow(
            'Completed Revenue',
            'Rs ${currency.format(_stats['completedRevenue'] ?? 0)}',
          ),
          statRow(
            'Pending Revenue',
            'Rs ${currency.format(_stats['pendingRevenue'] ?? 0)}',
          ),
          statRow(
            'Average Order Value',
            'Rs ${currency.format(_stats['averageOrderValue'] ?? 0)}',
          ),
          statRow(
            'Average Rating',
            '${(_stats['averageRating'] ?? 0.0).toStringAsFixed(2)}',
          ),
          sectionTitle('Order Status Distribution'),
          barRowsFromMap(
            _orderStatusCounts.map((e) => MapEntry(e.key, e.value)).toList(),
          ),
          sectionTitle('Top Vendors By Earnings'),
          barRowsFromMap(
            _topVendorEarnings
                .map((e) => MapEntry(e.key, e.value.round()))
                .toList(),
          ),
          sectionTitle('Top Customers By Spending'),
          barRowsFromMap(
            _topCustomerSpending
                .map((e) => MapEntry(e.key, e.value.round()))
                .toList(),
          ),
        ],
      ),
    );

    return doc.save();
  }

  @override
  Widget build(BuildContext context) {
    final range = _selectedRange;
    final rangeLabel = range == null
        ? 'All time'
        : '${DateFormat('dd MMM').format(range.start)} - ${DateFormat('dd MMM yyyy').format(range.end)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            tooltip: 'Filter date range',
            onPressed: _pickDateRange,
            icon: const Icon(Icons.date_range),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadReportData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 36),
                        const SizedBox(height: 12),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadReportData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReportData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Report Range: $rangeLabel',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildStatCard('Total Users', '${_stats['totalUsers'] ?? 0}', Colors.blue),
                          _buildStatCard('Total Vendors', '${_stats['totalVendors'] ?? 0}', Colors.green),
                          _buildStatCard('Total Orders', '${_stats['totalOrders'] ?? 0}', Colors.orange),
                          _buildStatCard(
                            'Completed Revenue',
                            'Rs ${NumberFormat('#,##0').format(_stats['completedRevenue'] ?? 0)}',
                            Colors.purple,
                          ),
                          _buildStatCard(
                            'Avg Rating',
                            '${(_stats['averageRating'] ?? 0.0).toStringAsFixed(2)}',
                            Colors.teal,
                          ),
                          _buildStatCard(
                            'Cancelled',
                            '${_stats['cancelledOrders'] ?? 0}',
                            Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Order Status'),
                      _buildSimpleBars(
                        _orderStatusCounts.map((e) => MapEntry(e.key, e.value.toDouble())).toList(),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Top Vendors By Earnings'),
                      _buildSimpleBars(_topVendorEarnings),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Top Customers By Spending'),
                      _buildSimpleBars(_topCustomerSpending),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _generatePdfReport,
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Generate PDF Report'),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleBars(List<MapEntry<String, double>> rows) {
    final maxValue = rows.isEmpty
        ? 1.0
        : rows.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    if (rows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text('No data available'),
      );
    }

    return Column(
      children: rows.map((entry) {
        final fraction = maxValue == 0 ? 0.0 : (entry.value / maxValue).clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  entry.key,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 10,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 62,
                child: Text(
                  entry.value.toStringAsFixed(0),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
