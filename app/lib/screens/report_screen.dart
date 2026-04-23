import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:firebase_database/firebase_database.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _report = '';
  bool _loading = false;

  Future<void> _generateReport() async {
    setState(() { _loading = true; _report = ''; });

    // Firebase se latest data lo
    final snapshot = await FirebaseDatabase.instance
        .ref('neurogrip/sensor_data').get();
    final data = snapshot.value as Map? ?? {};

    final model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: 'YOUR_GEMINI_API_KEY', // apni key dalna
    );

    final prompt = '''
You are a medical AI assistant analyzing Parkinson's tremor data.

Sensor Data:
- Accelerometer X: ${data['accel_x']} g
- Accelerometer Y: ${data['accel_y']} g  
- Accelerometer Z: ${data['accel_z']} g
- Gyroscope X: ${data['gyro_x']} °/s
- Gyroscope Y: ${data['gyro_y']} °/s
- Gyroscope Z: ${data['gyro_z']} °/s
- Tremor Severity: ${data['severity']}

Generate a concise medical report with:
1. Current tremor assessment
2. Severity analysis
3. Recommendations for patient and caregiver
Keep it simple and in plain English.
    ''';

    final response = await model.generateContent([Content.text(prompt)]);
    setState(() {
      _report = response.text ?? 'Report generation failed.';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini AI Report', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0A0E1A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _generateReport,
                icon: const Icon(Icons.auto_awesome, color: Colors.white),
                label: Text(_loading ? 'Generating...' : 'Generate AI Report',
                    style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const CircularProgressIndicator(color: Color(0xFF00BCD4)),
            if (_report.isNotEmpty)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1F2E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Text(_report, style: const TextStyle(color: Colors.white, height: 1.6)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
