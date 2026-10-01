import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'api_exceptions.dart';

/// Central HTTP Client responsible for making network requests and error handling.
/// Web-safe: avoids dart:io imports that crash on Flutter Web.
class ApiClient {
  final http.Client _client;
  final String _baseUrl;

  ApiClient({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConstants.baseUrl;

  /// Performs a GET request and returns decoded JSON (Map or List)
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);

    try {
      final response = await _client
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              ...?headers,
            },
          )
          .timeout(ApiConstants.connectTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiTimeoutException();
    } on FormatException {
      throw const SerializationException('Failed to process server response.');
    } on AppException {
      rethrow;
    } catch (e) {
      // On web, SocketException doesn't exist — we catch generic exceptions as network errors
      final msg = e.toString().toLowerCase();
      if (!kIsWeb &&
          (msg.contains('socketexception') ||
              msg.contains('connection refused') ||
              msg.contains('network is unreachable'))) {
        throw const NetworkException();
      }
      // On web: XMLHttpRequest errors manifest as ClientException
      if (msg.contains('xmlhttprequest') ||
          msg.contains('failed to fetch') ||
          msg.contains('clientexception') ||
          msg.contains('os error') ||
          msg.contains('connection')) {
        throw const NetworkException();
      }
      throw UnexpectedApiException(e.toString());
    }
  }

  /// Performs a POST request and returns decoded JSON
  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(endpoint, null);

    try {
      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              ...?headers,
            },
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.connectTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiTimeoutException();
    } on FormatException {
      throw const SerializationException('Failed to process server response.');
    } on AppException {
      rethrow;
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('socketexception') ||
          msg.contains('xmlhttprequest') ||
          msg.contains('failed to fetch') ||
          msg.contains('clientexception') ||
          msg.contains('connection')) {
        throw const NetworkException();
      }
      throw UnexpectedApiException(e.toString());
    }
  }

  /// Builds the complete URI with query parameters
  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParameters) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final urlString = '$_baseUrl$cleanEndpoint';

    final uri = Uri.parse(urlString);
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    // Convert all query parameter values to string
    final stringParams = queryParameters.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...stringParams,
    });
  }

  /// Evaluates HTTP response status code and extracts JSON body
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    dynamic decodedBody;
    if (response.body.isNotEmpty) {
      try {
        decodedBody = jsonDecode(response.body);
      } catch (_) {
        decodedBody = null;
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      return decodedBody;
    } else if (statusCode == 400) {
      final message = _extractErrorMessage(decodedBody) ?? 'Bad Request (400)';
      throw BadRequestException(message, statusCode);
    } else if (statusCode == 404) {
      final message =
          _extractErrorMessage(decodedBody) ?? 'Resource Not Found (404)';
      throw NotFoundException(message, statusCode);
    } else if (statusCode >= 500) {
      final message = _extractErrorMessage(decodedBody) ??
          'Internal Server Error ($statusCode)';
      throw ServerException(message, statusCode);
    } else {
      final message =
          _extractErrorMessage(decodedBody) ?? 'HTTP Error $statusCode';
      throw UnexpectedApiException(message, statusCode);
    }
  }

  String? _extractErrorMessage(dynamic body) {
    if (body is Map<String, dynamic> && body.containsKey('message')) {
      return body['message']?.toString();
    }
    return null;
  }

  /// Disposes underlying HTTP client if needed
  void dispose() {
    _client.close();
  }
}
