// lib/screens/daily_content_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/content_item.dart';
import 'package:flutter_application_1/models/related_article.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';
import 'package:flutter_application_1/services/audio_service.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/one_response.dart';
import '../services/article_service.dart';
import '../widgets/audio_player_widget.dart';

class DailyContentPage extends StatefulWidget {
  final ContentItem item;

  const DailyContentPage({Key? key, required this.item}) : super(key: key);

  @override
  State<DailyContentPage> createState() => _DailyContentPageState();
}

class _DailyContentPageState extends State<DailyContentPage> {
  final ArticleService _articleService = ArticleService();
  bool _isLoading = true;
  String _articleContent = '';
  List<String> _paragraphs = [];
  List<String> _images = [];
  Map<String, dynamic> _questionData = {};
  Map<String, dynamic> _radioData = {};
  List<RelatedArticle> _relatedArticles = [];
  String _errorMessage = '';
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // For article types (category '1')
      if (widget.item.category == '1') {
        await _loadArticleData();
      }
      // For question types (category '3')
      else if (widget.item.category == '3') {
        await _loadQuestionData();
      }
      // For radio types (category '8')
      else if (widget.item.category == '8') {
        await _loadRadioData();
      }
      // For other content types, we'll just use the content available in the item
      else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading content: $e';
      });
    }
  }

  Future<void> _loadArticleData() async {
    try {
      final content = await _articleService.fetchArticleContent(
        widget.item.contentId,
      );
      final relatedArticles = await _articleService.fetchRelatedArticles(
        widget.item.contentId,
        '1',
      );

      // Extract paragraphs from HTML content
      final paragraphs = _articleService.extractParagraphs(content);

      setState(() {
        _articleContent = content;
        _paragraphs = paragraphs;
        _relatedArticles = relatedArticles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading article: $e';
      });
    }
  }

  Future<void> _loadQuestionData() async {
    try {
      final questionData = await _articleService.fetchQuestionContent(
        widget.item.contentId,
      );
      final relatedArticles = await _articleService.fetchRelatedArticles(
        widget.item.contentId,
        '3',
      );

      // Extract images from HTML content
      final images = _articleService.extractImages(
        questionData['html_content'],
      );

      setState(() {
        _questionData = questionData;
        _images = images;
        _relatedArticles = relatedArticles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading question: $e';
      });
    }
  }

  Future<void> _loadRadioData() async {
    try {
      final radioData = await _articleService.fetchRadioContent(
        widget.item.contentId,
      );
      final relatedArticles = await _articleService.fetchRelatedArticles(
        widget.item.contentId,
        '8',
      );

      // Extract paragraphs from HTML content for description
      final paragraphs = _articleService.extractParagraphs(
        radioData['html_content'],
      );

      setState(() {
        _radioData = radioData;
        _paragraphs = paragraphs;
        _relatedArticles = relatedArticles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading radio: $e';
      });
    }
  }

  void _shareContent() {
    final String shareText =
        '${widget.item.title}\n'
        '${widget.item.author.userName != '' ? '作者: ${widget.item.author.userName}\n' : ''}'
        '${widget.item.forward}\n'
        '来自: ONE一个';

    Share.share(shareText);
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });

    // Here you would normally call an API to like/unlike the content
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isLiked ? '已点赞' : '已取消点赞'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _shareContent),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _buildContent(),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : Colors.grey,
                    ),
                    onPressed: _toggleLike,
                  ),
                  Text(
                    '${widget.item.likeCount}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_border, color: Colors.grey),
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('已加入收藏')));
                },
              ),
              IconButton(
                icon: const Icon(Icons.comment_outlined, color: Colors.grey),
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('评论功能暂未开放')));
                },
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.grey),
                onPressed: _shareContent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Daily illustration
    if (widget.item.category == '0') {
      return _buildDailyContent();
    }
    // Article
    else if (widget.item.category == '1') {
      return _buildArticleContent();
    }
    // Question
    else if (widget.item.category == '3') {
      return _buildQuestionContent();
    }
    // Radio
    else if (widget.item.category == '8') {
      return _buildRadioContent();
    }
    // Default
    else {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Content not available for this type',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
  }

  Widget _buildDailyContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              widget.item.imgUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                final isDarkMode =
                    Provider.of<ThemeProvider>(context).isDarkMode;

                return Container(
                  color: isDarkMode ? Colors.grey[900] : Colors.grey[300],
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
                  '插画 | ${widget.item.picInfo}',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  widget.item.forward,
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (widget.item.textAuthorInfo != null) ...[
                  Text(
                    '— ${widget.item.textAuthorInfo!.textAuthorName}',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.item.textAuthorInfo!.textAuthorWork,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.item.textAuthorInfo!.textAuthorDesc,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleContent() {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.item.imgUrl.isNotEmpty)
            Image.network(
              widget.item.imgUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: isDarkMode ? Colors.grey[900] : Colors.grey[300],
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
                  widget.item.title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '文 / ${widget.item.author.userName}',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),

                // Simplified article content - display paragraphs as Text widgets
                if (_paragraphs.isNotEmpty)
                  ..._paragraphs
                      .map(
                        (paragraph) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            paragraph,
                            style: TextStyle(fontSize: 16, height: 1.6),
                          ),
                        ),
                      )
                      .toList()
                else
                  Text(
                    widget.item.forward,
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),

                const SizedBox(height: 24),

                // Author info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          widget.item.author.webUrl,
                        ),
                        onBackgroundImageError: (e, s) => {},
                        backgroundColor:
                            isDarkMode ? Colors.grey[700] : Colors.grey[300],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.author.userName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              widget.item.author.summary,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('已关注作者')),
                          );
                        },
                        child: const Text('关注'),
                      ),
                    ],
                  ),
                ),

                // Related articles
                if (_relatedArticles.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Text(
                    '相关推荐',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._relatedArticles.map(
                    (article) => _buildRelatedArticleItem(article),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent() {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final authorData =
        _questionData.isNotEmpty ? _questionData['author'] : null;
    final authorName =
        authorData != null
            ? authorData['user_name']
            : widget.item.author.userName;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag if available
          if (widget.item.tagList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                '— ${widget.item.tagList.first.title} —',
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),

          // Question and answer
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.item.forward,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Divider with dot
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '•',
                        style: TextStyle(fontSize: 24, color: Colors.grey),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 16),

                // Answer
                Text(
                  '$authorName答：',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Display images from the question content
                if (_images.isNotEmpty)
                  ..._images
                      .map(
                        (imageSrc) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Image.network(
                            imageSrc,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color:
                                    isDarkMode
                                        ? Colors.grey[900]
                                        : Colors.grey[200],
                                child: Center(
                                  child: Text('Image not available'),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                      .toList(),

                const SizedBox(height: 24),

                // Author info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            authorData != null
                                ? NetworkImage(authorData['web_url'])
                                : NetworkImage(widget.item.author.webUrl),
                        onBackgroundImageError: (e, s) => {},
                        backgroundColor:
                            isDarkMode ? Colors.grey[700] : Colors.grey[300],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authorData != null
                                  ? authorData['user_name']
                                  : widget.item.author.userName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              authorData != null
                                  ? authorData['summary']
                                  : widget.item.author.summary,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('已关注作者')),
                          );
                        },
                        child: const Text('关注'),
                      ),
                    ],
                  ),
                ),

                // Related questions
                if (_relatedArticles.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Text(
                    '相关推荐',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._relatedArticles.map(
                    (article) =>
                        _buildRelatedArticleItem(article, isQuestion: true),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioContent() {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final audioUrl = _radioData.isNotEmpty ? _radioData['audio_url'] : '';
    final anchor = _radioData.isNotEmpty ? _radioData['anchor'] : '';
    final authorData = _radioData.isNotEmpty ? _radioData['author'] : null;

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image if available
          if (widget.item.imgUrl.isNotEmpty)
            Image.network(
              widget.item.imgUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: isDarkMode ? Colors.grey[900] : Colors.grey[300],
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
                  widget.item.title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'ONE收音机 | ${widget.item.volume}',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),

                // Audio player
                if (audioUrl.isNotEmpty)
                  AudioPlayerWidget(
                    audioService: AudioService(),
                    key: Key(audioUrl), // Ensure unique key for each instance
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('暂无音频', style: TextStyle(color: Colors.grey)),
                    ),
                  ),

                const SizedBox(height: 24),

                // Host info
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          authorData != null
                              ? NetworkImage(authorData['web_url'])
                              : NetworkImage(widget.item.author.webUrl),
                      onBackgroundImageError: (e, s) => {},
                      backgroundColor:
                          isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authorData != null
                              ? authorData['user_name']
                              : widget.item.author.userName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          authorData != null
                              ? authorData['summary']
                              : widget.item.author.summary,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Description
                if (_paragraphs.isNotEmpty)
                  ..._paragraphs
                      .map(
                        (paragraph) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            paragraph,
                            style: TextStyle(fontSize: 16, height: 1.6),
                          ),
                        ),
                      )
                      .toList()
                else
                  Text(
                    widget.item.forward,
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),

                // Related articles
                if (_relatedArticles.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Text(
                    '相关推荐',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._relatedArticles.map(
                    (article) =>
                        _buildRelatedArticleItem(article, isRadio: true),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedArticleItem(
    RelatedArticle article, {
    bool isQuestion = false,
    bool isRadio = false,
  }) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    String contentType = '阅读'; // Default to article
    if (isQuestion) contentType = '问答';
    if (isRadio) contentType = '电台';

    return InkWell(
      onTap: () {
        // Here we would navigate to the content detail page
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Opening: ${article.title}')));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              child: Center(
                child: Text(
                  contentType,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (article.authorList.isNotEmpty)
                    Text(
                      '文 / ${article.getAuthorsText()}',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
