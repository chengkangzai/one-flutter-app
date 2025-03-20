import 'dart:convert';
import 'package:flutter_application_1/models/related_article.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

class ArticleService {
  // Use HTTP as the API seems to only support HTTP
  final String baseUrl = 'http://v3.wufazhuce.com:8000/api';
  
  // Headers from your curl command
  final Map<String, String> headers = {
    'Host': 'v3.wufazhuce.com:8000',
    'Accept': '*/*',
    'User-Agent': 'ONE/5.3.5 (iPad; iOS 18.3; Scale/2.00)',
    'Accept-Language': 'en-US;q=1, ms-MY;q=0.9, zh-Hans-US;q=0.8',
    'Connection': 'keep-alive',
  };

  // Get request with error handling
  Future<http.Response> _safeGet(String endpoint) async {
    try {
      final url = '$baseUrl/$endpoint';
      final response = await http.get(Uri.parse(url), headers: headers);
      return response;
    } catch (e) {
      print('HTTP request failed: $e');
      throw Exception('Network error: $e');
    }
  }

  // Fetch article content by ID
  Future<String> fetchArticleContent(String contentId) async {
    final endpoint = 'essay/htmlcontent/$contentId';
    
    try {
      final response = await _safeGet(endpoint);
      
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        
        if (decodedData['res'] == 0 && decodedData['data'] != null) {
          final htmlContent = decodedData['data']['html_content'];
          return htmlContent;
        } else {
          throw Exception('Failed to parse article content');
        }
      } else {
        throw Exception('Failed to load article content: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching article content: $e');
      throw Exception('Network error: $e');
    }
  }

  // Fetch question content by ID
  Future<Map<String, dynamic>> fetchQuestionContent(String contentId) async {
    final endpoint = 'question/htmlcontent/$contentId';
    
    try {
      final response = await _safeGet(endpoint);
      
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        
        if (decodedData['res'] == 0 && decodedData['data'] != null) {
          return {
            'html_content': decodedData['data']['html_content'],
            'author': decodedData['data']['author_list'][0],
          };
        } else {
          throw Exception('Failed to parse question content');
        }
      } else {
        throw Exception('Failed to load question content: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching question content: $e');
      throw Exception('Network error: $e');
    }
  }

  // Fetch radio content by ID
  Future<Map<String, dynamic>> fetchRadioContent(String contentId) async {
    final endpoint = 'radio/htmlcontent/$contentId';
    
    try {
      final response = await _safeGet(endpoint);
      
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        
        if (decodedData['res'] == 0 && decodedData['data'] != null) {
          String audioUrl = decodedData['data']['audio'] ?? '';
          
          return {
            'audio_url': audioUrl,
            'anchor': decodedData['data']['anchor'] ?? '',
            'html_content': decodedData['data']['html_content'],
            'author': decodedData['data']['author_list'][0],
          };
        } else {
          throw Exception('Failed to parse radio content');
        }
      } else {
        throw Exception('Failed to load radio content: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching radio content: $e');
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

  // Extract images from HTML content
  List<String> extractImages(String htmlContent) {
    try {
      final document = html_parser.parse(htmlContent);
      final contentDiv = document.querySelector('.one-content-box');
      
      if (contentDiv != null) {
        final images = contentDiv.querySelectorAll('img');
        return images
            .map((element) => element.attributes['src'] ?? '')
            .where((src) => src.isNotEmpty)
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error extracting images: $e');
      return [];
    }
  }

  // Fetch related articles
  Future<List<RelatedArticle>> fetchRelatedArticles(String contentId, String contentType) async {
    String endpoint;
    
    switch(contentType) {
      case '1':
        endpoint = 'essay';
        break;
      case '3':
        endpoint = 'question';
        break;
      case '8':
        endpoint = 'radio';
        break;
      default:
        endpoint = 'essay';
    }
    
    final url = 'relatedforwebview/$endpoint/$contentId';
    
    try {
      final response = await _safeGet(url);
      
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        
        if (decodedData['res'] == 0 && decodedData['data'] != null) {
          final List<dynamic> relatedData = decodedData['data'];
          return relatedData.map((item) => RelatedArticle.fromJson(item)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load related articles: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching related articles: $e');
      return [];
    }
  }
}