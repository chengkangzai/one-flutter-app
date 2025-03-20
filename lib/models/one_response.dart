import 'package:flutter_application_1/models/data.dart';

class OneResponse {
  final int res;
  final Data data;

  OneResponse({required this.res, required this.data});

  factory OneResponse.fromJson(Map<String, dynamic> json) {
    return OneResponse(
      res: json['res'] ?? 0,
      data: Data.fromJson(json['data'] ?? {}),
    );
  }
}