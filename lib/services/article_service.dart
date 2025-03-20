import 'dart:convert';
import 'package:flutter_application_1/models/related_article.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

class ArticleService {
  final String baseUrl = 'http://v3.wufazhuce.com:8000/api';

  // Headers from your curl command
  final Map<String, String> headers = {
    'Host': 'v3.wufazhuce.com:8000',
    'Accept': '*/*',
    'User-Agent': 'ONE/5.3.5 (iPad; iOS 18.3; Scale/2.00)',
    'Accept-Language': 'en-US;q=1, ms-MY;q=0.9, zh-Hans-US;q=0.8',
    'Connection': 'keep-alive',
  };

  // Fetch article content by ID
  Future<String> fetchArticleContent(String contentId) async {
    final url = '$baseUrl/essay/htmlcontent/$contentId';

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        if (decodedData['res'] == 0 && decodedData['data'] != null) {
          final htmlContent = decodedData['data']['html_content'];
          return htmlContent;
        } else {
          throw Exception('Failed to parse article content');
        }
      } else {
        throw Exception(
          'Failed to load article content: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching article content: $e');
      throw Exception('Network error: $e');
    }
  }

  // Extract plain text paragraphs from HTML content
  List<String> extractParagraphs(String htmlContent) {
    try {
      final document = html_parser.parse(htmlContent);
      final contentDiv = document.querySelector('.one-content-box');

      if (contentDiv != null) {
        final paragraphs = contentDiv.querySelectorAll('p');
        return paragraphs.map((element) => element.text).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error extracting paragraphs: $e');
      return [];
    }
  }

  // Fetch related articles
  Future<List<RelatedArticle>> fetchRelatedArticles(String contentId) async {
    final url = '$baseUrl/relatedforwebview/essay/$contentId';

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        if (decodedData['res'] == 0 && decodedData['data'] != null) {
          final List<dynamic> relatedData = decodedData['data'];
          return relatedData
              .map((item) => RelatedArticle.fromJson(item))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception(
          'Failed to load related articles: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching related articles: $e');
      return [];
    }
  }
}
