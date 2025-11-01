import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/news_api_service.dart';
import '../widgets/article_card.dart';
import 'news_detail_screen.dart';

class NewsListScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const NewsListScreen({super.key, required this.onToggleTheme});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  late Future<List<Article>> _futureArticles;
  final NewsApiService _newsApiService = NewsApiService();

  @override
  void initState() {
    super.initState();
    _futureArticles = _newsApiService.fetchTopHeadlines();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureArticles = _newsApiService.fetchTopHeadlines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Headlines'),
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: const Icon(Icons.dark_mode),
            tooltip: 'Toggle theme',
          ),
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Article>>(
        future: _futureArticles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading indicator
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            // Error UI
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      'Không tải được tin tức.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Thử lại'),
                    )
                  ],
                ),
              ),
            );
          }

          final articles = snapshot.data ?? [];

          if (articles.isEmpty) {
            return const Center(
              child: Text('Không có bài báo nào.'),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: articles.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (context, index) {
                final article = articles[index];
                return ArticleCard(
                  article: article,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => NewsDetailScreen(article: article),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
