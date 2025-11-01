import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chính'),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_user, size: 72),
            const SizedBox(height: 16),
            Text(
              'Xin chào, ${user?.email ?? 'người dùng'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text('UID: ${user?.uid ?? 'không có'}'),
          ],
        ),
      ),
    );
  }
}
