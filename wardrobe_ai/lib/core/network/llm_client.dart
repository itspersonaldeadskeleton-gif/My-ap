import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum LlmErrorKind { noKey, offline, api }

class LlmException implements Exception {
  const LlmException(this.kind, this.message);
  final LlmErrorKind kind;
  final String message;
  @override
  String toString() => message;
}

/// Thin wrapper over a vision LLM (Claude or Gemini, chosen via LLM_PROVIDER).
/// SECURITY: keys come from .env for development only. In production, call
/// your own backend and keep provider keys server-side.
class LlmClient {
  LlmClient(this._dio);
  final Dio _dio;

  String get _provider =>
      (dotenv.maybeGet('LLM_PROVIDER') ?? 'claude').toLowerCase();

  /// Sends one image + prompt and returns the model's raw text reply.
  Future<String> askWithImage({
    required Uint8List bytes,
    required String mime,
    required String prompt,
  }) async {
    try {
      return _provider == 'gemini'
          ? await _gemini(bytes, mime, prompt)
          : await _claude(bytes, mime, prompt);
    } on DioException catch (e) {
      const offline = {
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      };
      if (offline.contains(e.type)) {
        throw const LlmException(LlmErrorKind.offline,
            'You appear to be offline. Check your connection and retry.');
      }
      throw LlmException(LlmErrorKind.api,
          'The AI service returned an error (${e.response?.statusCode ?? 'unknown'}).');
    }
  }

  /// Text-only call (used for outfit generation). Returns the raw reply.
  Future<String> askText({required String prompt}) async {
    try {
      if (_provider == 'gemini') {
        final model = dotenv.maybeGet('GEMINI_MODEL') ?? 'gemini-2.0-flash';
        final res = await _dio.post(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
          queryParameters: {'key': _key('GEMINI_API_KEY')},
          data: {
            'contents': [
              {'parts': [{'text': prompt}]}
            ],
            'generationConfig': {'responseMimeType': 'application/json'},
          },
        );
        return res.data['candidates'][0]['content']['parts'][0]['text'] as String;
      }
      final res = await _dio.post(
        'https://api.anthropic.com/v1/messages',
        options: Options(headers: {
          'x-api-key': _key('ANTHROPIC_API_KEY'),
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        }),
        data: {
          'model': dotenv.maybeGet('CLAUDE_MODEL') ?? 'claude-sonnet-4-6',
          'max_tokens': 3000,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        },
      );
      return res.data['content'][0]['text'] as String;
    } on DioException catch (e) {
      const offline = {
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      };
      if (offline.contains(e.type)) {
        throw const LlmException(LlmErrorKind.offline,
            'You appear to be offline. Check your connection and retry.');
      }
      throw LlmException(LlmErrorKind.api,
          'The AI service returned an error (${e.response?.statusCode ?? 'unknown'}).');
    }
  }

  String _key(String name) {
    final k = dotenv.maybeGet(name);
    if (k == null || k.isEmpty) {
      throw LlmException(LlmErrorKind.noKey, 'Missing $name in your .env file.');
    }
    return k;
  }

  Future<String> _claude(Uint8List bytes, String mime, String prompt) async {
    final res = await _dio.post(
      'https://api.anthropic.com/v1/messages',
      options: Options(headers: {
        'x-api-key': _key('ANTHROPIC_API_KEY'),
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      }),
      data: {
        'model': dotenv.maybeGet('CLAUDE_MODEL') ?? 'claude-sonnet-4-6',
        'max_tokens': 600,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image',
                'source': {
                  'type': 'base64',
                  'media_type': mime,
                  'data': base64Encode(bytes),
                },
              },
              {'type': 'text', 'text': prompt},
            ],
          }
        ],
      },
    );
    return res.data['content'][0]['text'] as String;
  }

  Future<String> _gemini(Uint8List bytes, String mime, String prompt) async {
    final model = dotenv.maybeGet('GEMINI_MODEL') ?? 'gemini-2.0-flash';
    final res = await _dio.post(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
      queryParameters: {'key': _key('GEMINI_API_KEY')},
      data: {
        'contents': [
          {
            'parts': [
              {'inline_data': {'mime_type': mime, 'data': base64Encode(bytes)}},
              {'text': prompt},
            ]
          }
        ],
        'generationConfig': {'responseMimeType': 'application/json'},
      },
    );
    return res.data['candidates'][0]['content']['parts'][0]['text'] as String;
  }
}
