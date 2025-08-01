import 'package:flutter/material.dart';
//import 'package:os_project/scheduler.dart';
import 'resultTry.dart';
import 'scheduTry.dart';
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
        onPressed: () => _navigateToResults(context, algorithm),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    List<Map<String, dynamic>> executionOrder = [];

    final copiedProcesses = List<Map<String, dynamic>>.from(processes);

    if (algorithm == 'FCFS') {
      results = Scheduler.calculateFCFS(copiedProcesses, executionOrder: executionOrder);
    } else if (algorithm == 'SRTF') {
      results = Scheduler.calculateSRTF2(copiedProcesses, executionOrder: executionOrder);
    } else if (algorithm == 'HPF') {
      results = Scheduler.calculateHPF(copiedProcesses, executionOrder: executionOrder);
    } else if (algorithm == 'Round Robin') {
      results = Scheduler.calculateRR(copiedProcesses, quantum: 3, executionOrder: executionOrder);
    } else {
      results = [];
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          processes: results,
          algorithm: algorithm,
          executionOrder: executionOrder,
        ),
      ),
    );
  }
}
