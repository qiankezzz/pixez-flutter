import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AnalyticsSortMode { bookmarkRate, views, bookmarks, newest }

class CreatorWorkStat {
  final int id;
  final String title;
  final String thumbnailUrl;
  final int views;
  final int bookmarks;
  final int comments;
  final String createDate;

  const CreatorWorkStat({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.views,
    required this.bookmarks,
    required this.comments,
    required this.createDate,
  });

  double get bookmarkRate => views > 0 ? (bookmarks / views) * 100.0 : 0.0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'thumbnailUrl': thumbnailUrl,
        'views': views,
        'bookmarks': bookmarks,
        'comments': comments,
        'createDate': createDate,
      };

  factory CreatorWorkStat.fromJson(Map<String, dynamic> json) => CreatorWorkStat(
        id: json['id'] as int,
        title: (json['title'] ?? '') as String,
        thumbnailUrl: (json['thumbnailUrl'] ?? '') as String,
        views: (json['views'] ?? 0) as int,
        bookmarks: (json['bookmarks'] ?? 0) as int,
        comments: (json['comments'] ?? 0) as int,
        createDate: (json['createDate'] ?? '') as String,
      );
}

class AnalyticsPageResult {
  final List<CreatorWorkStat> items;
  final String? nextUrl;

  const AnalyticsPageResult({required this.items, this.nextUrl});
}

/// Decoupled store supporting 100+ posted works with:
/// - Instant SharedPreferences cache load (0ms startup)
/// - Rate-limit-safe pagination (350ms polite interval between pages)
/// - 30-minute TTL auto-throttle so switching tabs never spams Pixiv API
class CreatorAnalyticsStore extends ChangeNotifier {
  static const _cacheKey = 'pixez_studio_creator_analytics_v1';
  static const _cacheTsKey = 'pixez_studio_creator_analytics_ts_v1';
  static const Duration cacheTtl = Duration(minutes: 30);

  List<CreatorWorkStat> _works = [];
  bool _loading = false;
  int _fetchedPages = 0;
  DateTime? _lastUpdated;
  String? _error;

  List<CreatorWorkStat> get works => _works;
  bool get loading => _loading;
  int get fetchedPages => _fetchedPages;
  DateTime? get lastUpdated => _lastUpdated;
  String? get error => _error;

  int get totalViews => _works.fold(0, (s, w) => s + w.views);
  int get totalBookmarks => _works.fold(0, (s, w) => s + w.bookmarks);
  int get totalComments => _works.fold(0, (s, w) => s + w.comments);
  double get avgBookmarkRate =>
      totalViews > 0 ? (totalBookmarks / totalViews) * 100.0 : 0.0;

  List<CreatorWorkStat> query({
    required AnalyticsSortMode sort,
    String keyword = '',
  }) {
    final q = keyword.trim().toLowerCase();
    final list = q.isEmpty
        ? List<CreatorWorkStat>.from(_works)
        : _works.where((w) => w.title.toLowerCase().contains(q)).toList();

    list.sort((a, b) {
      switch (sort) {
        case AnalyticsSortMode.views:
          return b.views.compareTo(a.views);
        case AnalyticsSortMode.bookmarks:
          return b.bookmarks.compareTo(a.bookmarks);
        case AnalyticsSortMode.newest:
          return b.createDate.compareTo(a.createDate);
        case AnalyticsSortMode.bookmarkRate:
          return b.bookmarkRate.compareTo(a.bookmarkRate);
      }
    });
    return list;
  }

  Future<void> loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    final ts = prefs.getInt(_cacheTsKey);
    if (raw != null && raw.isNotEmpty) {
      final decoded = (jsonDecode(raw) as List<dynamic>)
          .map((e) => CreatorWorkStat.fromJson(e as Map<String, dynamic>))
          .toList();
      _works = decoded;
      if (ts != null) _lastUpdated = DateTime.fromMillisecondsSinceEpoch(ts);
      notifyListeners();
    }
  }

  /// Syncs all pages of the user's posted works via [fetchPage].
  /// Pass `force: true` on pull-to-refresh; otherwise respects the 30-minute TTL.
  Future<void> syncAllWorks({
    required Future<AnalyticsPageResult> Function(String? nextUrl) fetchPage,
    bool force = false,
    int maxPages = 20, // supports up to ~600 works safely
  }) async {
    if (_loading) return;
    if (!force &&
        _lastUpdated != null &&
        DateTime.now().difference(_lastUpdated!) < cacheTtl &&
        _works.isNotEmpty) {
      return;
    }

    _loading = true;
    _fetchedPages = 0;
    _error = null;
    notifyListeners();

    try {
      final collected = <CreatorWorkStat>[];
      final seenIds = <int>{};
      String? nextUrl;

      for (int page = 0; page < maxPages; page++) {
        final res = await fetchPage(nextUrl);
        _fetchedPages = page + 1;
        for (final item in res.items) {
          if (seenIds.add(item.id)) collected.add(item);
        }
        nextUrl = res.nextUrl;
        notifyListeners();
        if (nextUrl == null || nextUrl.isEmpty) break;
        // Polite delay to avoid Pixiv 429 rate-limiting
        await Future.delayed(const Duration(milliseconds: 350));
      }

      _works = collected;
      _lastUpdated = DateTime.now();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cacheKey,
        jsonEncode(_works.map((e) => e.toJson()).toList()),
      );
      await prefs.setInt(_cacheTsKey, _lastUpdated!.millisecondsSinceEpoch);
    } catch (e) {
      _error = '同步失败：$e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
