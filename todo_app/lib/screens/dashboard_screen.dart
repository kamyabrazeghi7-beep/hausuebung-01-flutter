import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../appwrite_service.dart';
import '../services/weather_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _service = AppwriteService();
  String _userName = '';
  Map<String, dynamic>? _weather;
  bool _weatherLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadWeather();
  }

  Future<void> _loadUser() async {
    final user = await _service.getCurrentUser();
    if (user != null && mounted) {
      setState(() => _userName = user.name);
    }
  }

  Future<void> _loadWeather() async {
    try {
      final weather = await WeatherService.getWeather(50.11, 8.68);
      if (mounted) {
        setState(() {
          _weather = weather;
          _weatherLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _weatherLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Color(0xFFF0A500), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFF0A500)),
            onPressed: () async {
              await _service.logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hallo, $_userName 👋',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Hier ist deine Übersicht',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Wetter
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFF0A500),
                  width: 0.3,
                ),
              ),
              child: _weatherLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFF0A500),
                      ),
                    )
                  : _weather == null
                      ? const Text(
                          'Wetter nicht verfügbar',
                          style: TextStyle(color: Colors.grey),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Frankfurt am Main',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_weather!['temperature_2m']}°C',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  WeatherService.getWeatherDescription(
                                    _weather!['weather_code'],
                                  ),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  'Wind: ${_weather!['wind_speed_10m']} km/h',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              WeatherService.getWeatherIcon(
                                _weather!['weather_code'],
                              ),
                              style: const TextStyle(fontSize: 64),
                            ),
                          ],
                        ),
            ),
            const SizedBox(height: 24),

            // Stats
            const Text(
              'Todos',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _statCard('Gesamt', provider.totalCount.toString(), Icons.list, const Color(0xFFF0A500)),
                const SizedBox(width: 12),
                _statCard('Offen', provider.activeCount.toString(), Icons.radio_button_unchecked, Colors.blue),
                const SizedBox(width: 12),
                _statCard('Erledigt', provider.completedCount.toString(), Icons.check_circle, Colors.green),
              ],
            ),
            const SizedBox(height: 24),

            // Fortschritt
            const Text(
              'Fortschritt',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: provider.totalCount == 0
                    ? 0
                    : provider.completedCount / provider.totalCount,
                minHeight: 12,
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF0A500)),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${provider.totalCount == 0 ? 0 : ((provider.completedCount / provider.totalCount) * 100).toInt()}% abgeschlossen',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 24),

            // Navigation
            const Text(
              'Apps',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _navCard('Todos', Icons.check_box, const Color(0xFFF0A500), () {
                  Navigator.pushNamed(context, '/home');
                }),
                const SizedBox(width: 12),
                _navCard('Chat', Icons.chat_bubble, Colors.blue, () {
                  Navigator.pushNamed(context, '/chat');
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _navCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}