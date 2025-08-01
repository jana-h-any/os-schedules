import 'package:flutter/material.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:os_project/home_screen.dart';
import 'package:os_project/result_screen.dart';

class SRTFTestScreen extends StatelessWidget {
  final List<Map<String, dynamic>> processes;

  const SRTFTestScreen({super.key, required this.processes});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SRTF Try'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      print("Button Pressed");

                      List<Map<String, dynamic>> results =
                          calculateSRTF(List<Map<String, dynamic>>.from(processes));

                      print("Results: $results");

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultScreen(
                            processes: results,
                            algorithm: 'SRTF',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'SRTF',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // SRTF Algorithm
  static List<Map<String, dynamic>> calculateSRTF(List<Map<String, dynamic>> processes) {
  print("Processes before calculating: $processes");

  double currentTime = 0.0;
  double totalWaitingTime = 0.0;
  double totalTurnaroundTime = 0.0;

  List<Map<String, dynamic>> copiedProcesses = processes.map((p) {
    return {
      'id': p['id'],
      'arrivalTime': p['arrivalTime'] is String ? double.parse(p['arrivalTime']) : p['arrivalTime'].toDouble(),
      'burstTime': p['burstTime'] is String ? double.parse(p['burstTime']) : p['burstTime'].toDouble(),
      'priority': p['priority'] is String ? int.parse(p['priority']) : p['priority'].toInt(),
    };
  }).toList();

  Map<int, double> remainingBurst = {};
  for (var process in copiedProcesses) {
    int id = process['id'];
    remainingBurst[id] = process['burstTime'];
  }

  while (remainingBurst.isNotEmpty) {
    int? selectedProcessId;
    double shortestRemaining = double.infinity;

    for (var process in copiedProcesses) {
      int id = process['id'];
      double arrival = process['arrivalTime'];

      if (remainingBurst.containsKey(id) &&
          arrival <= currentTime &&
          remainingBurst[id]! < shortestRemaining) {
        shortestRemaining = remainingBurst[id]!;
        selectedProcessId = id;
      }
    }

    if (selectedProcessId == null) {
      double nextArrival = copiedProcesses
          .where((p) => remainingBurst.containsKey(p['id']))
          .map((p) => p['arrivalTime'])
          .reduce((a, b) => a < b ? a : b);

      currentTime = nextArrival;
      continue;
    }

    remainingBurst[selectedProcessId] = remainingBurst[selectedProcessId]! - 1;

    if (remainingBurst[selectedProcessId]! <= 0) {
      var process = copiedProcesses.firstWhere((p) => p['id'] == selectedProcessId);
      double arrivalTime = process['arrivalTime'];
      double burstTime = process['burstTime'];

      double turnaroundTime = currentTime + 1 - arrivalTime;
      double waitingTime = turnaroundTime - burstTime;

      process['waitingTime'] = waitingTime.toStringAsFixed(2);
      process['turnaroundTime'] = turnaroundTime.toStringAsFixed(2);

      totalWaitingTime += waitingTime;
      totalTurnaroundTime += turnaroundTime;

      remainingBurst.remove(selectedProcessId);
    }

    currentTime += 1;
  }

  int n = copiedProcesses.length;
  copiedProcesses.add({
    'id': 'Average',
    'waitingTime': (totalWaitingTime / n).toStringAsFixed(2),
    'turnaroundTime': (totalTurnaroundTime / n).toStringAsFixed(2),
  });

  return copiedProcesses;
}
}
