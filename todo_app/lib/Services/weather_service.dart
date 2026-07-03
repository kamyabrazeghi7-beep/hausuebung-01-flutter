import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static Future<Map<String, dynamic>> getWeather(double lat, double lon) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon'
      '&current=temperature_2m,weather_code,wind_speed_10m'
      '&timezone=auto',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['current'];
    } else {
      throw Exception('Wetter konnte nicht geladen werden');
    }
  }

  static String getWeatherIcon(int code) {
    if (code == 0) return '☀️';
    if (code <= 3) return '⛅️';
    if (code <= 48) return '🌫';
    if (code <= 67) return '🌧';
    if (code <= 77) return '❄️';
    if (code <= 82) return '🌦';
    if (code <= 99) return '⛈';
    return '🌡';
  }

  static String getWeatherDescription(int code) {
    if (code == 0) return 'Klar';
    if (code <= 3) return 'Bewölkt';
    if (code <= 48) return 'Neblig';
    if (code <= 67) return 'Regen';
    if (code <= 77) return 'Schnee';
    if (code <= 82) return 'Schauer';
    if (code <= 99) return 'Gewitter';
    return 'Unbekannt';
  }
}