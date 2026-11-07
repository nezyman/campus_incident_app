import 'dart:convert';
import 'dart:io';

import 'package:campus_incident_app/services/image_upload_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late File photo;

  setUp(() {
    photo = File('${Directory.systemTemp.path}/incident_test_photo.jpg')
      ..writeAsBytesSync([1, 2, 3, 4]);
  });

  tearDown(() {
    if (photo.existsSync()) photo.deleteSync();
  });

  test('isConfigured is false for placeholder values', () {
    final s = ImageUploadService(
        cloudName: 'YOUR_CLOUD_NAME', uploadPreset: 'YOUR_UNSIGNED_PRESET');
    expect(s.isConfigured, isFalse);
  });

  test('isConfigured is true for real values', () {
    final s = ImageUploadService(cloudName: 'demo', uploadPreset: 'preset');
    expect(s.isConfigured, isTrue);
  });

  test('upload throws when not configured', () async {
    final s = ImageUploadService(cloudName: '', uploadPreset: '');
    expect(() => s.upload(photo), throwsA(isA<ImageUploadException>()));
  });

  test('upload returns the secure_url on success', () async {
    late http.BaseRequest captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response(
          jsonEncode({'secure_url': 'https://res.cloudinary.com/demo/a.jpg'}),
          200);
    });
    final s = ImageUploadService(
        cloudName: 'demo', uploadPreset: 'preset', client: client);

    final url = await s.upload(photo);

    expect(url, 'https://res.cloudinary.com/demo/a.jpg');
    expect(captured.url.toString(),
        'https://api.cloudinary.com/v1_1/demo/image/upload');
    expect(captured.method, 'POST');
  });

  test('upload throws on a non-200 response', () async {
    final client = MockClient((_) async => http.Response('bad', 400));
    final s = ImageUploadService(
        cloudName: 'demo', uploadPreset: 'preset', client: client);
    expect(() => s.upload(photo), throwsA(isA<ImageUploadException>()));
  });

  test('upload throws when the response has no url', () async {
    final client = MockClient((_) async => http.Response('{}', 200));
    final s = ImageUploadService(
        cloudName: 'demo', uploadPreset: 'preset', client: client);
    expect(() => s.upload(photo), throwsA(isA<ImageUploadException>()));
  });
}
