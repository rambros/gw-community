import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class GetUnplashRandomCall {
  static Future<ApiCallResponse> call({
    String? clientId = 'ab7yomARXpPr3qaa71snIOzZFFgK6k0wDODIdDvkTPA',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getUnplashRandom',
      apiUrl: 'https://api.unsplash.com/photos/random',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'client_id': clientId,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetListPhotosCall {
  static Future<ApiCallResponse> call({
    String? perPage = '10',
    String? query = 'meditation',
    String? clientId = 'ab7yomARXpPr3qaa71snIOzZFFgK6k0wDODIdDvkTPA',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getListPhotos',
      apiUrl: 'https://api.unsplash.com/search/photos',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'per_page': perPage,
        'query': query,
        'client_id': clientId,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}
