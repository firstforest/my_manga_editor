import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/models/manga.dart';
import 'package:my_manga_editor/repositories/manga_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_comment_area.freezed.dart';

part 'ai_comment_area.g.dart';

@riverpod
Future<String> mangaDescription(Ref ref, MangaId mangaId) async {
  return await ref.read(mangaRepositoryProvider).toMarkdown(mangaId);
}

@freezed
abstract class AiComment with _$AiComment {
  const factory AiComment({required String text}) = _AiComment;
}

@riverpod
class AiCommentList extends _$AiCommentList {
  @override
  List<AiComment> build(MangaId mangaId) {
    final timer = Timer.periodic(Duration(seconds: 3), (_) async {
      state = state.toList()..add(await getAiComment(mangaId));
    });
    ref.onDispose(() {
      timer.cancel();
    });
    return [
      AiComment(text: 'HOGE'),
    ];
  }

  Future<AiComment> getAiComment(MangaId mangaId) async {
    final description =
        await ref.read(mangaDescriptionProvider(mangaId).future);
    return AiComment(text: description);
  }
}

class AiCommentArea extends HookConsumerWidget {
  const AiCommentArea(this.mangaId, {super.key});

  final MangaId mangaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiCommentList = ref.watch(aiCommentListProvider(mangaId));
    return ListView.separated(
      padding: const EdgeInsets.all(8.0).r,
      itemCount: aiCommentList.length,
      itemBuilder: (context, i) => AiCommentWidget(aiComment: aiCommentList[i]),
      separatorBuilder: (_, __) => SizedBox(height: 4.r),
    );
  }
}

class AiCommentWidget extends HookConsumerWidget {
  const AiCommentWidget({super.key, required this.aiComment});

  final AiComment aiComment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
          color: Colors.black12, borderRadius: BorderRadius.circular(4.r)),
      child: Text(aiComment.text),
    );
  }
}
