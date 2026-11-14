import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 配色「墨と藍」。墨に近い文字色、少し青みのある白、差し色は藍の 1 色。
///
/// ColorScheme.fromSeed は色相を補正して指定どおりの色にならないため、
/// 画面で目に入る役割は copyWith で直接指定する。
ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: _ai,
  ).copyWith(
    primary: _ai,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFE3E9F5),
    onPrimaryContainer: const Color(0xFF15264A),
    surface: const Color(0xFFF6F6F4),
    onSurface: const Color(0xFF1E2126),
    onSurfaceVariant: const Color(0xFF5D626B),
    outline: const Color(0xFF8C9098),
    outlineVariant: const Color(0xFFDCDDDA),
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: const Color(0xFFF2F2EF),
    surfaceContainer: const Color(0xFFEFEFEC),
    surfaceContainerHigh: const Color(0xFFE9E9E5),
    surfaceContainerHighest: const Color(0xFFE3E3DF),
  );

  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  return base.copyWith(
    textTheme: GoogleFonts.notoSansJpTextTheme(base.textTheme),
    scaffoldBackgroundColor: scheme.surface,
    // 置いてあるものは机に置いた紙として、角の立った面と細い縁で描く。
    // 影は浮いているもの（ドラッグ中・メニュー・ダイアログ）だけに付ける
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      scrolledUnderElevation: 0,
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant),
    extensions: [AppTokens.fromScheme(scheme)],
  );
}

const _ai = Color(0xFF2E4B85);

/// 「うまくいっている」状態の緑。墨と藍の中で浮かないよう彩度を落とす
const _success = Color(0xFF3F8F5A);

/// 書ける場所ごとの紙の色など、ColorScheme の役割の名前だけでは意味が伝わらないもの。
/// 紙の色は ColorScheme から導き、同じ紙を別々の値で持たない。
/// success は ColorScheme に対応する役割がないので、このテーマの固定値を持つ
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.memoField,
    required this.dialogueField,
    required this.directionField,
    required this.success,
  });

  factory AppTokens.fromScheme(ColorScheme scheme) {
    return AppTokens(
      memoField: scheme.primaryContainer,
      dialogueField: scheme.surfaceContainerLowest,
      directionField: scheme.surfaceContainer,
      success: _success,
    );
  }

  /// メモ欄の紙。ページ全体への書き込みなので差し色を薄く敷く
  final Color memoField;

  /// セリフ欄・何でも書ける場所の紙。一番読む欄なので白
  final Color dialogueField;

  /// ト書き欄。セリフより一段沈める
  final Color directionField;

  /// 保存済み・オンラインなど、うまくいっている状態
  final Color success;

  /// テーマに登録されていない（テストで素の MaterialApp を使うなど）ときは、
  /// その場の ColorScheme から導く
  static AppTokens of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AppTokens>() ??
        AppTokens.fromScheme(theme.colorScheme);
  }

  @override
  AppTokens copyWith({
    Color? memoField,
    Color? dialogueField,
    Color? directionField,
    Color? success,
  }) {
    return AppTokens(
      memoField: memoField ?? this.memoField,
      dialogueField: dialogueField ?? this.dialogueField,
      directionField: directionField ?? this.directionField,
      success: success ?? this.success,
    );
  }

  @override
  AppTokens lerp(AppTokens? other, double t) {
    if (other == null) return this;
    return AppTokens(
      memoField: Color.lerp(memoField, other.memoField, t)!,
      dialogueField: Color.lerp(dialogueField, other.dialogueField, t)!,
      directionField: Color.lerp(directionField, other.directionField, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}
