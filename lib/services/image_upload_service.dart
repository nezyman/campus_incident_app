import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ImageUploadException implements Exception {
  const ImageUploadException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ImageUploadService {
  ImageUploadService({
    required this.cloudName,
    required this.uploadPreset,
    this.folder,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String cloudName;
  final String uploadPreset;
  final String? folder;
  final http.Client _client;

  bool get isConfigured =>
      cloudName.isNotEmpty &&
      !cloudName.startsWith('YOUR_') &&
      uploadPreset.isNotEmpty &&
      !uploadPreset.startsWith('YOUR_');

  Future<String> upload(File file) async {
    if (!isConfigured) {
      throw const ImageUploadException('Image hosting is not configured.');
    }

    final uri =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));
    if (folder != null && folder!.isNotEmpty) {
      request.fields['folder'] = folder!;
    }

    try {
      final streamed =
          await _client.send(request).timeout(const Duration(seconds: 40));
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode != 200) {
        throw ImageUploadException(
            'Upload failed (${response.statusCode}). Please try again.');
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final url = body['secure_url'] as String?;
      if (url == null || url.isEmpty) {
        throw const ImageUploadException('Upload returned no image URL.');
      }
      return url;
    } on TimeoutException {
      throw const ImageUploadException('Upload timed out.');
    } on SocketException {
      throw const ImageUploadException('No internet connection.');
    }
  }
}
