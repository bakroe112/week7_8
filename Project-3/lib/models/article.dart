class Article {
  final String title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? sourceName;
  final DateTime? publishedAt;
  final String? content;

  Article({
    required this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.sourceName,
    this.publishedAt,
    this.content,
  });

  // dùng cho NewsAPI / GNews (giữ lại, lỡ sau đổi backend)
  factory Article.fromJson(Map<String, dynamic> json) {
    final source = json['source'];
    return Article(
      title: json['title'] ?? 'No title',
      description: json['description'],
      url: json['url'],
      urlToImage: json['urlToImage'] ?? json['image'],
      sourceName: source is Map ? source['name'] : null,
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'])
          : null,
      content: json['content'],
    );
  }

  // dùng cho Spaceflight News
  factory Article.fromSpaceflightJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No title',
      description: json['summary'],
      url: json['url'],
      urlToImage: json['image_url'],
      sourceName: json['news_site'],
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'])
          : null,
      content: json['summary'],
    );
  }
}
