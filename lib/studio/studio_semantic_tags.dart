import 'package:flutter/material.dart';

enum StudioTagCategory { ipChar, style, appearance, meta, other }

class StudioTagStyle {
  final String label;
  final Color color;
  final Color bg;

  const StudioTagStyle(this.label, this.color, this.bg);
}

class StudioTagClassifier {
  static const Map<StudioTagCategory, StudioTagStyle> styles = {
    StudioTagCategory.ipChar: StudioTagStyle('作品/角色', Color(0xFFA78BFA), Color(0x268B5CF6)),
    StudioTagCategory.style: StudioTagStyle('画风/构图', Color(0xFF38BDF8), Color(0x260EA5E9)),
    StudioTagCategory.appearance: StudioTagStyle('外观/服饰', Color(0xFF34D399), Color(0x2610B981)),
    StudioTagCategory.meta: StudioTagStyle('属性/AI', Color(0xFFFBBF24), Color(0x26F59E0B)),
    StudioTagCategory.other: StudioTagStyle('其他', Color(0xFF94A3B8), Color(0x2464748B)),
  };

  static final _metaRe = RegExp(
    r'^(r-?18g?|nsfw|ai)|ai生成|aiイラスト|オリジナル|原创|original|落書き|二次創作|fanart|女の子|1girl|美少女',
    caseSensitive: false,
  );
  static final _ipRe = RegExp(
    r'原神|genshin|崩壊|崩坏|スターレイル|ゼンレス|ブルーアーカイブ|ブルアカ|アークナイツ|明日方舟|アズールレーン|fgo|fate|東方|ウマ娘|ホロライブ|初音ミク|ポケモン|鳴潮|nikke',
    caseSensitive: false,
  );
  static final _appearanceRe = RegExp(
    r'制服|セーラー服|メイド|ドレス|水着|着物|チャイナ|ニーソ|タイツ|黒髪|白髪|銀髪|金髪|ロング|ショート|ツインテール|猫耳|獣耳|魔女|天使|悪魔',
    caseSensitive: false,
  );
  static final _styleRe = RegExp(
    r'背景|風景|风景|空|星空|夜景|夕焼け|厚塗り|水彩|逆光|ファンタジー|サイバーパンク|和風|ゴシック|かわいい|立ち絵|全身',
    caseSensitive: false,
  );

  static StudioTagCategory classify(String tag) {
    final t = tag.trim();
    if (_metaRe.hasMatch(t)) return StudioTagCategory.meta;
    if (_ipRe.hasMatch(t)) return StudioTagCategory.ipChar;
    if (_appearanceRe.hasMatch(t)) return StudioTagCategory.appearance;
    if (_styleRe.hasMatch(t)) return StudioTagCategory.style;
    return StudioTagCategory.other;
  }

  static StudioTagStyle styleOf(String tag) => styles[classify(tag)]!;
}

class StudioSemanticTagChip extends StatelessWidget {
  final String tag;
  final String? translatedTag;
  final VoidCallback? onTap;

  const StudioSemanticTagChip({
    super.key,
    required this.tag,
    this.translatedTag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final st = StudioTagClassifier.styleOf(tag);
    final display = (translatedTag != null && translatedTag!.isNotEmpty && translatedTag != tag)
        ? '#$tag · $translatedTag'
        : '#$tag';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: st.bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: st.color.withOpacity(0.32), width: 1),
        ),
        child: Text(
          display,
          style: TextStyle(
            color: st.color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
