import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor_data/repository/exceptions.dart';
import 'package:my_manga_editor_data/repository/memo_image_repository.dart';
import 'package:my_manga_editor_data/service/firebase/firebase_service.dart';
import 'package:my_manga_editor_data/service/firebase/memo_image_storage_service.dart';

@GenerateNiceMocks([MockSpec<MemoImageStorageService>()])
import 'memo_image_repository_test.mocks.dart';

final _png = Uint8List.fromList(
    [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00]);
final _jpeg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x00]);
final _gif = Uint8List.fromList('GIF89a....'.codeUnits);
final _webp = Uint8List.fromList('RIFF\x00\x00\x00\x00WEBPVP8 '.codeUnits);

void main() {
  group('detectImageContentType', () {
    test('先頭のバイト列から画像の形式を判定する', () {
      expect(detectImageContentType(_png), 'image/png');
      expect(detectImageContentType(_jpeg), 'image/jpeg');
      expect(detectImageContentType(_gif), 'image/gif');
      expect(detectImageContentType(_webp), 'image/webp');
    });

    test('画像でないバイト列や短すぎるバイト列は null', () {
      expect(detectImageContentType(Uint8List.fromList('hello'.codeUnits)),
          isNull);
      expect(detectImageContentType(Uint8List(0)), isNull);
      expect(detectImageContentType(Uint8List.fromList([0x89, 0x50])), isNull);
    });
  });

  group('upload', () {
    late MockMemoImageStorageService service;
    late MemoImageRepository repository;
    final mangaId = MangaId('manga-1');

    setUp(() {
      service = MockMemoImageStorageService();
      repository = MemoImageRepository(storageService: service);
    });

    test('判定した形式を付けて保存し、URL を返す', () async {
      when(service.upload(
        mangaId: anyNamed('mangaId'),
        bytes: anyNamed('bytes'),
        contentType: anyNamed('contentType'),
      )).thenAnswer((_) async => 'https://example.com/a.png');

      final url = await repository.upload(mangaId, _png);

      expect(url, 'https://example.com/a.png');
      verify(service.upload(
        mangaId: 'manga-1',
        bytes: _png,
        contentType: 'image/png',
      )).called(1);
    });

    test('上限を超える画像は保存せずに MemoImageTooLargeException', () async {
      final big = Uint8List(MemoImageRepository.maxBytes + 1)..setAll(0, _png);

      await expectLater(
        repository.upload(mangaId, big),
        throwsA(isA<MemoImageTooLargeException>()),
      );
      verifyNever(service.upload(
        mangaId: anyNamed('mangaId'),
        bytes: anyNamed('bytes'),
        contentType: anyNamed('contentType'),
      ));
    });

    test('ちょうど上限の画像は保存する', () async {
      final exact = Uint8List(MemoImageRepository.maxBytes)..setAll(0, _png);
      when(service.upload(
        mangaId: anyNamed('mangaId'),
        bytes: anyNamed('bytes'),
        contentType: anyNamed('contentType'),
      )).thenAnswer((_) async => 'https://example.com/a.png');

      expect(
          await repository.upload(mangaId, exact), 'https://example.com/a.png');
    });

    test('画像でないデータは UnsupportedMemoImageException', () async {
      await expectLater(
        repository.upload(mangaId, Uint8List.fromList('text'.codeUnits)),
        throwsA(isA<UnsupportedMemoImageException>()),
      );
    });

    test('保存に失敗したら StorageException', () async {
      when(service.upload(
        mangaId: anyNamed('mangaId'),
        bytes: anyNamed('bytes'),
        contentType: anyNamed('contentType'),
      )).thenThrow(FirebaseServiceException('denied', code: 'unauthorized'));

      await expectLater(
        repository.upload(mangaId, _png),
        throwsA(isA<StorageException>()
            .having((e) => e.code, 'code', 'unauthorized')),
      );
    });
  });

  group('deleteAllForManga', () {
    test('削除に失敗しても例外を投げない', () async {
      final service = MockMemoImageStorageService();
      when(service.deleteAllForManga(any))
          .thenThrow(FirebaseServiceException('network'));

      await MemoImageRepository(storageService: service)
          .deleteAllForManga(MangaId('manga-1'));

      verify(service.deleteAllForManga('manga-1')).called(1);
    });
  });
}
