import '/data/services/api/api_calls.dart';

class UnsplashRepository {
  Future<ApiCallResponse> getRandomImage() async {
    return await GetUnplashRandomCall.call();
  }
}
