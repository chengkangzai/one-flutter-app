// lib/providers/favorites_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/content_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<ContentItem> _favorites = [];
  static const String _favoritesKey = 'favorites_data';
  bool _isLoading = true;

  FavoritesProvider() {
    _loadFavorites();
  }

  // Getters
  List<ContentItem> get favorites => _favorites;
  bool get isLoading => _isLoading;

  // Check if an item is in favorites
  bool isFavorite(String contentId) {
    return _favorites.any((item) => item.contentId == contentId);
  }

  // Add item to favorites
  Future<void> addToFavorites(ContentItem item) async {
    // Check if already in favorites
    if (isFavorite(item.contentId)) {
      return;
    }

    _favorites.add(item);
    await _saveFavorites();
    notifyListeners();
  }

  // Remove item from favorites
  Future<void> removeFromFavorites(String contentId) async {
    _favorites.removeWhere((item) => item.contentId == contentId);
    await _saveFavorites();
    notifyListeners();
  }

  // Toggle favorite status
  Future<void> toggleFavorite(ContentItem item) async {
    if (isFavorite(item.contentId)) {
      await removeFromFavorites(item.contentId);
    } else {
      await addToFavorites(item);
    }
  }

  // Clear all favorites
  Future<void> clearAllFavorites() async {
    _favorites.clear();
    await _saveFavorites();
    notifyListeners();
  }

  // Load favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? favoritesJson = prefs.getString(_favoritesKey);

      if (favoritesJson != null && favoritesJson.isNotEmpty) {
        final List<dynamic> decodedData = json.decode(favoritesJson);
        _favorites.clear();

        for (var itemJson in decodedData) {
          try {
            final ContentItem item = ContentItem.fromJson(itemJson);
            _favorites.add(item);
          } catch (e) {
            print('Error parsing favorite item: $e');
          }
        }
      }
    } catch (e) {
      print('Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> favoritesMapList =
          _favorites.map((item) => _contentItemToJson(item)).toList();
      final String favoritesJson = json.encode(favoritesMapList);
      await prefs.setString(_favoritesKey, favoritesJson);
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  // Convert ContentItem to JSON
  Map<String, dynamic> _contentItemToJson(ContentItem item) {
    // Create a map that can be easily converted to JSON
    final Map<String, dynamic> itemMap = {
      'id': item.id,
      'category': item.category,
      'display_category': item.displayCategory,
      'item_id': item.itemId,
      'title': item.title,
      'forward': item.forward,
      'img_url': item.imgUrl,
      'like_count': item.likeCount,
      'post_date': item.postDate,
      'last_update_date': item.lastUpdateDate,
      'author': {
        'user_id': item.author.userId,
        'user_name': item.author.userName,
        'desc': item.author.desc,
        'wb_name': item.author.wbName,
        'is_settled': item.author.isSettled,
        'settled_type': item.author.settledType,
        'summary': item.author.summary,
        'fans_total': item.author.fansTotal,
        'web_url': item.author.webUrl,
      },
      'content_id': item.contentId,
      'content_type': item.contentType,
      'share_url': item.shareUrl,
      'share_info': item.shareInfo,
      'tag_list':
          item.tagList
              .map((tag) => {'id': tag.id, 'title': tag.title})
              .toList(),
      'volume': item.volume,
      'pic_info': item.picInfo,
      'words_info': item.wordsInfo,
    };

    // Add textAuthorInfo if it exists
    if (item.textAuthorInfo != null) {
      itemMap['text_author_info'] = {
        'text_author_name': item.textAuthorInfo!.textAuthorName,
        'text_author_work': item.textAuthorInfo!.textAuthorWork,
        'text_author_desc': item.textAuthorInfo!.textAuthorDesc,
      };
    }

    return itemMap;
  }
}
