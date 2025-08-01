import 'package:flutter/material.dart';
import 'resultTry.dart';
import 'scheduTry.dart';


// Input screen for FCFS and SRTF
class InputScreen extends StatefulWidget {
  final int processCount;
  final String algorithm;

  const InputScreen({super.key, required this.processCount, required this.algorithm});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  List<Map<String, dynamic>> processData = [];

  @override
  void initState() {
    super.initState();
    processData = List.generate(widget.processCount, (index) => {
      'id': index + 1,
      'arrivalTime': '',
      'burstTime': '',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.algorithm} Input')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.processCount,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Text('P${processData[index]['id']}'),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Arrival Time'),
                          onChanged: (value) {
                            setState(() {
                              if (int.tryParse(value) != null && int.parse(value) >= 0) {
                                processData[index]['arrivalTime'] = value;
                              } else {
                                processData[index]['arrivalTime'] = '';
                              }
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Burst Time'),
                          onChanged: (value) {
                            setState(() {
                              if (int.tryParse(value) != null && int.parse(value) > 0) {
                                processData[index]['burstTime'] = value;
                              } else {
                                processData[index]['burstTime'] = '';
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_validateInputs()) {
                  List<Map<String, dynamic>> results;
                  List<Map<String, dynamic>> executionOrder = [];

                  if (widget.algorithm == 'FCFS') {
                    results = Scheduler.calculateFCFS(
                      processData,
                      executionOrder: executionOrder,
                    );
                  } else if (widget.algorithm == 'SRTF') {
                    results = Scheduler.calculateSRTF(
                      processData,
                      executionOrder: executionOrder,
                    );
                  } else {
                    results = [];
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultScreen(
                        processes: results,
                        algorithm: widget.algorithm,
                        executionOrder: executionOrder,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please ensure all fields are valid.')),
                  );
                }
              },
              child: const Text('Calculate'),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateInputs() {
    for (var process in processData) {
      if (int.tryParse(process['arrivalTime']) == null || int.parse(process['arrivalTime']) < 0) {
        return false;
      }

      if (int.tryParse(process['burstTime']) == null || int.parse(process['burstTime']) <= 0) {
        return false;
      }
    }
    return true;
  }
}
