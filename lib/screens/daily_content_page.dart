// lib/screens/daily_content_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/content_item.dart';

class DailyContentPage extends StatelessWidget {
  final ContentItem item;

  const DailyContentPage({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildContent()],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite_border),
                  const SizedBox(width: 4),
                  Text('${item.likeCount}'),
                ],
              ),
              const Icon(Icons.bookmark_border),
              const Icon(Icons.comment_outlined),
              const Icon(Icons.share),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Daily illustration
    if (item.category == '0') {
      return _buildDailyContent();
    }
    // Article
    else if (item.category == '1') {
      return _buildArticleContent();
    }
    // Question
    else if (item.category == '3') {
      return _buildQuestionContent();
    }
    // Radio
    else if (item.category == '8') {
      return _buildRadioContent();
    }
    // Default
    else {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Content not available for this type',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
  }

  Widget _buildDailyContent() {
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
              const SizedBox(height: 24),
              Text(
                item.forward,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (item.textAuthorInfo != null) ...[
                Text(
                  '— ${item.textAuthorInfo!.textAuthorName}',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  item.textAuthorInfo!.textAuthorWork,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  item.textAuthorInfo!.textAuthorDesc,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArticleContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '文 / ${item.author.userName}',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Text(item.forward, style: TextStyle(fontSize: 16, height: 1.6)),
              const SizedBox(height: 16),
              // This would be where the full article content would go
              Text(
                '(This is a placeholder for the full article content, which would be fetched from a separate API call with the article ID: ${item.contentId})',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              // Author info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(item.author.webUrl),
                      onBackgroundImageError: (e, s) => {},
                      backgroundColor: Colors.grey[300],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.author.userName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            item.author.summary,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Follow author functionality
                      },
                      child: const Text('关注'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tag if available
        if (item.tagList.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              '— ${item.tagList.first.title} —',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),

        // Question
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                item.forward,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),

              // Answer placeholder
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '(This is a placeholder for the answer content, which would be fetched from a separate API call)',
                      style: TextStyle(fontSize: 16, height: 1.6),
                    ),
                    const SizedBox(height: 16),
                    if (item.author.userId != '0') // Check if there's an author
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(item.author.webUrl),
                            onBackgroundImageError: (e, s) => {},
                            backgroundColor: Colors.grey[300],
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.author.userName,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                item.author.summary,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Image if available
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

  Widget _buildRadioContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image if available
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

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'ONE收音机 | ${item.volume}',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Audio player placeholder
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.play_circle_filled),
                      iconSize: 48,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Host info
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(item.author.webUrl),
                    onBackgroundImageError: (e, s) => {},
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.author.userName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        item.author.summary,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Description placeholder
              Text(
                '(This is a placeholder for the full radio transcript or description, which would be fetched from a separate API call with the radio ID: ${item.contentId})',
                style: TextStyle(fontSize: 16, height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
