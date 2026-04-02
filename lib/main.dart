import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/page/main_page.dart';
import 'package:my_manga_editor_data/my_manga_editor_data.dart';

import 'firebase_options.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await initializeFirebase(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ScreenUtilInit(child: ProviderScope(child: MyApp())));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '漫画プロットエディタ Komatto',
      theme: ThemeData(
        textTheme: GoogleFonts.notoSansJpTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: FlutterQuillLocalizations.localizationsDelegates,
      home: const MainPage(),
    );
  }
}
