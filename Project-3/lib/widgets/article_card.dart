import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/article.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback? onTap;

  const ArticleCard({super.key, required this.article, this.onTap});

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: article.urlToImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                article.urlToImage!,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported),
              ),
            )
          : const Icon(Icons.article_outlined, size: 40),
      title: Text(
        article.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.sourceName != null) Text(article.sourceName!),
          if (article.publishedAt != null)
            Text(
              _formatDate(article.publishedAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
