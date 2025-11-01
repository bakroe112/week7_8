import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Gallery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const GalleryPage(),
    );
  }
}

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _images = [];

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> _requestStoragePermission() async {
    // Android 13 trở lên sẽ map qua READ_MEDIA_IMAGES
    final status = await Permission.photos.request();
    if (status.isGranted) return true;

    // fallback để máy thấp hơn vẫn xin được
    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  Future<void> _pickFromCamera() async {
    final granted = await _requestCameraPermission();
    if (!granted) {
      _showSnackBar('Không có quyền dùng camera.');
      return;
    }

    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _images.add(File(photo.path));
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final granted = await _requestStoragePermission();
    if (!granted) {
      _showSnackBar('Không có quyền truy cập thư viện.');
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  void _showAddPhotoOptions() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp bằng camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _openImageFull(File file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullImageScreen(imageFile: file),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _images.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gallery'),
        centerTitle: true,
      ),
      body: isEmpty
          ? const Center(
              child: Text(
                'Chưa có ảnh nào.\nNhấn nút + để thêm.',
                textAlign: TextAlign.center,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: _images.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemBuilder: (context, index) {
                  final file = _images[index];
                  return GestureDetector(
                    onTap: () => _openImageFull(file),
                    onLongPress: () {
                      // xóa nhanh
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Xóa ảnh'),
                          content: const Text('Bạn có chắc muốn xóa ảnh này?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _images.removeAt(index);
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Xóa'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        file,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPhotoOptions,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}

class FullImageScreen extends StatelessWidget {
  final File imageFile;
  const FullImageScreen({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xem ảnh'),
      ),
      body: Center(
        child: Image.file(imageFile),
      ),
    );
  }
}
