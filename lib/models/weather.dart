import 'package:flutter_application_1/models/weather_icons.dart';

class Weather {
  final String cityName;
  final String date;
  final String temperature;
  final String humidity;
  final String climate;
  final String windDirection;
  final String hurricane;
  final WeatherIcons icons;

  Weather({
    required this.cityName,
    required this.date,
    required this.temperature,
    required this.humidity,
    required this.climate,
    required this.windDirection,
    required this.hurricane,
    required this.icons,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['city_name'] ?? '',
      date: json['date'] ?? '',
      // Ensure these are always strings
      temperature: json['temperature']?.toString() ?? '',
      humidity: json['humidity']?.toString() ?? '',
      climate: json['climate'] ?? '',
      windDirection: json['wind_direction'] ?? '',
      hurricane: json['hurricane']?.toString() ?? '',
      icons: WeatherIcons.fromJson(json['icons'] ?? {}),
    );
  }
}