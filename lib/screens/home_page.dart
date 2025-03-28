// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/content_item.dart';
import 'package:flutter_application_1/providers/cache_provider.dart';
import 'package:flutter_application_1/providers/favorites_provider.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';
import 'package:flutter_application_1/screens/favorites_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/one_response.dart';
import '../services/feed_service.dart';
import 'daily_content_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FeedService _apiService = FeedService();
  late Future<OneResponse> _oneResponseFuture;
  String _errorDetails = '';
  bool _isRefreshing = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchData(forceRefresh: false);
  }

  Future<void> _fetchData({bool forceRefresh = true}) async {
    setState(() {
      _errorDetails = '';
      _isRefreshing = true;
    });

    try {
      final cacheProvider = Provider.of<CacheProvider>(context, listen: false);

      // Use offline mode setting if not explicitly forcing refresh
      final shouldForceRefresh =
          forceRefresh ? true : !(cacheProvider.offlineModeEnabled);

      setState(() {
        _oneResponseFuture = _apiService
            .fetchOneData(forceRefresh: shouldForceRefresh)
            .catchError((error) {
              setState(() {
                _errorDetails = 'Error: $error';
                _isRefreshing = false;
              });
              throw error;
            });
      });

      // Update cache size in provider after fetch
      await _oneResponseFuture;
      await cacheProvider.refreshSettings();
    } catch (e) {
      print('Error in _fetchData: $e');
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: _currentIndex == 0 ? _buildHomeAppBar(isDarkMode) : null,
      body: _getBodyForIndex(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: '发现'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: '收藏夹'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 3) {
            // "My" tab
            Navigator.pushNamed(context, '/settings');
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }

  AppBar _buildHomeAppBar(bool isDarkMode) {
    return AppBar(
      title: const Text('ONE一个'),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed:
              () =>
                  Provider.of<ThemeProvider>(
                    context,
                    listen: false,
                  ).toggleTheme(),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => Navigator.pushNamed(context, '/settings'),
        ),
        IconButton(
          icon:
              _isRefreshing
                  ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).appBarTheme.foregroundColor!,
                      ),
                    ),
                  )
                  : const Icon(Icons.refresh),
          onPressed:
              _isRefreshing ? null : () => _fetchData(forceRefresh: true),
        ),
      ],
    );
  }

  Widget _getBodyForIndex(int index) {
    switch (index) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildDiscoveryContent();
      case 2:
        return const FavoritesPage();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () => _fetchData(forceRefresh: true),
      child: FutureBuilder<OneResponse>(
        future: _oneResponseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !_isRefreshing) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Check if we're offline and show appropriate message
            final cacheProvider = Provider.of<CacheProvider>(
              context,
              listen: false,
            );
            final isOfflineMode = cacheProvider.offlineModeEnabled;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isOfflineMode ? '没有可用的缓存数据' : '加载数据时出错',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}'),
                    if (_errorDetails.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              Provider.of<ThemeProvider>(context).isDarkMode
                                  ? Colors.black26
                                  : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(_errorDetails),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (isOfflineMode) ...[
                      const Text(
                        '您处于离线模式。要获取新数据，请禁用设置中的离线模式或在连接时重试。',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],
                    ElevatedButton(
                      onPressed: () => _fetchData(forceRefresh: true),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!.data;

            // Format the date for display
            final dateStr = data.date;
            DateTime dateTime = DateTime.now();
            try {
              dateTime = DateTime.parse(dateStr);
            } catch (e) {
              // Use current date if parsing fails
              print('Date parsing error: $e for date: $dateStr');
            }

            final day = dateTime.day.toString();
            final month = DateFormat('MMM').format(dateTime);
            final year = dateTime.year.toString();

            return Column(
              children: [
                // Date display with network/cache indicator
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        day,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(month, style: const TextStyle(fontSize: 12)),
                          Text(year, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      // Cache status indicator
                      Consumer<CacheProvider>(
                        builder: (context, cacheProvider, child) {
                          return Row(
                            children: [
                              Icon(
                                cacheProvider.offlineModeEnabled
                                    ? Icons.offline_pin
                                    : Icons.cloud_done,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              // Weather info
                              Text(
                                '${data.weather.cityName} ${data.weather.temperature}°C',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Content list
                Expanded(
                  child: ListView.builder(
                    itemCount: data.contentList.length,
                    itemBuilder: (context, index) {
                      final item = data.contentList[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => DailyContentPage(item: item),
                            ),
                          );
                        },
                        child: _buildContentListItem(item),
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('暂无数据'));
          }
        },
      ),
    );
  }

  Widget _buildDiscoveryContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.explore, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('发现功能即将上线', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text('敬请期待', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildContentListItem(ContentItem item) {
    Widget contentWidget;
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(item.contentId);

    // For main daily illustration
    if (item.category == '0') {
      contentWidget = _buildDailyItem(item, isFavorite);
    }
    // Article
    else if (item.category == '1') {
      contentWidget = _buildArticleItem(item, isFavorite);
    }
    // Question
    else if (item.category == '3') {
      contentWidget = _buildQuestionItem(item, isFavorite);
    }
    // Radio
    else if (item.category == '8') {
      contentWidget = _buildRadioItem(item, isFavorite);
    }
    // Default case
    else {
      contentWidget = ListTile(
        title: Text(item.title),
        subtitle: Text(item.forward),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      child: contentWidget,
    );
  }

  Widget _buildDailyItem(ContentItem item, bool isFavorite) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image with caching
        AspectRatio(
          aspectRatio: 16 / 9,
          child: _cachedNetworkImage(item.imgUrl, fit: BoxFit.cover),
        ),

        // Attribution and quote
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '插画 | ${item.picInfo}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                item.forward,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (item.textAuthorInfo != null)
                Text(
                  '— ${item.textAuthorInfo!.textAuthorName}',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '文字 · 图片 · 歌曲 · 电影 · 谈话',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Like and favorite buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.favorite_border, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                '${item.likeCount}',
                style: const TextStyle(color: Colors.grey),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _toggleFavorite(context, item),
                child: Icon(
                  isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  color: isFavorite ? Colors.blue : Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.share, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method for cached network images
  Widget _cachedNetworkImage(
    String url, {
    BoxFit fit = BoxFit.cover,
    double? height,
  }) {
    // Check if we're in offline mode
    final cacheProvider = Provider.of<CacheProvider>(context, listen: false);
    final isOfflineMode = cacheProvider.offlineModeEnabled;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    return Image.network(
      url,
      fit: fit,
      height: height,
      width: double.infinity,
      // Don't try to load from network in offline mode
      errorBuilder: (context, error, stackTrace) {
        print('Image loading error: $error for URL: $url');
        return Container(
          height: height,
          color: isDarkMode ? Colors.grey[900] : Colors.grey[300],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.image_not_supported, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  isOfflineMode ? 'Image not cached' : 'Image not available',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Article list item
  Widget _buildArticleItem(ContentItem item, bool isFavorite) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        ListTile(
          title: Text(
            item.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('文 / ${item.author.userName}'),
              const SizedBox(height: 8),
              Text(item.forward),
            ],
          ),
          contentPadding: const EdgeInsets.all(16),
          trailing: GestureDetector(
            onTap: () => _toggleFavorite(context, item),
            child: Icon(
              isFavorite ? Icons.bookmark : Icons.bookmark_border,
              color: isFavorite ? Colors.blue : Colors.grey,
            ),
          ),
        ),
        if (item.imgUrl.isNotEmpty)
          _cachedNetworkImage(item.imgUrl, height: 200),
      ],
    );
  }

  // Question list item
  Widget _buildQuestionItem(ContentItem item, bool isFavorite) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.tagList.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              '— ${item.tagList.first.title} —',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ListTile(
          title: Text(
            item.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [const SizedBox(height: 8), Text(item.forward)],
          ),
          contentPadding: const EdgeInsets.all(16),
          trailing: GestureDetector(
            onTap: () => _toggleFavorite(context, item),
            child: Icon(
              isFavorite ? Icons.bookmark : Icons.bookmark_border,
              color: isFavorite ? Colors.blue : Colors.grey,
            ),
          ),
        ),
        if (item.imgUrl.isNotEmpty)
          _cachedNetworkImage(item.imgUrl, height: 200),
      ],
    );
  }

  // Radio list item
  Widget _buildRadioItem(ContentItem item, bool isFavorite) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            item.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text('ONE收音机 | ${item.volume}'),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _toggleFavorite(context, item),
                child: Icon(
                  isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  color: isFavorite ? Colors.blue : Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.play_circle_filled, size: 36),
            ],
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        if (item.imgUrl.isNotEmpty)
          _cachedNetworkImage(item.imgUrl, height: 200),
      ],
    );
  }

  void _toggleFavorite(BuildContext context, ContentItem item) {
    final favoritesProvider = Provider.of<FavoritesProvider>(
      context,
      listen: false,
    );
    final isFavorite = favoritesProvider.isFavorite(item.contentId);

    favoritesProvider.toggleFavorite(item);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isFavorite ? '已移除收藏' : '已加入收藏'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
