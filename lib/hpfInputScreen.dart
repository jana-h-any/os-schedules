import 'package:flutter/material.dart';
import 'scheduTry.dart';
import 'resultTry.dart';

class HPFInputScreen extends StatefulWidget {
  final int processCount;

  const HPFInputScreen({super.key, required this.processCount});

  @override
  State<HPFInputScreen> createState() => _HPFInputScreenState();
}

class _HPFInputScreenState extends State<HPFInputScreen> {
  List<Map<String, dynamic>> processData = [];

  @override
  void initState() {
    super.initState();
    processData = List.generate(widget.processCount, (index) => {
      'id': index + 1,
      'arrivalTime': '',
      'burstTime': '',
      'priority': '',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HPF Input')),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
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
                          decoration:
                          const InputDecoration(labelText: 'Arrival Time'),
                          onChanged: (value) {
                            setState(() {
                              processData[index]['arrivalTime'] = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration:
                          const InputDecoration(labelText: 'Burst Time'),
                          onChanged: (value) {
                            setState(() {
                              processData[index]['burstTime'] = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration:
                          const InputDecoration(labelText: 'Priority'),
                          onChanged: (value) {
                            setState(() {
                              processData[index]['priority'] = value;
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
                  List<Map<String, dynamic>> executionOrder = [];
                  List<Map<String, dynamic>> results =
                  Scheduler.calculateHPF(processData, executionOrder: executionOrder);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultScreen(
                        processes: results,
                        algorithm: 'HPF',
                        executionOrder: executionOrder,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields.')),
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
      if (int.tryParse(process['arrivalTime']) == null ||
          int.parse(process['arrivalTime']) < 0) {
        return false;
      }

      if (int.tryParse(process['burstTime']) == null ||
          int.parse(process['burstTime']) <= 0) {
        return false;
      }

      if (int.tryParse(process['priority']) == null) {
        return false;
      }
    }
    return true;
  }
}
