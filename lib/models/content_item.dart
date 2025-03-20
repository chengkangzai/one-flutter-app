import 'package:flutter_application_1/models/author.dart';
import 'package:flutter_application_1/models/tag.dart';
import 'package:flutter_application_1/models/text_author_info.dart';

class ContentItem {
  final String id;
  final String category;
  final int displayCategory;
  final String itemId;
  final String title;
  final String forward;
  final String imgUrl;
  final int likeCount;
  final String postDate;
  final String lastUpdateDate;
  final Author author;
  final String contentId;
  final String contentType;
  final String shareUrl;
  final Map<String, dynamic> shareInfo;
  final List<Tag> tagList;
  final String volume;
  final String picInfo;
  final String wordsInfo;
  final TextAuthorInfo? textAuthorInfo;

  ContentItem({
    required this.id,
    required this.category,
    required this.displayCategory,
    required this.itemId,
    required this.title,
    required this.forward,
    required this.imgUrl,
    required this.likeCount,
    required this.postDate,
    required this.lastUpdateDate,
    required this.author,
    required this.contentId,
    required this.contentType,
    required this.shareUrl,
    required this.shareInfo,
    required this.tagList,
    required this.volume,
    required this.picInfo,
    required this.wordsInfo,
    this.textAuthorInfo,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    final tagListJson = json['tag_list'] as List<dynamic>? ?? [];
    final tagList = tagListJson.map((tag) => Tag.fromJson(tag)).toList();

    TextAuthorInfo? textAuthorInfo;
    if (json['text_author_info'] != null && json['text_author_info'] is Map) {
      textAuthorInfo = TextAuthorInfo.fromJson(json['text_author_info']);
    }

    return ContentItem(
      // Convert all ID fields to strings
      id: json['id']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      // Keep numeric fields as int
      displayCategory: json['display_category'] is int 
          ? json['display_category'] 
          : int.tryParse(json['display_category']?.toString() ?? '0') ?? 0,
      itemId: json['item_id']?.toString() ?? '',
      title: json['title'] ?? '',
      forward: json['forward'] ?? '',
      imgUrl: json['img_url'] ?? '',
      // Handle like_count as int
      likeCount: json['like_count'] is int 
          ? json['like_count'] 
          : int.tryParse(json['like_count']?.toString() ?? '0') ?? 0,
      postDate: json['post_date'] ?? '',
      lastUpdateDate: json['last_update_date'] ?? '',
      author: Author.fromJson(json['author'] ?? {}),
      contentId: json['content_id']?.toString() ?? '',
      contentType: json['content_type']?.toString() ?? '',
      shareUrl: json['share_url'] ?? '',
      shareInfo: json['share_info'] ?? {},
      tagList: tagList,
      volume: json['volume']?.toString() ?? '',
      picInfo: json['pic_info'] ?? '',
      wordsInfo: json['words_info'] ?? '',
      textAuthorInfo: textAuthorInfo,
    );
  }
}