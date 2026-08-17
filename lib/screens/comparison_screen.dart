import 'package:flutter/material.dart';
import '../models/device.dart';
import '../services/ai_comparison_service.dart';
import 'thank_you_screen.dart';

class ComparisonScreen extends StatefulWidget {
  final List<Device> selectedDevices;

  const ComparisonScreen({super.key, required this.selectedDevices});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {

  // Direct route to ThankYouScreen on exit
  void _navigateToThankYou() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ThankYouScreen()),
      (route) => false, // Clears navigation stack back to home/splash
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevents default pop so custom navigation runs
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _navigateToThankYou();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Device Comparison'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _navigateToThankYou,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Spec Comparison Table
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    const DataColumn(label: Text('Feature', style: TextStyle(fontWeight: FontWeight.bold))),
                    ...widget.selectedDevices.map((d) => DataColumn(
                          label: Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        )),
                  ],
                  rows: [
                    _buildRow('Brand', (d) => d.brand),
                    _buildRow('Price', (d) => d.price),
                    _buildRow('Processor', (d) => d.processor),
                    _buildRow('RAM', (d) => d.ram),
                    _buildRow('Storage', (d) => d.storage),
                    _buildRow('Battery', (d) => d.battery),
                    _buildRow('Camera', (d) => d.camera),
                    _buildRow('Display', (d) => d.display),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // AI Opinion / Verdict Card
              _buildAiOpinionCard(),

              const SizedBox(height: 32),

              // Finish Comparison Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _navigateToThankYou,
                  child: const Text('Finish Comparison', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(String feature, String Function(Device) getVal) {
    return DataRow(
      cells: [
        DataCell(Text(feature, style: const TextStyle(fontWeight: FontWeight.w600))),
        ...widget.selectedDevices.map((d) => DataCell(Text(getVal(d)))),
      ],
    );
  }

  Widget _buildAiOpinionCard() {
    return Card(
      color: Colors.blueGrey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'AI Opinion & Verdict',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<String>(
              future: AiComparisonService.generateVerdict(widget.selectedDevices),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      children: [
                        SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 12),
                        Text('Analyzing specifications...', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  );
                }

                return Text(
                  snapshot.data ?? 'Unable to generate comparison.',
                  style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.white),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}