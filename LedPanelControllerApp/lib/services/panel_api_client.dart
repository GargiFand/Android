import 'dart:convert';

import 'package:http/http.dart' as http;

/// Lightweight client for talking to the ESP32 signage controller.
class PanelApiClient {
  PanelApiClient({required this.baseUrl, this.apiKey});

  final String baseUrl;
  final String? apiKey;

  Uri _buildUri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (apiKey != null && apiKey!.isNotEmpty) 'X-API-Key': apiKey!,
      };

  Future<void> sendMessage({required String message, String? animation}) async {
    final response = await http.post(
      _buildUri('/message'),
      headers: _headers,
      body: jsonEncode({
        'text': message,
        if (animation != null && animation.isNotEmpty) 'animation': animation,
      }),
    );

    if (response.statusCode >= 400) {
      throw PanelApiException(
        'Failed to send message: \\${response.statusCode}',
        details: response.body,
      );
    }
  }

  Future<void> ping() async {
    final response = await http.get(
      _buildUri('/health'),
      headers: _headers,
    );

    if (response.statusCode >= 400) {
      throw PanelApiException('Device health check failed');
    }
  }
}

class PanelApiException implements Exception {
  PanelApiException(this.message, {this.details});

  final String message;
  final String? details;

  @override
  String toString() => 'PanelApiException(message: $message, details: $details)';
}
