import 'package:flutter_application_1/models/menu_item.dart';
class Menu {
  final String vol;
  final List<MenuItem> list;

  Menu({required this.vol, required this.list});

  factory Menu.fromJson(Map<String, dynamic> json) {
    final listJson = json['list'] as List<dynamic>? ?? [];
    final menuItems = listJson.map((item) => MenuItem.fromJson(item)).toList();

    return Menu(
      vol: json['vol']?.toString() ?? '',
      list: menuItems,
    );
  }
}