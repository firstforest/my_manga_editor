import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_manga_editor/models/manga.dart';
import 'package:my_manga_editor/views/manga_page_widget.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main_page.freezed.dart';
part 'main_page.g.dart';

@freezed
class MangaPageViewModel with _$MangaPageViewModel {
  const factory MangaPageViewModel({
    required Manga manga,
  }) = _MangaPageViewModel;
}

@riverpod
class MangaPageViewModelNotifier extends _$MangaPageViewModelNotifier {
  @override
  FutureOr<MangaPageViewModel> build() async {
    return MangaPageViewModel(
      manga: Manga(
        name: 'test',
        startPage: MangaStartPage.left,
        pages: [1, 2, 3]
            .map(
              (i) => MangaPage(
                id: i,
                memo: 'memo $i',
                dialogues: 'dialogues',
              ),
            )
            .toList(),
      ),
    );
  }

  void reorderPage(int oldIndex, int newIndex) {
    state.whenOrNull(data: (data) {
      final pages = List<MangaPage>.from(data.manga.pages);
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = pages.removeAt(oldIndex);
      pages.insert(newIndex, item);
      state = AsyncValue.data(data.copyWith.manga(pages: pages));
    });
  }
}

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(mangaPageViewModelNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('漫画用エディタ'),
      ),
      body: Row(
        children: [
          const Expanded(flex: 1, child: Workspace()),
          Expanded(
            flex: 3,
            child: ColoredBox(
              color: Colors.black12,
              child: viewModel.when(
                data: (data) => ReorderableListView.builder(
                  padding: EdgeInsets.all(8.r),
                  itemBuilder: (context, index) {
                    final page = data.manga.pages[index];
                    return Card(
                      key: ValueKey(page.id),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 8.r,
                          horizontal: 24.r,
                        ),
                        child: MangaPageWidget(
                          pageIndex: index + 1,
                          startPage: data.manga.startPage,
                          mangaPage: page,
                        ),
                      ),
                    );
                  },
                  itemCount: data.manga.pages.length,
                  onReorder: (oldIndex, newIndex) {
                    ref
                        .read(mangaPageViewModelNotifierProvider.notifier)
                        .reorderPage(oldIndex, newIndex);
                  },
                ),
                error: (_, __) => const Text('error'),
                loading: () => const CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Workspace extends StatefulWidget {
  const Workspace({super.key});

  @override
  State<Workspace> createState() => _WorkspaceState();
}

class _WorkspaceState extends State<Workspace> {
  final _controller = QuillController.basic();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QuillToolbar.simple(
          configurations:
              QuillSimpleToolbarConfigurations(controller: _controller),
        ),
        Expanded(
          child: QuillEditor.basic(
            configurations: QuillEditorConfigurations(
              controller: _controller,
              padding: const EdgeInsets.all(8.0),
            ),
          ),
        ),
      ],
    );
  }
}
