import 'package:flutter_application_1/models/author.dart';

class RelatedArticle {
  final String contentId;
  final List<Author> authorList;
  final int category;
  final String title;
  final String cover;

  RelatedArticle({
    required this.contentId,
    required this.authorList,
    required this.category,
    required this.title,
    required this.cover,
  });

  factory RelatedArticle.fromJson(Map<String, dynamic> json) {
    final List<dynamic> authorListJson = json['author_list'] ?? [];
    final authorList =
        authorListJson.map((author) => Author.fromJson(author)).toList();

    return RelatedArticle(
      contentId: json['content_id'].toString(),
      authorList: authorList,
      category: json['category'] ?? 0,
      title: json['title'] ?? '',
      cover: json['cover'] ?? json['home_image'] ?? '',
    );
  }

  String getAuthorsText() {
    if (authorList.isEmpty) return '';
    return authorList.map((author) => author.userName).join('、');
  }
}
