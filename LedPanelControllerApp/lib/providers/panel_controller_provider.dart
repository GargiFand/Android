import 'package:flutter/material.dart';

import '../services/panel_api_client.dart';

class PanelControllerProvider extends ChangeNotifier {
  PanelControllerProvider();

  String _baseUrl = '';
  String _apiKey = '';
  bool _connected = false;
  bool _busy = false;
  String? _error;
  PanelApiClient? _client;

  String get baseUrl => _baseUrl;
  String get apiKey => _apiKey;
  bool get isConnected => _connected;
  bool get isBusy => _busy;
  String? get error => _error;

  set baseUrl(String value) {
    _baseUrl = value;
    notifyListeners();
  }

  set apiKey(String value) {
    _apiKey = value;
    notifyListeners();
  }

  Future<void> connect() async {
    if (_baseUrl.isEmpty) {
      _error = 'Please enter the device URL.';
      notifyListeners();
      return;
    }

    _setBusy(true);

    try {
      _client = PanelApiClient(baseUrl: _baseUrl, apiKey: _apiKey.isEmpty ? null : _apiKey);
      await _client!.ping();
      _connected = true;
      _error = null;
    } on PanelApiException catch (e) {
      _error = e.message;
      _connected = false;
    } catch (e) {
      _error = 'Failed to connect: $e';
      _connected = false;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> sendMessage(String message, {String? animation}) async {
    if (_client == null) {
      _error = 'Connect to the panel first.';
      notifyListeners();
      return;
    }

    _setBusy(true);

    try {
      await _client!.sendMessage(message: message, animation: animation);
      _error = null;
    } on PanelApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to send message: $e';
    } finally {
      _setBusy(false);
    }
  }

  void disconnect() {
    _client = null;
    _connected = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }
}
