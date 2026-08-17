import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/device.dart';

class AiComparisonService {
  static Future<String> generateVerdict(List<Device> devices) async {
    if (devices.isEmpty) return "No devices selected for comparison.";
    
    // Extract names cleanly for the prompt
    String deviceNames = devices.map((d) => d.name).join(' vs ');
    final prompt = 'Compare these devices and give a clear student-friendly verdict: $deviceNames';

    try {
      final url = Uri.parse('https://tech-comp-app.vercel.app/api/ai-compare');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'] ?? 'No verdict returned from AI.';
      } else {
        throw Exception('Server returned code ${response.statusCode}');
      }
    } catch (e) {
      // OFFLINE MODEL FALL-OVER TRIGGERED AUTOMATICALLY
      return _getOfflineFallbackVerdict(devices);
    }
  }

  static String _getOfflineFallbackVerdict(List<Device> devices) {
    String names = devices.map((d) => d.name).join(', ');
    return "Offline Mode: AI server is temporarily unavailable. Based on core hardware metrics, comparing $names requires evaluating your personal priorities regarding budget, battery retention, and processor efficiency.";
  }
}