import 'package:flutter/material.dart';
import '../models/earthquake.dart';
import 'package:intl/intl.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  Color _getMagnitudeColor(double mag) {
    if (mag >= 7.0) return Colors.red.shade900;
    if (mag >= 6.0) return Colors.red;
    if (mag >= 5.0) return Colors.orange;
    if (mag >= 4.0) return Colors.yellow.shade700;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final quake = ModalRoute.of(context)!.settings.arguments as Earthquake;
    final magColor = _getMagnitudeColor(quake.magnitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: magColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: magColor, width: 4),
                      ),
                      child: Center(
                        child: Text(
                          'M ${quake.magnitude.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: magColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(context, Icons.location_on, 'Location', quake.place),
                          const Divider(),
                          _buildDetailRow(
                            context,
                            Icons.access_time,
                            'Time',
                            DateFormat.yMMMMEEEEd().add_jms().format(quake.time),
                          ),
                          const Divider(),
                          _buildDetailRow(context, Icons.map, 'Coordinates', '${quake.latitude.toStringAsFixed(4)}, ${quake.longitude.toStringAsFixed(4)}'),
                          const Divider(),
                          _buildDetailRow(context, Icons.vertical_align_bottom, 'Depth', '${quake.depth.toStringAsFixed(1)} km'),
                          if (quake.tsunami) ...[
                            const Divider(),
                            _buildDetailRow(context, Icons.warning, 'Tsunami Warning', 'Possible Tsunami generated. Check local authorities.', color: Colors.red),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (quake.url.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          // In a real app we would use url_launcher here
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Would open USGS URL: ${quake.url}')),
                          );
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('View on USGS Website'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: color,
                    fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
