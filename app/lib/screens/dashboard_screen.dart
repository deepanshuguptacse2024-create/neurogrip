import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'report_screen.dart';
import 'blockchain_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref('neurogrip/sensor_data');

  double _accelX = 0, _accelY = 0, _accelZ = 0;
  double _gyroX = 0, _gyroY = 0, _gyroZ = 0;
  String _severity = 'Normal';
  List<FlSpot> _accelHistory = [];
  int _tick = 0;

  @override
  void initState() {
    super.initState();
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          _accelX = (data['accel_x'] ?? 0).toDouble();
          _accelY = (data['accel_y'] ?? 0).toDouble();
          _accelZ = (data['accel_z'] ?? 0).toDouble();
          _gyroX = (data['gyro_x'] ?? 0).toDouble();
          _gyroY = (data['gyro_y'] ?? 0).toDouble();
          _gyroZ = (data['gyro_z'] ?? 0).toDouble();
          _severity = data['severity'] ?? 'Normal';

          _accelHistory.add(FlSpot(_tick.toDouble(), _accelX));
          if (_accelHistory.length > 20) _accelHistory.removeAt(0);
          _tick++;
        });
      }
    });
  }

  Color _severityColor() {
    switch (_severity) {
      case 'Severe': return Colors.red;
      case 'Moderate': return Colors.orange;
      case 'Mild': return Colors.yellow;
      default: return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NeuroGrip Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0A0E1A),
        actions: [
          IconButton(
  icon: const Icon(Icons.favorite, color: Colors.pink),
  onPressed: () => Navigator.push(context,
      MaterialPageRoute(builder: (_) => const CompanionScreen())),
),
          IconButton(
            icon: const Icon(Icons.description, color: Color(0xFF00BCD4)),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ReportScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.link, color: Color(0xFF00BCD4)),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BlockchainScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Severity Badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _severityColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _severityColor()),
              ),
              child: Column(
                children: [
                  Text('Tremor Severity',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  Text(_severity,
                      style: TextStyle(
                          color: _severityColor(),
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sensor Cards Row
            Row(
              children: [
                _sensorCard('Accel X', _accelX, 'g'),
                const SizedBox(width: 8),
                _sensorCard('Accel Y', _accelY, 'g'),
                const SizedBox(width: 8),
                _sensorCard('Accel Z', _accelZ, 'g'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _sensorCard('Gyro X', _gyroX, '°/s'),
                const SizedBox(width: 8),
                _sensorCard('Gyro Y', _gyroY, '°/s'),
                const SizedBox(width: 8),
                _sensorCard('Gyro Z', _gyroZ, '°/s'),
              ],
            ),
            const SizedBox(height: 16),

            // Live Chart
            Container(
              height: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _accelHistory.isEmpty
                  ? const Center(child: Text('Waiting for data...', style: TextStyle(color: Colors.grey)))
                  : LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _accelHistory,
                            isCurved: true,
                            color: const Color(0xFF00BCD4),
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sensorCard(String label, double value, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
            const SizedBox(height: 4),
            Text('${value.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(unit, style: const TextStyle(color: Colors.cyan, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
