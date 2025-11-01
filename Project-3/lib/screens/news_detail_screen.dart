import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/article.dart';

class NewsDetailScreen extends StatelessWidget {
  final Article article;
  const NewsDetailScreen({super.key, required this.article});

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.sourceName ?? 'Chi tiết'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (article.urlToImage != null)
              Image.network(
                article.urlToImage!,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(
                  height: 220,
                  child: Center(child: Icon(Icons.broken_image)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (article.sourceName != null)
                        Text(
                          article.sourceName!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      const SizedBox(width: 12),
                      if (article.publishedAt != null)
                        Text(
                          _formatDate(article.publishedAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (article.description != null)
                    Text(
                      article.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 16),
                  if (article.content != null)
                    Text(
                      article.content!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 16),
                  if (article.url != null)
                    FilledButton.icon(
                      onPressed: () {
                        // Ở đây có thể mở WebView hoặc url_launcher
                        // Để đơn giản, hiện tạm dialog
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Mở bài báo gốc'),
                            content: Text(
                                'Bạn có thể dùng url_launcher để mở:\n${article.url}'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Đóng'),
                              )
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Đọc trên web'),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
