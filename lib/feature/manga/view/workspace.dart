import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor_common/logger.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor_data/repository/exceptions.dart';
import 'package:my_manga_editor_data/repository/memo_image_repository.dart';
import 'package:my_manga_editor/widgets/quill_text_field_semantics.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_providers.dart';
import 'package:my_manga_editor/feature/manga/view/memo_image_embed.dart';
import 'package:my_manga_editor/hooks/quill_controller_hook.dart';
import 'package:my_manga_editor/theme/app_theme.dart';
import 'package:my_manga_editor/widgets/paper_sheet.dart';

class Workspace extends HookConsumerWidget {
  const Workspace({
    super.key,
    required this.mangaId,
    required this.deltaId,
  });

  final MangaId mangaId;
  final DeltaId deltaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deltaAsync = ref.watch(deltaProvider(mangaId, deltaId));

    return switch (deltaAsync) {
      AsyncData<Delta?>(:final value) => _QuillEditor(
          initialText: value,
          onTextChanged: (delta) {
            ref
                .read(deltaProvider(mangaId, deltaId).notifier)
                .updateDelta(delta);
          },
          onUploadImage: (bytes) => _uploadImage(context, ref, bytes),
        ),
      _ => SizedBox.shrink(),
    };
  }

  /// 画像を保存して URL を返す。保存できなかったときは理由を伝えて null を返す。
  Future<String?> _uploadImage(
      BuildContext context, WidgetRef ref, Uint8List bytes) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      return await ref.read(memoImageRepositoryProvider).upload(mangaId, bytes);
    } on MemoImageTooLargeException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(_tooLargeMessage(e.maxBytes))),
      );
    } on UnsupportedMemoImageException {
      messenger.showSnackBar(
        const SnackBar(content: Text('PNG・JPEG・GIF・WebP の画像を貼れます')),
      );
    } on Exception catch (e) {
      logger.e('Failed to upload memo image', error: e);
      messenger.showSnackBar(
        const SnackBar(content: Text('画像を保存できませんでした。通信状態を確かめてもう一度お試しください')),
      );
    }
    return null;
  }
}

String _tooLargeMessage(int maxBytes) =>
    '画像が大きすぎます。${maxBytes ~/ (1024 * 1024)} MB までの画像を貼れます';

class _QuillEditor extends HookConsumerWidget {
  const _QuillEditor({
    required this.initialText,
    required this.onTextChanged,
    required this.onUploadImage,
  });

  final Delta? initialText;
  final Function(Delta delta) onTextChanged;

  /// 画像を保存して URL を返す。保存できなかったときは null。
  final Future<String?> Function(Uint8List bytes) onUploadImage;

  static const _imageTypeGroup = XTypeGroup(
    label: '画像',
    extensions: ['png', 'jpg', 'jpeg', 'gif', 'webp'],
    mimeTypes: ['image/png', 'image/jpeg', 'image/gif', 'image/webp'],
    // public.image だと HEIC なども選べてしまい、選んだあとで断ることになる
    uniformTypeIdentifiers: [
      'public.png',
      'public.jpeg',
      'com.compuserve.gif',
      'org.webmproject.webp',
    ],
  );

  void _onTextChanged(QuillController controller) {
    final selection = controller.selection;
    final index = selection.baseOffset - 3;
    if (0 <= index) {
      if (controller.document.getPlainText(index, 3) == '\n* ') {
        logger.d('text: ${controller.document.toPlainText()}');
        controller.document.format(selection.baseOffset - 2, 2, Attribute.ul);
        controller.document.delete(selection.baseOffset - 2, 2);
        controller.updateSelection(
          selection.copyWith(baseOffset: selection.baseOffset - 2),
          ChangeSource.silent,
        );
      }
    } else if (index == -1) {
      if (controller.document.getPlainText(0, 2) == '* ') {
        logger.d('text: ${controller.document.toPlainText()}');
        controller.document.format(0, 2, Attribute.ul);
        controller.document.delete(0, 1);
        controller.updateSelection(
          selection.copyWith(baseOffset: 1),
          ChangeSource.silent,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 保存中の画像の枚数。0 より大きいあいだ進捗バーを出す
    final uploadingCount = useState(0);
    final latestOnUploadImage = useRef(onUploadImage)..value = onUploadImage;

    Future<String?> upload(Uint8List bytes) async {
      uploadingCount.value++;
      try {
        return await latestOnUploadImage.value(bytes);
      } finally {
        if (context.mounted) uploadingCount.value--;
      }
    }

    final controller = useQuillController(
      initialText?.isNotEmpty == true ? initialText : null,
      config: QuillControllerConfig(
        // flutter_quill 側で experimental 指定の API。貼り付けた画像を
        // 保存するためにこれしか手段がない
        // ignore: experimental_member_use
        clipboardConfig: QuillClipboardConfig(
          onImagePaste: upload,
          // HTML の貼り付けを先に試されると、ブラウザでコピーした画像が
          // 元サイトの URL のまま (保存されずに) 入ってしまう
          // ignore: experimental_member_use
          enableExternalRichPaste: false,
        ),
      ),
    );
    final focusNode = useFocusNode();

    Future<void> pickImage() async {
      // メモにカーソルがないときは末尾に足す
      final hadFocus = focusNode.hasFocus;
      final messenger = ScaffoldMessenger.of(context);
      final Uint8List bytes;
      try {
        final file =
            await openFile(acceptedTypeGroups: const [_imageTypeGroup]);
        if (file == null) return;
        // 巨大なファイルを丸ごと読み込む前に断る
        if (await file.length() > MemoImageRepository.maxBytes) {
          messenger.showSnackBar(
            SnackBar(
                content: Text(_tooLargeMessage(MemoImageRepository.maxBytes))),
          );
          return;
        }
        bytes = await file.readAsBytes();
      } on Exception catch (e) {
        logger.e('Failed to read image file', error: e);
        messenger.showSnackBar(
          const SnackBar(content: Text('画像ファイルを読み込めませんでした')),
        );
        return;
      }

      final url = await upload(bytes);
      if (url == null || !context.mounted) return;

      final docEnd = controller.document.length - 1;
      final selection = controller.selection;
      final index = hadFocus && selection.isValid
          ? selection.end.clamp(0, docEnd)
          : docEnd;
      // 行の途中に入れると、画像の前で行が分かれる (改行が 1 つ足される)
      final splitsLine =
          index > 0 && controller.document.getPlainText(index - 1, 1) != '\n';
      controller.replaceText(index, 0, BlockEmbed.image(url), null);
      controller.updateSelection(
        TextSelection.collapsed(offset: index + (splitsLine ? 2 : 1)),
        ChangeSource.local,
      );
    }

    final onTextChanged = useCallback(
      () {
        this.onTextChanged(controller.document.toDelta());
      },
      [],
    );

    final formatText = useCallback(() {
      _onTextChanged(controller);
    }, [controller]);

    useEffect(() {
      controller.addListener(onTextChanged);
      controller.addListener(formatText);
      return () {
        controller.removeListener(onTextChanged);
        controller.removeListener(formatText);
      };
    }, []);
    return Column(
      children: [
        QuillSimpleToolbar(
          controller: controller,
          config: QuillSimpleToolbarConfig(
            showFontFamily: false,
            showFontSize: false,
            showBoldButton: false,
            showItalicButton: false,
            showUnderLineButton: false,
            showStrikeThrough: false,
            showInlineCode: false,
            showSubscript: false,
            showSuperscript: false,
            showColorButton: false,
            showBackgroundColorButton: false,
            showClearFormat: false,
            showHeaderStyle: false,
            showCodeBlock: false,
            showQuote: false,
            showIndent: false,
            showLink: false,
            // flutter_quill 側で experimental 指定の API。非表示にする用途で
            // 意図的に使っている (警告のままだと flutter analyze が exit 1 になる)
            // ignore: experimental_member_use
            showClipboardCut: false,
            // ignore: experimental_member_use
            showClipboardCopy: false,
            // ignore: experimental_member_use
            showClipboardPaste: false,
            showRedo: false,
            showUndo: false,
            customButtons: [
              QuillToolbarCustomButtonOptions(
                icon: const Icon(Icons.add_photo_alternate_outlined),
                tooltip: '画像を追加',
                onPressed: pickImage,
              ),
            ],
          ),
        ),
        // 進捗バーの有無で紙の位置が動かないよう、高さは常に確保しておく
        SizedBox(
          height: 4,
          child: uploadingCount.value > 0
              ? const LinearProgressIndicator(semanticsLabel: '画像を保存しています')
              : null,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: 16.r),
            child: PaperSheet(
              color: AppTokens.of(context).dialogueField,
              child: QuillTextFieldSemantics(
                controller: controller,
                focusNode: focusNode,
                label: '何でも書ける場所',
                child: QuillEditor.basic(
                  controller: controller,
                  focusNode: focusNode,
                  config: QuillEditorConfig(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.r, horizontal: 16.r),
                    placeholder: '何でも書ける場所',
                    embedBuilders: const [MemoImageEmbedBuilder()],
                    unknownEmbedBuilder: const UnknownEmbedBuilder(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
