import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/earthquake.dart';

class UsgsService {
  // Use the "all earthquakes from the past day" or "significant past week" feed for a good mix of data.
  // We'll use 4.5+ from the past 7 days so it consistently has relevant, actionable data.
  static const String _feedUrl = 'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/4.5_week.geojson';

  Future<List<Earthquake>> fetchRecentEarthquakes() async {
    try {
      final response = await http.get(Uri.parse(_feedUrl)).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List features = data['features'] ?? [];
        return features.map((json) => Earthquake.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load earthquake data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }
}
