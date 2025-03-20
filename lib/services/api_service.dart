// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import '../models/one_response.dart';

class ApiService {
  final String baseUrl = 'http://v3.wufazhuce.com:8000/api';
  
  // Headers from your curl command
  final Map<String, String> headers = {
    'Host': 'v3.wufazhuce.com:8000',
    'Accept': '*/*',
    'User-Agent': 'ONE/5.3.5 (iPad; iOS 18.3; Scale/2.00)',
    'Accept-Language': 'en-US;q=1, ms-MY;q=0.9, zh-Hans-US;q=0.8',
    'Connection': 'keep-alive',
  };

  Future<OneResponse> fetchOneData({String location = 'Petaling Jaya'}) async {
    final encodedLocation = Uri.encodeComponent(location);
    final url = '$baseUrl/channel/one/0/$encodedLocation';
    
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      
      if (response.statusCode == 200) {
        try {
          final decodedData = json.decode(response.body);
          return OneResponse.fromJson(decodedData);
        } catch (e) {
          print('JSON parsing error: $e');
          print('Response body: ${response.body.substring(0, min(500, response.body.length))}');
          throw Exception('Failed to parse response data: $e');
        }
      } else {
        print('HTTP error: ${response.statusCode}');
        print('Response body: ${response.body.substring(0, min(500, response.body.length))}');
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('HTTP error occurred');
    } on FormatException {
      throw Exception('Invalid response format');
    } catch (e) {
      print('Network error: $e');
      throw Exception('Network error: $e');
    }
  }
}

// Helper function to get min of two values
int min(int a, int b) => a < b ? a : b;