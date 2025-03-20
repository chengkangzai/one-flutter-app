import 'package:flutter_application_1/models/tag.dart';

class MenuItem {
  final String contentType;
  final String contentId;
  final String title;
  final Tag? tag;

  MenuItem({
    required this.contentType,
    required this.contentId,
    required this.title,
    this.tag,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    Tag? tag;
    if (json['tag'] != null) {
      tag = Tag.fromJson(json['tag']);
    }

    return MenuItem(
      contentType: json['content_type']?.toString() ?? '',
      contentId: json['content_id']?.toString() ?? '',
      title: json['title'] ?? '',
      tag: tag,
    );
  }
}