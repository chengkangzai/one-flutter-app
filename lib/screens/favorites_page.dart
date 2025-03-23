// lib/screens/favorites_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/content_item.dart';
import 'package:flutter_application_1/providers/favorites_provider.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';
import 'package:flutter_application_1/screens/daily_content_page.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final favorites = favoritesProvider.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('收藏夹'),
        actions: [
          if (favorites.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear') {
                  _confirmClearAll(context, favoritesProvider);
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem<String>(
                      value: 'clear',
                      child: Text('清空收藏夹'),
                    ),
                  ],
            ),
        ],
      ),
      body:
          favoritesProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : favorites.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('还没有收藏内容', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(
                      '浏览内容时点击收藏按钮将内容添加到这里',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.separated(
                itemCount: favorites.length,
                separatorBuilder:
                    (context, index) => Divider(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    ),
                itemBuilder: (context, index) {
                  final item = favorites[index];
                  return _buildFavoriteItem(
                    context,
                    item,
                    favoritesProvider,
                    isDarkMode,
                  );
                },
              ),
    );
  }

  Widget _buildFavoriteItem(
    BuildContext context,
    ContentItem item,
    FavoritesProvider favoritesProvider,
    bool isDarkMode,
  ) {
    // Format item type based on category
    String itemType = '文章';
    if (item.category == '0') {
      itemType = '插画';
    } else if (item.category == '3') {
      itemType = '问答';
    } else if (item.category == '8') {
      itemType = '电台';
    }

    return Dismissible(
      key: Key('favorite_${item.contentId}'),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        favoritesProvider.removeFromFavorites(item.contentId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已从收藏夹移除'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: '撤销',
              onPressed: () {
                favoritesProvider.addToFavorites(item);
              },
            ),
          ),
        );
      },
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DailyContentPage(item: item),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              if (item.imgUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: Image.network(
                      item.imgUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color:
                              isDarkMode ? Colors.grey[800] : Colors.grey[200],
                          child: Icon(
                            _getCategoryIcon(item.category),
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                )
              else
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(item.category),
                    color: Colors.grey,
                  ),
                ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? Colors.blue.shade900
                                    : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            itemType,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isDarkMode
                                      ? Colors.blue.shade100
                                      : Colors.blue.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.postDate,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.forward,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '作者: ${item.author.userName}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '0':
        return Icons.image;
      case '1':
        return Icons.article;
      case '3':
        return Icons.question_answer;
      case '8':
        return Icons.radio;
      default:
        return Icons.article;
    }
  }

  void _confirmClearAll(BuildContext context, FavoritesProvider provider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('清空收藏夹'),
            content: const Text('确定要清空收藏夹吗？此操作无法撤销。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  provider.clearAllFavorites();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('收藏夹已清空')));
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('确定'),
              ),
            ],
          ),
    );
  }
}
