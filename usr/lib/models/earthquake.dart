class Earthquake {
  final String id;
  final String place;
  final double magnitude;
  final DateTime time;
  final String url;
  final bool tsunami;
  final double longitude;
  final double latitude;
  final double depth;

  Earthquake({
    required this.id,
    required this.place,
    required this.magnitude,
    required this.time,
    required this.url,
    required this.tsunami,
    required this.longitude,
    required this.latitude,
    required this.depth,
  });

  factory Earthquake.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'];
    final geometry = json['geometry'];
    final coords = geometry['coordinates'];

    return Earthquake(
      id: json['id'] as String,
      place: properties['place'] as String? ?? 'Unknown location',
      magnitude: (properties['mag'] ?? 0.0).toDouble(),
      time: DateTime.fromMillisecondsSinceEpoch(properties['time'] as int),
      url: properties['url'] as String? ?? '',
      tsunami: (properties['tsunami'] as int? ?? 0) == 1,
      longitude: (coords[0] ?? 0.0).toDouble(),
      latitude: (coords[1] ?? 0.0).toDouble(),
      depth: (coords[2] ?? 0.0).toDouble(),
    );
  }
}
