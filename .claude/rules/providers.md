---
paths:
  - "lib/feature/**"
  - "local_package/my_manga_editor_data/lib/repository/**"
  - "local_package/my_manga_editor_data/lib/service/**"
---

# Riverpod Provider Patterns

- `@riverpod` (function-style) for streams/futures: `allMangaList`, `mangaPageIdList`, `onlineStatus`
- `@Riverpod(keepAlive: true)` for persistent state: `MangaRepository`, `FirebaseService`
- `@riverpod` class notifiers for complex UI state: `MangaPageViewModelNotifier`

## Testing Providers
- Tests in `test/feature/manga/provider/` using Mockito with `@GenerateNiceMocks`
- Uses `ProviderContainer` for Riverpod provider isolation
- `fake_cloud_firestore` package available for Firestore mocking
