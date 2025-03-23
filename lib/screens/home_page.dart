// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/content_item.dart';
import 'package:intl/intl.dart';
import '../models/one_response.dart';
import '../services/feed_service.dart';
import 'daily_content_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FeedService _apiService = FeedService();
  late Future<OneResponse> _oneResponseFuture;
  String _errorDetails = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _errorDetails = '';
      _oneResponseFuture = _apiService.fetchOneData().catchError((error) {
        setState(() {
          _errorDetails = 'Error: $error';
        });
        throw error;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ONE一个'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData),
        ],
      ),
      body: FutureBuilder<OneResponse>(
        future: _oneResponseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading data',
                      style: TextStyle(
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
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(_errorDetails),
                      ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchData,
                      child: const Text('Retry'),
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
                // Date display
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        day,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(month, style: TextStyle(fontSize: 12)),
                          Text(year, style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      // Weather info
                      Text(
                        '${data.weather.cityName} ${data.weather.temperature}°C',
                        style: TextStyle(color: Colors.grey),
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
            return const Center(child: Text('No data available'));
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: '发现'),
          BottomNavigationBarItem(icon: Icon(Icons.collections), label: '收藏夹'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildContentListItem(ContentItem item) {
    Widget contentWidget;

    // For main daily illustration
    if (item.category == '0') {
      contentWidget = _buildDailyItem(item);
    }
    // Article
    else if (item.category == '1') {
      contentWidget = _buildArticleItem(item);
    }
    // Question
    else if (item.category == '3') {
      contentWidget = _buildQuestionItem(item);
    }
    // Radio
    else if (item.category == '8') {
      contentWidget = _buildRadioItem(item);
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

  Widget _buildDailyItem(ContentItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            item.imgUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Image loading error: $error for URL: ${item.imgUrl}');
              return Container(
                color: Colors.grey[300],
                child: const Center(child: Text('Image not available')),
              );
            },
          ),
        ),

        // Attribution and quote
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '插画 | ${item.picInfo}',
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                item.forward,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (item.textAuthorInfo != null)
                Text(
                  '— ${item.textAuthorInfo!.textAuthorName}',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
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

        // Like button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.favorite_border, color: Colors.grey),
              const SizedBox(width: 8),
              Text('${item.likeCount}', style: TextStyle(color: Colors.grey)),
              const Spacer(),
              const Icon(Icons.share, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  // Other build methods remain the same
  Widget _buildArticleItem(ContentItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        ListTile(
          title: Text(
            item.title,
            style: TextStyle(fontWeight: FontWeight.bold),
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
        ),
        if (item.imgUrl.isNotEmpty)
          Image.network(
            item.imgUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(child: Text('Image not available')),
              );
            },
          ),
      ],
    );
  }

  Widget _buildQuestionItem(ContentItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.tagList.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              '— ${item.tagList.first.title} —',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ListTile(
          title: Text(
            item.title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [const SizedBox(height: 8), Text(item.forward)],
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        if (item.imgUrl.isNotEmpty)
          Image.network(
            item.imgUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(child: Text('Image not available')),
              );
            },
          ),
      ],
    );
  }

  Widget _buildRadioItem(ContentItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            item.title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text('ONE收音机 | ${item.volume}'),
            ],
          ),
          trailing: const Icon(Icons.play_circle_filled, size: 36),
          contentPadding: const EdgeInsets.all(16),
        ),
        if (item.imgUrl.isNotEmpty)
          Image.network(
            item.imgUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(child: Text('Image not available')),
              );
            },
          ),
      ],
    );
  }
}
