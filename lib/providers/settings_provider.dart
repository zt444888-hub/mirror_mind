import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Settings provider with secure API Key storage.
class SettingsProvider extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  String _baseUrl = 'https://api.openai.com/v1';
  String _apiKey = '';
  String _model = 'gpt-4o-mini';
  bool _isDarkMode = false;
  bool _initialized = false;

  String get baseUrl => _baseUrl;
  String get apiKey => _apiKey;
  String get model => _model;
  bool get isDarkMode => _isDarkMode;
  bool get isApiConfigured => _apiKey.isNotEmpty;

  /// Load persisted config. Call once on app start.
  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    
    _baseUrl = prefs.getString('settings_base_url') ?? 'https://api.openai.com/v1';
    _model = prefs.getString('settings_model') ?? 'gpt-4o-mini';
    _isDarkMode = prefs.getBool('settings_dark_mode') ?? false;
    
    // Load API Key from secure storage
    _apiKey = await _secureStorage.read(key: 'settings_api_key') ?? '';
    
    // Migrate from SharedPreferences if key exists there (backward compatibility)
    if (_apiKey.isEmpty) {
      final legacyKey = prefs.getString('settings_api_key');
      if (legacyKey != null && legacyKey.isNotEmpty) {
        await _secureStorage.write(key: 'settings_api_key', value: legacyKey);
        await prefs.remove('settings_api_key'); // Remove from plaintext storage
        _apiKey = legacyKey;
      }
    }
    
    _initialized = true;
    notifyListeners();
  }

  Future<void> setBaseUrl(String url) async {
    _baseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings_base_url', url);
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key;
    // Store API Key in secure storage (AES encrypted)
    if (key.isNotEmpty) {
      await _secureStorage.write(key: 'settings_api_key', value: key);
    } else {
      await _secureStorage.delete(key: 'settings_api_key');
    }
    // Clean up any legacy plaintext storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('settings_api_key');
    notifyListeners();
  }

  Future<void> setModel(String model) async {
    _model = model;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings_model', model);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_dark_mode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_dark_mode', value);
    notifyListeners();
  }
}
