import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/models/manga.dart';
import 'package:my_manga_editor/repositories/manga_providers.dart';

class MangaNameWidget extends HookConsumerWidget {
  const MangaNameWidget({
    super.key,
    required this.manga,
  });

  final Manga manga;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNameEdit = useState(false);
    final nameEditController = useTextEditingController(text: manga.name);
    final focusNode = useFocusNode();

    final onFocusChanged = useCallback(() {
      if (!focusNode.hasFocus) {
        ref
            .read(mangaProvider(manga.id).notifier)
            .updateName(nameEditController.text);
        isNameEdit.value = false;
      }
    });

    useEffect(() {
      focusNode.addListener(onFocusChanged);
      return () {
        focusNode.removeListener(onFocusChanged);
      };
    }, [manga.id]);

    return SizedBox(
      height: 48.r,
      child: isNameEdit.value
          ? Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 200.r,
                    maxWidth: 500.r,
                  ),
                  child: TextField(
                    focusNode: focusNode,
                    autofocus: true,
                    controller: nameEditController,
                    style: TextStyle(fontSize: 24.r),
                    onSubmitted: (value) {
                      ref
                          .read(mangaProvider(manga.id).notifier)
                          .updateName(value);
                      isNameEdit.value = false;
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ref
                        .read(mangaProvider(manga.id).notifier)
                        .updateName(nameEditController.text);
                    isNameEdit.value = false;
                  },
                  icon: const Icon(Icons.done),
                ),
              ],
            )
          : Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 200.r,
                  maxWidth: 500.r,
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    isNameEdit.value = true;
                  },
                  child: Text(
                    nameEditController.text,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 24.r),
                  ),
                ),
              ),
            ),
    );
  }
}
