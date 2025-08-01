import 'package:flutter/material.dart';
import 'package:os_project/Testt/scheduler.dart';
import '../result_screen.dart';

class GeneratedDataScreen extends StatelessWidget {
  final List<Map<String, dynamic>> processes;

  const GeneratedDataScreen({super.key, required this.processes});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Data'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Scroll horizontally for table
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: screenWidth),
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Arrival Time')),
                          DataColumn(label: Text('Burst Time')),
                          DataColumn(label: Text('Priority')),
                        ],
                        rows: processes.map((process) {
                          return DataRow(
                            cells: [
                              DataCell(Text('${process['id'] ?? 'N/A'}')),
                              DataCell(Text('${process['arrivalTime'] ?? 'N/A'}')),
                              DataCell(Text('${process['burstTime'] ?? 'N/A'}')),
                              DataCell(Text('${process['priority'] ?? 'N/A'}')),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // The buttons will always stay at the bottom
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _buildButton(context, 'FCFS'),
                _buildButton(context, 'SRTF'),
                _buildButton(context, 'HPF'),
                _buildButton(context, 'Round Robin'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String algorithm) {
    return SizedBox(
      width: 150,
      height: 45,
      child: ElevatedButton(
        onPressed: () {
          _navigateToResults(context, algorithm);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          algorithm,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  void _navigateToResults(BuildContext context, String algorithm) {
    List<Map<String, dynamic>> results;

    if (algorithm == 'FCFS') {
      results = Scheduler.calculateFCFS(List<Map<String, dynamic>>.from(processes));
    } else if (algorithm == 'SRTF') {
      results = Scheduler.calculateSRTF2(List<Map<String, dynamic>>.from(processes));
    } else if (algorithm == 'HPF') {
      results = Scheduler.calculateHPF(List<Map<String, dynamic>>.from(processes));
    } else if (algorithm == 'Round Robin') {
      results = Scheduler.calculateRR(List<Map<String, dynamic>>.from(processes));
    } else {
      results = [];
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          processes: results,
          algorithm: algorithm,
        ),
      ),
    );
  }
}
