
class WeatherIcons {
  final String day;
  final String night;

  WeatherIcons({required this.day, required this.night});

  factory WeatherIcons.fromJson(Map<String, dynamic> json) {
    return WeatherIcons(
      day: json['day'] ?? '',
      night: json['night'] ?? '',
    );
  }
}