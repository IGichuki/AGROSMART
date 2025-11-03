import 'package:flutter/material.dart';

class IrrigationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Irrigation Control'),
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed('/user-dashboard'),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                final state = context
                    .findAncestorStateOfType<_IrrigationContentState>();
                state?.refreshPage();
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _IrrigationContent(),
      ),
    );
  }
}

class _IrrigationContent extends StatefulWidget {
  @override
  State<_IrrigationContent> createState() => _IrrigationContentState();
}

class _IrrigationContentState extends State<_IrrigationContent> {
  void refreshPage() {
    setState(() {
      // Add logic to reload or refresh data if needed
    });
  }

  bool isIrrigating = false;
  DateTime? lastIrrigation;
  Duration? lastDuration;
  DateTime? nextScheduled;
  List<Map<String, dynamic>> history = [];
  bool isAutoMode = false;
  Duration manualDuration = Duration(minutes: 10);

  void startIrrigation() {
    setState(() {
      isIrrigating = true;
      lastIrrigation = DateTime.now();
      lastDuration = manualDuration;
      history.insert(0, {
        'date': lastIrrigation,
        'duration': manualDuration,
        'mode': isAutoMode ? 'Auto' : 'Manual',
      });
    });
    // TODO: Trigger irrigation hardware/API
    Future.delayed(manualDuration, stopIrrigation);
  }

  void stopIrrigation() {
    setState(() {
      isIrrigating = false;
    });
    // TODO: Stop irrigation hardware/API
  }

  void scheduleIrrigation(DateTime dateTime, Duration duration) {
    setState(() {
      nextScheduled = dateTime;
    });
    // TODO: Schedule irrigation in backend
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isIrrigating
                            ? Icons.water_drop
                            : Icons.water_drop_outlined,
                        color: isIrrigating ? Colors.blue : Colors.grey,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isIrrigating
                            ? 'Irrigation Active'
                            : 'Irrigation Inactive',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isIrrigating ? Colors.blue : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Last Irrigation: ' +
                        (lastIrrigation != null
                            ? '${lastIrrigation!.toLocal().toString().split('.')[0]} (${lastDuration?.inMinutes ?? 0} min)'
                            : '--'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Next Scheduled: ' +
                        (nextScheduled != null
                            ? nextScheduled!.toLocal().toString().split('.')[0]
                            : '--'),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Control Panel',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: isAutoMode,
                        onChanged: (val) {
                          setState(() {
                            isAutoMode = val;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                      Text(isAutoMode ? 'Auto' : 'Manual'),
                    ],
                  ),
                  if (!isAutoMode) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Duration:'),
                        const SizedBox(width: 8),
                        DropdownButton<int>(
                          value: manualDuration.inMinutes,
                          items: [5, 10, 15, 20, 30]
                              .map(
                                (min) => DropdownMenuItem(
                                  value: min,
                                  child: Text('$min min'),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                manualDuration = Duration(minutes: val);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.play_arrow),
                          label: Text('Start'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: isIrrigating ? null : startIrrigation,
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          icon: Icon(Icons.stop),
                          label: Text('Stop'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: isIrrigating ? stopIrrigation : null,
                        ),
                      ],
                    ),
                  ],
                  if (isAutoMode) ...[
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: Icon(Icons.schedule),
                      label: Text('Set Schedule'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        // TODO: Show schedule picker dialog
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Irrigation History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: history.isEmpty
                ? Center(child: Text('No irrigation events yet.'))
                : ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, idx) {
                      final item = history[idx];
                      return ListTile(
                        leading: Icon(Icons.history, color: Colors.grey[700]),
                        title: Text(
                          '${item['date'].toLocal().toString().split('.')[0]}',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          '${item['duration'].inMinutes} min • ${item['mode']}',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
