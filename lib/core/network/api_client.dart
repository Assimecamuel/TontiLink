import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Client HTTP pour la communication entre Flutter et l'API Django REST.
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  static ApiClient get instance => _instance;

  ApiClient._internal();

  // String _baseUrl = 'http://172.29.66.1:8000';
  // String _baseUrl = 'http://192.168.1.117:8000';
  String _baseUrl = 'http://10.103.60.1:8000';


  String? _token;

  String get baseUrl => _baseUrl;
  String? get token => _token;
  bool get hasToken => _token != null && _token!.isNotEmpty;

  void setBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  void setToken(String? token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final parsedEndpoint =
        Uri.parse(endpoint.startsWith('/') ? endpoint : '/$endpoint');
    final path = parsedEndpoint.path.endsWith('/')
        ? parsedEndpoint.path
        : '${parsedEndpoint.path}/';
    final uri = Uri.parse('$_baseUrl$path');
    final allQueryParams = <String, String>{
      ...parsedEndpoint.queryParameters,
      ...?queryParams,
    };
    return allQueryParams.isEmpty
        ? uri
        : uri.replace(queryParameters: allQueryParams);
  }

  Future<ApiResponse> get(String endpoint,
          {Map<String, String>? queryParams}) =>
      _send('GET', endpoint, queryParams: queryParams);

  Future<ApiResponse> post(String endpoint, [Map<String, dynamic>? body]) =>
      _send('POST', endpoint, body: body);

  Future<ApiResponse> put(String endpoint, [Map<String, dynamic>? body]) =>
      _send('PUT', endpoint, body: body);

  Future<ApiResponse> delete(String endpoint) => _send('DELETE', endpoint);

  Future<ApiResponse> _send(
    String method,
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(endpoint, queryParams);
    final client = http.Client();

    try {
      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
      };
      if (hasToken) {
        headers['Authorization'] = 'Bearer $_token';
      }

      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) {
        request.body = jsonEncode(body);
      }
      final streamedResponse =
          await client.send(request).timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse)
          .timeout(const Duration(seconds: 15));
      final responseBody = utf8.decode(response.bodyBytes);

      dynamic parsedJson;
      try {
        parsedJson = jsonDecode(responseBody);
      } on FormatException {
        parsedJson = responseBody;
      }

      final httpSuccess =
          response.statusCode >= 200 && response.statusCode < 300;
      if (parsedJson is Map<String, dynamic>) {
        return ApiResponse(
          statusCode: response.statusCode,
          success: parsedJson['success'] is bool
              ? parsedJson['success'] as bool
              : httpSuccess,
          data:
              parsedJson.containsKey('data') ? parsedJson['data'] : parsedJson,
          message: parsedJson['message']?.toString() ??
              parsedJson['detail']?.toString() ??
              parsedJson['error']?.toString(),
          errorCode: parsedJson['code']?.toString(),
          rawBody: responseBody,
        );
      }
      return ApiResponse(
        statusCode: response.statusCode,
        success: httpSuccess,
        data: parsedJson,
        rawBody: responseBody,
      );
    } on http.ClientException catch (e) {
      return ApiResponse(
        statusCode: 0,
        success: false,
        isNetworkError: true,
        message:
            'Serveur Django injoignable (${e.message}). Vérifiez le réseau et le backend.',
      );
    } on TimeoutException {
      return const ApiResponse(
        statusCode: 408,
        success: false,
        isNetworkError: true,
        message:
            'Délai d\'attente dépassé lors de la communication avec le serveur.',
      );
    } catch (e) {
      return ApiResponse(
        statusCode: 500,
        success: false,
        isNetworkError: true,
        message: 'Erreur de communication : $e',
      );
    } finally {
      client.close();
    }
  }
}

/// Modèle uniforme pour la réponse API.
class ApiResponse {
  final int statusCode;
  final bool success;
  final dynamic data;
  final String? message;
  final String? rawBody;
  final bool isNetworkError;

  /// Code d'erreur métier renvoyé par le backend (ex. `UNAUTHORIZED`).
  final String? errorCode;

  const ApiResponse({
    required this.statusCode,
    required this.success,
    this.data,
    this.message,
    this.rawBody,
    this.isNetworkError = false,
    this.errorCode,
  });

  /// Permission RBAC refusée (HTTP 403 / code UNAUTHORIZED).
  bool get isPermissionDenied =>
      statusCode == 403 || errorCode == 'UNAUTHORIZED';

  bool get isOk => success && statusCode >= 200 && statusCode < 300;
}
