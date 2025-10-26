import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'setting_repository.g.dart';

/// SharedPreferencesのキー定数
class SettingKeys {
  static const String openaiApiKey = 'openai_api_key';
}

/// 設定を管理するRepository
class SettingRepository {
  final SharedPreferences _prefs;

  SettingRepository(this._prefs);

  /// OpenAI API Keyを取得
  String? getOpenAiApiKey() {
    return _prefs.getString(SettingKeys.openaiApiKey);
  }

  /// OpenAI API Keyを保存
  Future<void> setOpenAiApiKey(String apiKey) async {
    await _prefs.setString(SettingKeys.openaiApiKey, apiKey);
  }

  /// OpenAI API Keyを削除
  Future<void> deleteOpenAiApiKey() async {
    await _prefs.remove(SettingKeys.openaiApiKey);
  }
}

/// SharedPreferencesのプロバイダー
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return await SharedPreferences.getInstance();
}

/// SettingRepositoryのプロバイダー
@Riverpod(keepAlive: true)
SettingRepository settingRepository(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  if (prefs == null) {
    throw Exception('SharedPreferences not initialized');
  }
  return SettingRepository(prefs);
}

/// OpenAI API Keyのストリームプロバイダー
@riverpod
class OpenAiApiKey extends _$OpenAiApiKey {
  @override
  String? build() {
    final repository = ref.watch(settingRepositoryProvider);
    return repository.getOpenAiApiKey();
  }

  /// API Keyを更新
  Future<void> update(String apiKey) async {
    final repository = ref.read(settingRepositoryProvider);
    await repository.setOpenAiApiKey(apiKey);
    state = apiKey;
  }

  /// API Keyを削除
  Future<void> delete() async {
    final repository = ref.read(settingRepositoryProvider);
    await repository.deleteOpenAiApiKey();
    state = null;
  }
}
