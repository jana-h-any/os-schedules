import 'package:flutter/material.dart';
import 'scheduTry.dart';
import 'resultTry.dart';
class RRInputScreen extends StatefulWidget {
  final int processCount;

  const RRInputScreen({super.key, required this.processCount});

  @override
  State<RRInputScreen> createState() => _RRInputScreenState();
}

class _RRInputScreenState extends State<RRInputScreen> {
  List<Map<String, dynamic>> processData = [];
  int quantum = 4; // Default

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
      appBar: AppBar(title: const Text('Round Robin Input')),
      body: Padding(
        padding: const EdgeInsets.all(19.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text('Quantum:'),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (quantum > 1) {
                        quantum--;
                      }
                    });
                  },
                ),
                Text(quantum.toString()),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      if (quantum < 30) {
                        quantum++;
                      }
                    });
                  },
                ),
              ],
            ),
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
                              processData[index]['arrivalTime'] = value;
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
                              processData[index]['burstTime'] = value;
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
                  List<Map<String, dynamic>> results = Scheduler.calculateRR(
                    processData,
                    quantum: quantum,
                    executionOrder: executionOrder,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultScreen(
                        processes: results,
                        algorithm: 'Round Robin',
                        executionOrder: executionOrder,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields with valid values.')),
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
      if (process['arrivalTime'].isEmpty || process['burstTime'].isEmpty) {
        return false;
      }

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
