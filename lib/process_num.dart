import 'package:flutter/material.dart';
import 'choose_algorithm.dart';

class ProcessNumberScreen extends StatefulWidget {
  const ProcessNumberScreen({super.key});

  @override
  State<ProcessNumberScreen> createState() => _ProcessNumberScreenState();
}

class _ProcessNumberScreenState extends State<ProcessNumberScreen> {
  int _selectedProcessCount = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('Number of Processes')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select number of processes',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_selectedProcessCount',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            Slider(
              value: _selectedProcessCount.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '$_selectedProcessCount',
              onChanged: (value) {
                setState(() {
                  _selectedProcessCount = value.round();
                });
              },
              activeColor: Colors.blue,
              inactiveColor: Colors.grey[300],
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChooseAlgorithmScreen(processCount: _selectedProcessCount),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'SELECT ALGORITHM',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}