import 'dart:convert';

import 'package:my_manga_editor/logger.dart';
import 'package:my_manga_editor/models/manga.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'manga_repository.g.dart';

@riverpod
MangaRepository mangaRepository(MangaRepositoryRef ref) {
  return MangaRepository(sharedPreferences: SharedPreferences.getInstance());
}

class MangaRepository {
  MangaRepository({
    required Future<SharedPreferences> sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  final Future<SharedPreferences> _sharedPreferences;

  Future<void> saveManga(Manga manga) async {
    logger.d('saveManga: $manga');
    final prefs = await _sharedPreferences;
    await prefs.setString('manga', json.encode(manga.toJson()));
  }

  Future<Manga?> loadManga() async {
    logger.d('loadManga');
    final prefs = await _sharedPreferences;
    final jsonString = prefs.getString('manga');
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
