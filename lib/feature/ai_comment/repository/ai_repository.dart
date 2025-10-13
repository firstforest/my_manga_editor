import 'package:flutter/foundation.dart';
import 'package:dart_openai/dart_openai.dart';

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
        model: "gpt-3.5-turbo",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                'あなたは漫画制作のアドバイザーです。提供された漫画のプロットやページ内容を分析し、建設的なフィードバックやアドバイスを日本語で提供してください。',
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
            ],
          ),
        ],
        maxTokens: 500,
        temperature: 0.7,
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