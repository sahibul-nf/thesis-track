import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
  static String get apiVersion => dotenv.env['API_VERSION'] ?? 'v1';

  static String get fullApiUrl => '$apiBaseUrl/api/$apiVersion';

  // API Endpoints
  static final endpoints = _ApiEndpoints();
}

class _ApiEndpoints {
  final auth = _AuthEndpoints();
  final thesis = _ThesisEndpoints();
  final profile = _ProfileEndpoints();
  final document = _DocumentEndpoints();
  final progress = _ProgressEndpoints();
}

class _AuthEndpoints {
  final String login = '/auth/login';
  final String register = '/auth/register';
  final String logout = '/auth/logout';
}

class _ThesisEndpoints {
  final String list = '/theses';
  final String create = '/theses';
  final String update = '/theses';
  final String delete = '/theses';
}

class _ProfileEndpoints {
  final String get = '/profile';
  final String update = '/profile';
}

class _ProgressEndpoints {
  final String list = '/progress';
  String get(String id) => '/progress/$id';
  final String create = '/progress';
  String update(String id) => '/progress/$id';
}

class _DocumentEndpoints {
  String uploadDraft(String thesisId) => '/documents/thesis/$thesisId/draft';
  String uploadFinal(String thesisId) => '/documents/thesis/$thesisId/final';
  String uploadProgress(String progressId) => '/documents/progress/$progressId';
}