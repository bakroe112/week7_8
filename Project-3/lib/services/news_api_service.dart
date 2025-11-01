import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class NewsApiService {
  // limit=30 để giống yêu cầu ban đầu
  static const String _baseUrl =
      'https://api.spaceflightnewsapi.net/v4/articles/?limit=30';

  Future<List<Article>> fetchTopHeadlines() async {
    final url = Uri.parse(_baseUrl);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      // cấu trúc:
      // {
      //   "count": ...,
      //   "next": ...,
      //   "previous": ...,
      //   "results": [ ... ]
      // }
      final List articlesJson = body['results'] ?? [];

      return articlesJson.map((e) => Article.fromSpaceflightJson(e)).toList();
    } else {
      throw Exception(
          'Lỗi API: ${response.statusCode} ${response.reasonPhrase}');
    }
  }
}
