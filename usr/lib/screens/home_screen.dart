import 'package:flutter/material.dart';
import '../models/earthquake.dart';
import '../services/usgs_service.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UsgsService _usgsService = UsgsService();
  late Future<List<Earthquake>> _earthquakesFuture;

  @override
  void initState() {
    super.initState();
    _earthquakesFuture = _usgsService.fetchSignificantEarthquakesPastWeek();
  }

  Future<void> _refresh() async {
    setState(() {
      _earthquakesFuture = _usgsService.fetchSignificantEarthquakesPastWeek();
    });
  }

  Color _getMagnitudeColor(double mag) {
    if (mag >= 7.0) return Colors.red.shade900;
    if (mag >= 6.0) return Colors.red;
    if (mag >= 5.0) return Colors.orange;
    if (mag >= 4.0) return Colors.yellow.shade700;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Earthquakes (7 Days)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          )
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<Earthquake>>(
          future: _earthquakesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Failed to load data: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No significant earthquakes reported recently.'),
              );
            }

            final earthquakes = snapshot.data!;

            return RefreshIndicator(
              onRefresh: _refresh,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 1;
                  if (constraints.maxWidth > 900) {
                    crossAxisCount = 3;
                  } else if (constraints.maxWidth > 600) {
                    crossAxisCount = 2;
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: isMobile ? 3 : 2.5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: earthquakes.length,
                    itemBuilder: (context, index) {
                      final quake = earthquakes[index];
                      final magColor = _getMagnitudeColor(quake.magnitude);

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/detail',
                              arguments: quake,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: magColor.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: magColor, width: 2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      quake.magnitude.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: magColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        quake.place,
                                        style: Theme.of(context).textTheme.titleMedium,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat.yMMMd().add_jm().format(quake.time),
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
