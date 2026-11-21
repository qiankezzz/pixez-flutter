import 'dart:ui';
import 'package:material_ui/material_ui.dart';
import 'creator_analytics_store.dart';
import 'studio_theme.dart';

String _fmtCompact(int n) {
  if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}w';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
  return '$n';
}

/// Compact summary card placed on the "我的" (Profile/Settings) screen.
/// Tapping opens the dedicated full-screen [CreatorAnalyticsPage] subpage.
class CreatorSummaryCard extends StatelessWidget {
  final CreatorAnalyticsStore store;
  final VoidCallback onOpenDashboard;

  const CreatorSummaryCard({
    super.key,
    required this.store,
    required this.onOpenDashboard,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.studio;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return GestureDetector(
          onTap: onOpenDashboard,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: s.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: s.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.insights_rounded, size: 18, color: s.accent),
                        const SizedBox(width: 6),
                        Text(
                          '我的作品数据看板',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: s.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          store.loading
                              ? '同步第 ${store.fetchedPages} 页…'
                              : '查看全部 ${store.works.length} 幅',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: s.accent,
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, size: 18, color: s.accent),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _KpiTile(label: '总浏览', value: _fmtCompact(store.totalViews)),
                    const SizedBox(width: 8),
                    _KpiTile(label: '总收藏', value: _fmtCompact(store.totalBookmarks)),
                    const SizedBox(width: 8),
                    _KpiTile(
                      label: '平均收藏率',
                      value: '${store.avgBookmarkRate.toStringAsFixed(1)}%',
                      highlight: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Dedicated subpage for inspecting 100+ posted artworks with virtualized scrolling,
/// instant search, and metric sorting.
class CreatorAnalyticsPage extends StatefulWidget {
  final CreatorAnalyticsStore store;
  final Future<void> Function() onRefresh;
  final Widget Function(String thumbnailUrl) imageBuilder;
  final void Function(int illustId) onOpenIllust;

  const CreatorAnalyticsPage({
    super.key,
    required this.store,
    required this.onRefresh,
    required this.imageBuilder,
    required this.onOpenIllust,
  });

  @override
  State<CreatorAnalyticsPage> createState() => _CreatorAnalyticsPageState();
}

class _CreatorAnalyticsPageState extends State<CreatorAnalyticsPage> {
  AnalyticsSortMode _sort = AnalyticsSortMode.bookmarkRate;
  String _keyword = '';

  @override
  Widget build(BuildContext context) {
    final s = context.studio;

    return Scaffold(
      backgroundColor: s.bg,
      appBar: AppBar(
        title: const Text('我的作品数据看板'),
        actions: [
          IconButton(
            tooltip: '重新拉取最新数据',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: widget.onRefresh,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.store,
        builder: (context, _) {
          final items = widget.store.query(sort: _sort, keyword: _keyword);
          final maxVal = items.isEmpty
              ? 1.0
              : items
                  .map((w) => _metricValue(w))
                  .reduce((a, b) => a > b ? a : b)
                  .clamp(1.0, double.infinity);

          return RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _KpiTile(label: '总浏览', value: _fmtCompact(widget.store.totalViews)),
                            const SizedBox(width: 8),
                            _KpiTile(label: '总收藏', value: _fmtCompact(widget.store.totalBookmarks)),
                            const SizedBox(width: 8),
                            _KpiTile(
                              label: '平均收藏率',
                              value: '${widget.store.avgBookmarkRate.toStringAsFixed(1)}%',
                              highlight: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          onChanged: (v) => setState(() => _keyword = v),
                          decoration: const InputDecoration(
                            hintText: '搜索我的作品标题…',
                            prefixIcon: Icon(Icons.search_rounded, size: 19),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 34,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _sortPill('按收藏率', AnalyticsSortMode.bookmarkRate),
                              _sortPill('按浏览量', AnalyticsSortMode.views),
                              _sortPill('按收藏数', AnalyticsSortMode.bookmarks),
                              _sortPill('按最新发布', AnalyticsSortMode.newest),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.store.loading && items.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                    sliver: SliverList.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final w = items[index];
                        final pct = (_metricValue(w) / maxVal).clamp(0.08, 1.0);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            onTap: () => widget.onOpenIllust(w.id),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: s.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: s.border),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: SizedBox(
                                      width: 54,
                                      height: 54,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          widget.imageBuilder(w.thumbnailUrl),
                                          Positioned(
                                            top: 3,
                                            left: 3,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.7),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '#${index + 1}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                w.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: s.textPrimary,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${w.bookmarkRate.toStringAsFixed(1)}%',
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w700,
                                                color: s.accent,
                                                fontFeatures: const [FontFeature.tabularFigures()],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '浏览 ${_fmtCompact(w.views)} · 收藏 ${_fmtCompact(w.bookmarks)} · 评论 ${w.comments}',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: s.textMuted,
                                            fontFeatures: const [FontFeature.tabularFigures()],
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(999),
                                          child: LinearProgressIndicator(
                                            value: pct,
                                            minHeight: 5,
                                            backgroundColor: s.surfaceSubtle,
                                            valueColor: AlwaysStoppedAnimation(s.accent),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  double _metricValue(CreatorWorkStat w) {
    switch (_sort) {
      case AnalyticsSortMode.views:
        return w.views.toDouble();
      case AnalyticsSortMode.bookmarks:
        return w.bookmarks.toDouble();
      case AnalyticsSortMode.newest:
      case AnalyticsSortMode.bookmarkRate:
        return w.bookmarkRate;
    }
  }

  Widget _sortPill(String label, AnalyticsSortMode mode) {
    final s = context.studio;
    final active = _sort == mode;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _sort = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active ? s.accent : s.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: active ? s.accent : s.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : s.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _KpiTile({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.studio;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: highlight ? s.accentSoft : s.surfaceSubtle,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: highlight ? s.accent : s.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: highlight ? s.accent : s.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
