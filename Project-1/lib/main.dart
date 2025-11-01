import 'package:flutter/material.dart';

void main() {
  runApp(const ProfileApp());
}

class ProfileApp extends StatefulWidget {
  const ProfileApp({super.key});

  @override
  State<ProfileApp> createState() => _ProfileAppState();
}

class _ProfileAppState extends State<ProfileApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme(bool dark) {
    setState(() {
      _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Profile',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        brightness: Brightness.light,
        cardTheme: const CardTheme(margin: EdgeInsets.all(12)),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
        cardTheme: const CardTheme(margin: EdgeInsets.all(12)),
      ),
      home: HomeScreen(
        isDark: _themeMode == ThemeMode.dark,
        onThemeChanged: _toggleTheme,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
  });

  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Profile'),
        actions: [
          Row(
            children: [
              const Icon(Icons.light_mode, size: 18),
              Switch(
                value: isDark,
                onChanged: onThemeChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const Icon(Icons.dark_mode, size: 18),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final narrow = constraints.maxWidth < 720;
                  final leftColumn = [
                    const HeaderSection(),
                    const AboutSection(),
                    const ContactSection(),
                  ];
                  final rightColumn = [
                    const SkillsSection(),
                    const SocialSection(),
                    const HighlightsSection(),
                  ];

                  if (narrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ...leftColumn,
                        ...rightColumn,
                        const SizedBox(height: 24),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: leftColumn,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: rightColumn,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 56,
              backgroundImage: NetworkImage(
                'https://cdn.britannica.com/70/234870-050-D4D024BB/Orange-colored-cat-yawns-displaying-teeth.jpg',
              ),
            ),
            const SizedBox(height: 16),
            Text('Lê Demo', style: textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Mobile Developer • Flutter',
              style: textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: const [
                InfoChip(icon: Icons.location_on, label: 'Đà Nẵng, VN'),
                InfoChip(icon: Icons.school, label: 'VKU'),
                InfoChip(icon: Icons.language, label: 'vi • en'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  const InfoChip({super.key, required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: const [
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Giới thiệu'),
            subtitle: Text(
              'Sinh viên Khoa học Máy tính, mê mobile và UI/UX. '
              'Thích build app gọn gàng, hiệu năng ổn, code dễ bảo trì.',
            ),
          ),
        ],
      ),
    );
  }
}

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final skills = [
      'Flutter',
      'Dart',
      'REST API',
      'Firebase',
      'Hive',
      'Provider',
      'Git',
      'Clean UI',
      'Responsive',
    ];
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ListTile(
            leading: Icon(Icons.bolt_outlined),
            title: Text('Kỹ năng'),
            subtitle: Text('Một vài tech mình dùng hàng ngày'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((s) => SkillChip(text: s)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class SkillChip extends StatelessWidget {
  const SkillChip({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.primary.withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class SocialSection extends StatelessWidget {
  const SocialSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: const [
          ListTile(
            leading: Icon(Icons.link_outlined),
            title: Text('Liên kết'),
            subtitle: Text('Các kênh mình hoạt động'),
          ),
          Divider(height: 0),
          ListTile(
            leading: Icon(Icons.public),
            title: Text('Website'),
            subtitle: Text('https://bakroe.site'),
            trailing: Icon(Icons.open_in_new),
          ),
          ListTile(
            leading: Icon(Icons.code),
            title: Text('GitHub'),
            subtitle: Text('github.com/your-id'),
            trailing: Icon(Icons.open_in_new),
          ),
          ListTile(
            leading: Icon(Icons.business_center),
            title: Text('LinkedIn'),
            subtitle: Text('linkedin.com/in/your-id'),
            trailing: Icon(Icons.open_in_new),
          ),
        ],
      ),
    );
  }
}

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: const [
          ListTile(
            leading: Icon(Icons.mail_outline),
            title: Text('Email'),
            subtitle: Text('you@example.com'),
            trailing: Icon(Icons.copy),
          ),
          ListTile(
            leading: Icon(Icons.phone_outlined),
            title: Text('Số điện thoại'),
            subtitle: Text('+84 912 345 678'),
            trailing: Icon(Icons.copy),
          ),
          ListTile(
            leading: Icon(Icons.place_outlined),
            title: Text('Địa điểm'),
            subtitle: Text('Đà Nẵng, Việt Nam'),
          ),
        ],
      ),
    );
  }
}

class HighlightsSection extends StatelessWidget {
  const HighlightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: const [
          ListTile(
            leading: Icon(Icons.star_border),
            title: Text('Highlights'),
            subtitle: Text('Một vài điểm nổi bật gần đây'),
          ),
          Divider(height: 0),
          ListTile(
            leading: Icon(Icons.check_circle_outline),
            title: Text('Portfolio App'),
            subtitle: Text('Flutter • Material 3 • Responsive'),
          ),
          ListTile(
            leading: Icon(Icons.check_circle_outline),
            title: Text('UI Components'),
            subtitle: Text('Card, ListTile, CircleAvatar, Column'),
          ),
        ],
      ),
    );
  }
}
