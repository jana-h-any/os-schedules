import 'dart:math';

class Scheduler {

  // FCFS Algorithm
  static List<Map<String, dynamic>> calculateFCFS(
      List<Map<String, dynamic>> processes,
      {List<Map<String, dynamic>>? executionOrder}) {
    executionOrder?.clear();

    double currentTime = 0.0;
    double totalWaitingTime = 0.0;
    double totalTurnaroundTime = 0.0;

    processes.sort((a, b) => double.parse(a['arrivalTime'])
        .compareTo(double.parse(b['arrivalTime'])));

    for (var process in processes) {
      double arrivalTime = double.parse(process['arrivalTime']);
      double burstTime = double.parse(process['burstTime']);

      // Fix: Start from the arrival time if no process has arrived yet
      if (currentTime < arrivalTime) {
        currentTime = arrivalTime;
      }

      double waitingTime = currentTime - arrivalTime;
      process['waitingTime'] = waitingTime.toStringAsFixed(2);

      double turnaroundTime = burstTime + waitingTime;
      process['turnaroundTime'] = turnaroundTime.toStringAsFixed(2);

      executionOrder?.add({
        'id': process['id'],
        'start': currentTime.toStringAsFixed(2),
        'end': (currentTime + burstTime).toStringAsFixed(2),
      });

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
      List<Map<String, dynamic>> processes,
      {List<Map<String, dynamic>>? executionOrder}) {
    executionOrder?.clear();

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

    int? lastProcessId;
    double? blockStartTime;

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

      // لو العملية اتغيرت، نسجل البلوك اللي فات
      if (selectedProcessId != lastProcessId) {
        if (lastProcessId != null && blockStartTime != null) {
          executionOrder?.add({
            'id': lastProcessId,
            'start': blockStartTime.toStringAsFixed(2),
            'end': currentTime.toStringAsFixed(2),
          });
        }
        blockStartTime = currentTime;
        lastProcessId = selectedProcessId;
      }

      // Execute current process for 1 time unit
      remainingBurst[selectedProcessId] =
          remainingBurst[selectedProcessId]! - 1;

      if (remainingBurst[selectedProcessId]! == 0) {
        // لما البروسيس تخلص نضيف آخر بلوك
        executionOrder?.add({
          'id': selectedProcessId,
          'start': blockStartTime!.toStringAsFixed(2),
          'end': (currentTime + 1).toStringAsFixed(2),
        });

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

        // Reset block tracking
        lastProcessId = null;
        blockStartTime = null;
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

  // HPF Algorithm
  static List<Map<String, dynamic>> calculateHPF(
      List<Map<String, dynamic>> processes,
      {List<Map<String, dynamic>>? executionOrder}) {
    executionOrder?.clear();

    double currentTime = 0.0;
    double totalWaitingTime = 0.0;
    double totalTurnaroundTime = 0.0;

    List<Map<String, dynamic>> processesCopy =
    processes.map((p) => Map<String, dynamic>.from(p)).toList();

    Set<int> completed = {};
    int n = processes.length;

    while (completed.length < n) {

      List<Map<String, dynamic>> available = processesCopy.where((p) {
        int id = p['id'];
        double arrival = double.parse(p['arrivalTime']);
        return arrival <= currentTime && !completed.contains(id);
      }).toList();

      if (available.isEmpty) {

        var next = processesCopy
            .where((p) => !completed.contains(p['id']))
            .reduce((a, b) =>
        double.parse(a['arrivalTime']) < double.parse(b['arrivalTime'])
            ? a
            : b);

        double arrivalTime = double.parse(next['arrivalTime']);
        double burstTime = double.parse(next['burstTime']);
        int id = next['id'];

        currentTime = arrivalTime;
        double waitingTime = 0.0;
        double turnaroundTime = burstTime;

        next['waitingTime'] = waitingTime.toStringAsFixed(2);
        next['turnaroundTime'] = turnaroundTime.toStringAsFixed(2);

        executionOrder?.add({
          'id': id,
          'start': arrivalTime.toStringAsFixed(2),
          'end': (arrivalTime + burstTime).toStringAsFixed(2),
        });

        currentTime += burstTime;
        totalWaitingTime += waitingTime;
        totalTurnaroundTime += turnaroundTime;
        completed.add(id);
        continue;
      }

      // لو فيه عمليات وصلت، نختار أعلى Priority
      available.sort((a, b) =>
          int.parse(b['priority']).compareTo(int.parse(a['priority'])));

      var process = available.first;
      int id = process['id'];
      double arrivalTime = double.parse(process['arrivalTime']);
      double burstTime = double.parse(process['burstTime']);

      double waitingTime = currentTime - arrivalTime;
      double turnaroundTime = waitingTime + burstTime;

      process['waitingTime'] = waitingTime.toStringAsFixed(2);
      process['turnaroundTime'] = turnaroundTime.toStringAsFixed(2);

      executionOrder?.add({
        'id': id,
        'start': currentTime.toStringAsFixed(2),
        'end': (currentTime + burstTime).toStringAsFixed(2),
      });

      currentTime += burstTime;
      totalWaitingTime += waitingTime;
      totalTurnaroundTime += turnaroundTime;
      completed.add(id);
    }

    processesCopy.add({
      'id': 'Average',
      'waitingTime': (totalWaitingTime / n).toStringAsFixed(2),
      'turnaroundTime': (totalTurnaroundTime / n).toStringAsFixed(2),
    });

    return processesCopy;
  }

  // Round Robin
  static List<Map<String, dynamic>> calculateRR(
      List<Map<String, dynamic>> processes,
      {int quantum = 3,
        List<Map<String, dynamic>>? executionOrder}) {
    executionOrder?.clear();

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

      executionOrder?.add({
        'id': currentProcessId,
        'start': currentTime.toStringAsFixed(2),
        'end': (currentTime + executionTime).toStringAsFixed(2),
      });

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
      List<Map<String, dynamic>> processes,
      {List<Map<String, dynamic>>? executionOrder}) {
    executionOrder?.clear();

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

    int? lastProcessId;
    double? startTime;

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

      // Switch context if process changed
      if (selectedProcessId != lastProcessId) {
        if (lastProcessId != null && startTime != null) {
          executionOrder?.add({
            'id': lastProcessId,
            'start': startTime.toStringAsFixed(2),
            'end': currentTime.toStringAsFixed(2),
          });
        }
        startTime = currentTime;
        lastProcessId = selectedProcessId;
      }

      // Execute 1 time unit
      remainingBurst[selectedProcessId] =
          remainingBurst[selectedProcessId]! - 1;

      if (remainingBurst[selectedProcessId]! <= 0) {
        // End current block
        executionOrder?.add({
          'id': selectedProcessId,
          'start': startTime!.toStringAsFixed(2),
          'end': (currentTime + 1).toStringAsFixed(2),
        });

        var process = copiedProcesses
            .firstWhere((p) => p['id'] == selectedProcessId);
        double arrivalTime = process['arrivalTime'];
        double burstTime = process['burstTime'];

        double turnaroundTime = currentTime + 1 - arrivalTime;
        double waitingTime = turnaroundTime - burstTime;

        process['waitingTime'] = waitingTime.toStringAsFixed(2);
        process['turnaroundTime'] = turnaroundTime.toStringAsFixed(2);

        totalWaitingTime += waitingTime;
        totalTurnaroundTime += turnaroundTime;

        remainingBurst.remove(selectedProcessId);
        lastProcessId = null;
        startTime = null;
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
