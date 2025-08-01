import 'package:flutter/material.dart';
//import 'fcfs_srtf_input.dart';
//import 'rr_input.dart';
//import 'hpf_input.dart';
import 'hpfInputScreen.dart';
import 'fcfcSRTFInput.dart';
import 'tryRR_input.dart';

class ChooseAlgorithmScreen extends StatelessWidget {
  final int processCount;

  const ChooseAlgorithmScreen({super.key, required this.processCount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Scheduling Algorithm')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAlgorithmButton(context, 'FCFS', Colors.blue, processCount),
            _buildAlgorithmButton(context, 'SRTF', Colors.green, processCount),
            _buildAlgorithmButton(
                context, 'Round Robin', Colors.orange, processCount),
            _buildAlgorithmButton(context, 'HPF', Colors.purple, processCount),
          ],
        ),
      ),
    );
  }

  Widget _buildAlgorithmButton(
      BuildContext context, String algorithm, Color color, int processCount) {
    return Container(
      width: 220,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: () {
          if (algorithm == 'Round Robin') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RRInputScreen(processCount: processCount),
              ),
            );
          } else if (algorithm == 'HPF') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    HPFInputScreen(processCount: processCount),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InputScreen(
                    processCount: processCount, algorithm: algorithm),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          algorithm,
          style: const TextStyle(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
