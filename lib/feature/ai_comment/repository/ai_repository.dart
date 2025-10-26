import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/foundation.dart';

class AiRepository {
  final String? _apiKey;

  AiRepository({String? apiKey}) : _apiKey = apiKey {
    if (apiKey != null && apiKey.isNotEmpty) {
      OpenAI.apiKey = apiKey;
    }
  }

  Future<String> generateComment(String prompt) async {
    if (_apiKey == null || _apiKey.isEmpty) {
      throw Exception('OpenAI API key is not configured');
    }

    try {
      final completion = await OpenAI.instance.chat.create(
        model: 'gpt-5-nano-2025-08-07',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  'あなたは制作中の漫画のプロットを見ている読者です。制作途中のプロットの情報が与えられるので、期待をしているという内容のコメントを返してください。口調はランダムで生成してください。一言コメントがよいです。'),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
            ],
          ),
        ],
      );

      if (completion.choices.isNotEmpty) {
        final message = completion.choices.first.message;
        final content = message.content;
        if (content != null && content.isNotEmpty) {
          return content.first.text ?? '';
        } else {
          throw Exception('No response generated');
        }
      } else {
        throw Exception('No response generated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AI Repository Error: $e');
      }
      rethrow;
    }
  }
}
