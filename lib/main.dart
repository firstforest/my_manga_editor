import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/env_config.dart';
import 'package:my_manga_editor/router.dart';
import 'package:my_manga_editor_data/my_manga_editor_data.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  final env = EnvConfig.current;

  // Initialize Firebase with environment-specific options
  await initializeFirebase(options: env.firebaseOptions);

  runApp(ScreenUtilInit(
    child: ProviderScope(
      overrides: [
        webClientIdProvider.overrideWithValue(env.webClientId),
      ],
      child: const MyApp(),
    ),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: '漫画プロットエディタ Komatto',
      theme: ThemeData(
        textTheme: GoogleFonts.notoSansJpTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: FlutterQuillLocalizations.localizationsDelegates,
      routerConfig: router,
    );
  }
}
