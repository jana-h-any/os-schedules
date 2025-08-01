import 'dart:math';

class Scheduler {

  // FCFS Algorithm

  static List<Map<String, dynamic>> calculateFCFS(
      List<Map<String, dynamic>> processes) {
    double currentTime = 0.0;
    double totalWaitingTime = 0.0;
    double totalTurnaroundTime = 0.0;

    processes.sort((a, b) => double.parse(a['arrivalTime'])
        .compareTo(double.parse(b['arrivalTime'])));

    for (var process in processes) {
      double arrivalTime = double.parse(process['arrivalTime']);
      double burstTime = double.parse(process['burstTime']);

      double waitingTime = max(0.0, currentTime - arrivalTime);
      process['waitingTime'] = waitingTime.toStringAsFixed(2);

      double turnaroundTime = burstTime + waitingTime;
      process['turnaroundTime'] = turnaroundTime.toStringAsFixed(2);

      currentTime += burstTime;

      totalWaitingTime += waitingTime;
      totalTurnaroundTime += turnaroundTime;
    }

    processes.add({
      'id': 'Average',
      'waitingTime': (totalWaitingTime / processes.length).toStringAsFixed(2),
      'turnaroundTime':
          (totalTurnaroundTime / processes.length).toStringAsFixed(2),
    });

    return processes;
  }


  // SRTF Algorithm

  static List<Map<String, dynamic>> calculateSRTF(
      List<Map<String, dynamic>> processes) {
    double currentTime = 0.0;
    double totalWaitingTime = 0.0;
    double totalTurnaroundTime = 0.0;

    List<Map<String, dynamic>> copiedProcesses =
        processes.map((p) => Map<String, dynamic>.from(p)).toList();

    Map<int, double> remainingBurst = {};
    for (var process in copiedProcesses) {
      int id = process['id'];
      remainingBurst[id] = (process['burstTime'] is String)
          ? double.parse(process['burstTime'])
          : process['burstTime'].toDouble();
    }

    while (remainingBurst.isNotEmpty) {
      int? selectedProcessId;
      double shortestRemaining = double.infinity;

      for (var process in copiedProcesses) {
        int id = process['id'];
        double arrival = process['arrivalTime'] is String
            ? double.parse(process['arrivalTime'])
            : process['arrivalTime'].toDouble();

        if (remainingBurst.containsKey(id) &&
            arrival <= currentTime &&
            remainingBurst[id]! < shortestRemaining) {
          shortestRemaining = remainingBurst[id]!;
          selectedProcessId = id;
        }
      }

      if (selectedProcessId == null) {
        double nextArrival = double.infinity;
        for (var process in copiedProcesses) {
          int id = process['id'];
          if (!remainingBurst.containsKey(id)) continue;
          double arrival = process['arrivalTime'] is String
              ? double.parse(process['arrivalTime'])
              : process['arrivalTime'].toDouble();
          nextArrival = min(nextArrival, arrival);
        }
        currentTime = nextArrival;
        continue;
      }

      remainingBurst[selectedProcessId] =
          remainingBurst[selectedProcessId]! - 1;

      if (remainingBurst[selectedProcessId]! == 0) {
        var process =
            copiedProcesses.firstWhere((p) => p['id'] == selectedProcessId);
        double arrivalTime = process['arrivalTime'] is String
            ? double.parse(process['arrivalTime'])
            : process['arrivalTime'].toDouble();
        double burstTime = process['burstTime'] is String
            ? double.parse(process['burstTime'])
            : process['burstTime'].toDouble();

        double turnaroundTime = currentTime + 1 - arrivalTime;
        double waitingTime = turnaroundTime - burstTime;

        process['waitingTime'] = waitingTime.toStringAsFixed(2);
        process['turnaroundTime'] = turnaroundTime.toStringAsFixed(2);

        totalWaitingTime += waitingTime;
        totalTurnaroundTime += turnaroundTime;

        remainingBurst.remove(selectedProcessId);
      }

      currentTime++;
    }

    int n = copiedProcesses.length;
    copiedProcesses.add({
      'id': 'Average',
      'waitingTime': (totalWaitingTime / n).toStringAsFixed(2),
      'turnaroundTime': (totalTurnaroundTime / n).toStringAsFixed(2),
    });

    return copiedProcesses;
  }

// HPf

  static List<Map<String, dynamic>> calculateHPF(
      List<Map<String, dynamic>> processes) {
    double currentTime = 0.0;
    double totalWaitingTime = 0.0;
    double totalTurnaroundTime = 0.0;

    processes.sort(
        (a, b) => int.parse(b['priority']).compareTo(int.parse(a['priority'])));

    for (var process in processes) {
      double arrivalTime = double.parse(process['arrivalTime']);
      double burstTime = double.parse(process['burstTime']);

      double waitingTime = max(0.0, currentTime - arrivalTime);
      process['waitingTime'] = waitingTime.toStringAsFixed(2);

      double turnaroundTime = burstTime + waitingTime;
      process['turnaroundTime'] = turnaroundTime.toStringAsFixed(2);

      currentTime += burstTime;

      totalWaitingTime += waitingTime;
      totalTurnaroundTime += turnaroundTime;
    }

    processes.add({
      'id': 'Average',
      'waitingTime': (totalWaitingTime / processes.length).toStringAsFixed(2),
      'turnaroundTime':
          (totalTurnaroundTime / processes.length).toStringAsFixed(2),
    });

    return processes;
  }

//RR
  static List<Map<String, dynamic>> calculateRR(
      List<Map<String, dynamic>> processes,
      {int quantum = 3}) {
    double currentTime = 0.0;
    double totalWaitingTime = 0.0;
    double totalTurnaroundTime = 0.0;

    processes.sort((a, b) => double.parse(a['arrivalTime'])
        .compareTo(double.parse(b['arrivalTime'])));

    int n = processes.length;

    Map<int, double> remainingBurst = {};
    for (var process in processes) {
      remainingBurst[process['id']] = double.parse(process['burstTime']);
    }

    List<int> readyQueue = [];
    Set<int> completedProcesses = {};

    while (completedProcesses.length < n) {
      for (var process in processes) {
        int id = process['id'];
        if (!completedProcesses.contains(id) &&
            !readyQueue.contains(id) &&
            double.parse(process['arrivalTime']) <= currentTime) {
          readyQueue.add(id);
        }
      }

      if (readyQueue.isEmpty) {
        currentTime++;
        continue;
      }

      int currentProcessId = readyQueue.removeAt(0);
      var process = processes.firstWhere((p) => p['id'] == currentProcessId);

      double executionTime =
          min(quantum.toDouble(), remainingBurst[currentProcessId]!);
      remainingBurst[currentProcessId] =
          remainingBurst[currentProcessId]! - executionTime;
      currentTime += executionTime;

      for (var proc in processes) {
        int id = proc['id'];
        if (!completedProcesses.contains(id) &&
            !readyQueue.contains(id) &&
            double.parse(proc['arrivalTime']) > currentTime - executionTime &&
            double.parse(proc['arrivalTime']) <= currentTime) {
          readyQueue.add(id);
        }
      }

      if (remainingBurst[currentProcessId]! == 0) {
        double arrivalTime = double.parse(process['arrivalTime']);
        double burstTime = double.parse(process['burstTime']);

        double turnaroundTime = currentTime - arrivalTime;
        double waitingTime = turnaroundTime - burstTime;

        process['waitingTime'] = waitingTime.toStringAsFixed(2);
        process['turnaroundTime'] = turnaroundTime.toStringAsFixed(2);

        totalWaitingTime += waitingTime;
        totalTurnaroundTime += turnaroundTime;

        completedProcesses.add(currentProcessId);
      } else {
        readyQueue.add(currentProcessId);
      }
    }

    processes.add({
      'id': 'Average',
      'waitingTime': (totalWaitingTime / n).toStringAsFixed(2),
      'turnaroundTime': (totalTurnaroundTime / n).toStringAsFixed(2),
    });

    return processes;
  }

  // SRTF Algorithm for random

  static List<Map<String, dynamic>> calculateSRTF2(
      List<Map<String, dynamic>> processes) {
    double currentTime = 0.0;
    double totalWaitingTime = 0.0;
    double totalTurnaroundTime = 0.0;

    List<Map<String, dynamic>> copiedProcesses = processes.map((p) {
      return {
        'id': p['id'],
        'arrivalTime': p['arrivalTime'] is String
            ? double.parse(p['arrivalTime'])
            : p['arrivalTime'].toDouble(),
        'burstTime': p['burstTime'] is String
            ? double.parse(p['burstTime'])
            : p['burstTime'].toDouble(),
        'priority': p['priority'] is String
            ? int.parse(p['priority'])
            : p['priority'].toInt(),
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

      remainingBurst[selectedProcessId] =
          remainingBurst[selectedProcessId]! - 1;

      if (remainingBurst[selectedProcessId]! <= 0) {
        var process =
            copiedProcesses.firstWhere((p) => p['id'] == selectedProcessId);
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
