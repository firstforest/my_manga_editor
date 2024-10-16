import 'dart:convert';
import 'dart:io';

import 'package:my_manga_editor/logger.dart';
import 'package:my_manga_editor/models/manga.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'manga_repository.g.dart';

@riverpod
MangaRepository mangaRepository(MangaRepositoryRef ref) {
  return MangaRepository(sharedPreferences: SharedPreferences.getInstance());
}

const directoryName = 'MangaEditor';

class MangaRepository {
  MangaRepository({
    required Future<SharedPreferences> sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  final Future<SharedPreferences> _sharedPreferences;

  Future<void> saveManga(String fileName, Manga manga) async {
    logger.d('saveManga: $manga');
    final directoryRoot = await getApplicationDocumentsDirectory();
    final directory = Directory('${directoryRoot.path}/$directoryName');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(json.encode(manga.toJson()));
  }

  Future<List<String>> getMangaFiles() async {
    return [];
  }

  Future<Manga?> loadManga(String fileName) async {
    logger.d('loadManga');
    final directoryRoot = await getApplicationDocumentsDirectory();
    final file = File('${directoryRoot.path}/$directoryName/$fileName');
    final jsonString = (await file.exists()) ? await file.readAsString() : null;
    if (jsonString == null) {
      return null;
    }
    return Manga.fromJson(json.decode(jsonString));
  }

  Future<void> clearData() async {
    logger.d('clearData');
    final prefs = await _sharedPreferences;
    await prefs.clear();
  }
}
