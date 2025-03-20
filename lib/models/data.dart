import 'package:flutter_application_1/models/content_item.dart';
import 'package:flutter_application_1/models/menu.dart';
import 'package:flutter_application_1/models/weather.dart';

class Data {
  final String id;
  final Weather weather;
  final String date;
  final List<ContentItem> contentList;
  final Menu menu;

  Data({
    required this.id,
    required this.weather,
    required this.date,
    required this.contentList,
    required this.menu,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    final contentListJson = json['content_list'] as List<dynamic>? ?? [];
    final contentList = contentListJson
        .map((item) => ContentItem.fromJson(item))
        .toList();

    return Data(
      // Convert id to String if it's an int
      id: json['id']?.toString() ?? '',
      weather: Weather.fromJson(json['weather'] ?? {}),
      date: json['date'] ?? '',
      contentList: contentList,
      menu: Menu.fromJson(json['menu'] ?? {}),
    );
  }
}