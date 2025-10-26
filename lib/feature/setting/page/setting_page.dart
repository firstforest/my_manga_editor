import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/setting/repository/setting_repository.dart';

class SettingPage extends HookConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentApiKey = ref.watch(openAiApiKeyProvider);
    final controller = useTextEditingController(text: currentApiKey ?? '');
    final obscureText = useState(true);
    final isSaving = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OpenAI API設定',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'AIコメント機能を使用するには、OpenAI API Keyが必要です。',
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 24.h),
            TextField(
              controller: controller,
              obscureText: obscureText.value,
              decoration: InputDecoration(
                labelText: 'OpenAI API Key',
                hintText: 'sk-...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText.value ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    obscureText.value = !obscureText.value;
                  },
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSaving.value
                        ? null
                        : () async {
                            isSaving.value = true;
                            try {
                              final apiKey = controller.text.trim();
                              if (apiKey.isEmpty) {
                                await ref
                                    .read(openAiApiKeyProvider.notifier)
                                    .delete();
                              } else {
                                await ref
                                    .read(openAiApiKeyProvider.notifier)
                                    .update(apiKey);
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('API Keyを保存しました'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('保存に失敗しました: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } finally {
                              isSaving.value = false;
                            }
                          },
                    child: isSaving.value
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('保存'),
                  ),
                ),
                SizedBox(width: 8.w),
                if (currentApiKey != null)
                  ElevatedButton(
                    onPressed: isSaving.value
                        ? null
                        : () async {
                            isSaving.value = true;
                            try {
                              await ref
                                  .read(openAiApiKeyProvider.notifier)
                                  .delete();
                              controller.clear();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('API Keyを削除しました'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('削除に失敗しました: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } finally {
                              isSaving.value = false;
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('削除'),
                  ),
              ],
            ),
            SizedBox(height: 24.h),
            Text(
              'ヒント',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '• OpenAI API Keyは https://platform.openai.com/api-keys から取得できます\n'
              '• API Keyは安全に保存されます\n'
              '• 開発時に --dart-define=OPENAI_API_KEY=... で指定した場合、環境変数が優先されます',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
