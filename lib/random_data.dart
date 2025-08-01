import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
//import 'generated_data_screen.dart';
import 'try_generated.dart';
class RandomDataGeneratorScreen extends StatefulWidget {
  const RandomDataGeneratorScreen({super.key});

  @override
  _RandomDataGeneratorScreenState createState() =>
      _RandomDataGeneratorScreenState();
}

class _RandomDataGeneratorScreenState extends State<RandomDataGeneratorScreen> {
  String _statusMessage = '';
  String? _selectedFileName;

  Future<void> _handleFileGeneration({required String inputContent}) async {
    try {
      final lines = LineSplitter.split(inputContent).toList();

      if (lines.length < 4) {
        setState(() {
          _statusMessage =
              'Invalid input file format. File must contain at least 4 lines.';
        });
        return;
      }

      final numProcesses = int.parse(lines[0].trim());
      final arrivalParams =
          lines[1].trim().split(' ').map(double.parse).toList();
      final burstParams = lines[2].trim().split(' ').map(double.parse).toList();
      final lambda = double.parse(lines[3].trim());

      final arrivalMean = arrivalParams[0];
      final arrivalStdDev = arrivalParams[1];
      final burstMean = burstParams[0];
      final burstStdDev = burstParams[1];

      final random = Random();
      final processes = List.generate(numProcesses, (index) {
        final arrivalTime =
            _normalDistribution(random, arrivalMean, arrivalStdDev);
        final burstTime = _normalDistribution(random, burstMean, burstStdDev);
        final priority = _poissonDistribution(random, lambda);
        return {
          'id': index + 1,
          'arrivalTime': arrivalTime.toStringAsFixed(2),
          'burstTime': burstTime.toStringAsFixed(2),
          'priority': priority.toString(),
        };
      });

      final outputLines = <String>[
        numProcesses.toString(),
        ...processes.map((p) =>
            '${p['id']} ${p['arrivalTime']} ${p['burstTime']} ${p['priority']}')
      ];

      final directory = await getApplicationDocumentsDirectory();
      final outputFile = File('${directory.path}/output.txt');
      await outputFile.writeAsString(outputLines.join('\n'));

      print('✅ Output file saved at: ${outputFile.path}');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GeneratedDataScreen(processes: processes),
        ),
      );
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _generateFromDefaultAsset() async {
    final inputString =
        await DefaultAssetBundle.of(context).loadString('assets/input.txt');
    await _handleFileGeneration(inputContent: inputString);
  }

  Future<void> _generateFromUploadedFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result == null || result.files.single.path == null) {
      setState(() {
        _statusMessage = 'No file selected.';
      });
      return;
    }

    final filePath = result.files.single.path!;
    final inputFile = File(filePath);
    final inputString = await inputFile.readAsString();

    setState(() {
      _selectedFileName = result.files.single.name;
    });

    await _handleFileGeneration(inputContent: inputString);
  }

  double _normalDistribution(Random random, double mean, double stdDev) {
    final u1 = 1.0 - random.nextDouble();
    final u2 = 1.0 - random.nextDouble();
    final randStdNormal = sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
    return mean + stdDev * randStdNormal;
  }

  int _poissonDistribution(Random random, double lambda) {
    double L = exp(-lambda);
    int k = 0;
    double p = 1.0;

    while (p > L) {
      k++;
      p *= random.nextDouble();
    }
    return k - 1;
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Random Data Generator')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Button for uploading file
                Flexible(
                  child: ElevatedButton(
                    onPressed: _generateFromUploadedFile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: const Color(0xFFF6F1FF),
                      foregroundColor: const Color.fromARGB(255, 84, 49, 143),
                      elevation: 3,
                      minimumSize: Size(150, 50), // Ensures minimum button size
                    ),
                    child: const Text(
                      'Upload File',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Button for generating random data
                Flexible(
                  child: ElevatedButton(
                    onPressed: _generateFromDefaultAsset,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: const Color(0xFF0D6EFD),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      minimumSize: Size(150, 50), // Ensures minimum button size
                    ),
                    child: const Text(
                      'Random',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_selectedFileName != null)
              Text(
                'Selected file: $_selectedFileName',
                style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            const SizedBox(height: 16),
            Text(
              _statusMessage,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    ),
  );
}

}
