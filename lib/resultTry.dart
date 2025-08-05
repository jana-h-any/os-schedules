import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:os_project/home_screen.dart';

class ResultScreen extends StatefulWidget {
  final List<Map<String, dynamic>> processes;
  final String algorithm;
  final List<Map<String, dynamic>> executionOrder;

  const ResultScreen({
    super.key,
    required this.processes,
    required this.algorithm,
    required this.executionOrder,
  });

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? averageRow;
    List<Map<String, dynamic>> sortedProcesses = List.from(widget.processes);

    sortedProcesses.removeWhere((process) {
      if (process['id'] == 'Average') {
        averageRow = process;
        return true;
      }
      return false;
    });

    sortedProcesses.sort((a, b) => a['id'].compareTo(b['id']));

    if (averageRow != null) {
      sortedProcesses.add(averageRow!);
    }

    List<double> waitingTimes = [];
    List<double> turnaroundTimes = [];

    for (var process in sortedProcesses) {
      if (process['id'] != 'Average' &&
          process['waitingTime'] != null &&
          process['turnaroundTime'] != null) {
        waitingTimes.add(double.parse(process['waitingTime'].toString()));
        turnaroundTimes
            .add(double.parse(process['turnaroundTime'].toString()));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Process Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Table of Processes
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: IntrinsicWidth(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width,
                    ),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Arrival Time')),
                        DataColumn(label: Text('Burst Time')),
                        DataColumn(label: Text('Priority')),
                        DataColumn(label: Text('Waiting Time')),
                        DataColumn(label: Text('Turnaround Time')),
                      ],
                      rows: sortedProcesses.map((process) {
                        return DataRow(
                          cells: [
                            DataCell(Text('${process['id'] ?? '-'}')),
                            DataCell(Text('${process['arrivalTime'] ?? '-'}')),
                            DataCell(Text('${process['burstTime'] ?? '-'}')),
                            DataCell(Text('${process['priority'] ?? '-'}')),
                            DataCell(Text('${process['waitingTime'] ?? '-'}')),
                            DataCell(
                                Text('${process['turnaroundTime'] ?? '-'}')),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

// Execution Order Table
              const Text(
                'Execution Order Table',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: IntrinsicWidth(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Process ID')),
                      DataColumn(label: Text('Start Time')),
                      DataColumn(label: Text('End Time')),
                    ],
                    rows: widget.executionOrder.map((entry) {
                      return DataRow(
                        cells: [
                          DataCell(Text('P${entry['id']}')),
                          DataCell(Text('${entry['start']}')),
                          DataCell(Text('${entry['end']}')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

// Gantt Chart
              const Text(
                'Gantt Chart',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: widget.executionOrder.map((entry) {
                    final processId = entry['id'];
                    final startTime = double.parse(entry['start'].toString());
                    final endTime = double.parse(entry['end'].toString());
                   // final duration = endTime - startTime;

                    return Row(
                      children: [
                        Container(
                          width: 100,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.purple[300],
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'P$processId\n[$startTime-$endTime]',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Charts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 300,
                child: BarChart(
                  BarChartData(
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text('P${value.toInt() + 1}');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(
                      waitingTimes.length,
                          (index) => BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: waitingTimes[index],
                            color: Colors.blue,
                            width: 20,
                          ),
                          BarChartRodData(
                            toY: turnaroundTimes[index],
                            color: Colors.green,
                            width: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(Colors.blue, 'Waiting Time'),
                  const SizedBox(width: 20),
                  _buildLegendItem(Colors.green, 'Turnaround Time'),
                ],
              ),

              const SizedBox(height: 20),

              Center(
                child: SizedBox(
                  width: 180,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
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
                      'Back to Home',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
