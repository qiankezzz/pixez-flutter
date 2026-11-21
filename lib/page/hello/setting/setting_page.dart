/*
- Copyright (C) 2020. by perol_notsf, All rights reserved
 *
- This program is free software: you can redistribute it and/or modify it under
- the terms of the GNU General Public License as published by the Free Software
- Foundation, either version 3 of the License, or (at your option) any later version.
 *
- This program is distributed in the hope that it will be useful, but WITHOUT ANY
- WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
- FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
- You should have received a copy of the GNU General Public License along with
- this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/new_version_chip.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/er/updater.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/account.dart';
import 'package:pixez/models/board_info.dart';
import 'package:pixez/models/glance_illust_persist.dart';
import 'package:pixez/models/recommend.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/page/about/about_page.dart';
import 'package:pixez/page/account/edit/account_edit_page.dart';
import 'package:pixez/page/account/select/account_select_page.dart';
import 'package:pixez/page/board/board_page.dart';
import 'package:pixez/page/book/tag/book_tag_page.dart';
import 'package:pixez/page/hello/recom/recom_manga_page.dart';
import 'package:pixez/page/hello/setting/data_export_page.dart';
import 'package:pixez/page/hello/setting/setting_quality_page.dart';
import 'package:pixez/page/history/history_page.dart';
import 'package:pixez/page/login/login_page.dart';
import 'package:pixez/page/novel/history/novel_history_page.dart';
import 'package:pixez/page/novel/novel_rail.dart';
import 'package:pixez/page/picture/illust_lighting_page.dart';
import 'package:pixez/page/shield/shield_page.dart';
import 'package:pixez/page/task/job_page.dart';
import 'package:pixez/page/theme/theme_page.dart';
import 'package:pixez/page/user/users_page.dart';
import 'package:pixez/studio/creator_analytics_store.dart';
import 'package:pixez/studio/creator_analytics_widgets.dart';
import 'package:pixez/studio/studio_theme.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final CreatorAnalyticsStore _analyticsStore = CreatorAnalyticsStore();

  @override
  void initState() {
    super.initState();
    initMethod();
    fetchBoard();
    _initCreatorAnalytics();
  }

  @override
  void dispose() {
    _analyticsStore.dispose();
    super.dispose();
  }

  bool hideEmail = true;

  bool get _effectiveHasNewVersion =>
      Updater.result == Result.yes &&
      Updater.latestVersion != userSetting.ignoreUpdateVersion;

  Future<void> _initCreatorAnalytics() async {
    await _analyticsStore.loadFromCache();
    await _syncCreatorAnalytics(force: false);
  }

  Future<void> _syncCreatorAnalytics({bool force = false}) async {
    final now = accountStore.now;
    if (now == null) return;
    final uid = int.tryParse(now.userId);
    if (uid == null) return;

    await _analyticsStore.syncAllWorks(
      force: force,
      fetchPage: (nextUrl) async {
        final resp = nextUrl == null
            ? await apiClient.getUserIllusts(uid, 'illust')
            : await apiClient.getNext(nextUrl);
        final data = Recommend.fromJson(resp.data);
        return AnalyticsPageResult(
          items: data.illusts
              .map(
                (it) => CreatorWorkStat(
                  id: it.id,
                  title: it.title,
                  thumbnailUrl: it.imageUrls.squareMedium,
                  views: it.totalView,
                  bookmarks: it.totalBookmarks,
                  comments: it.totalComments ?? 0,
                  createDate: it.createDate,
                ),
              )
              .toList(),
          nextUrl: data.nextUrl,
        );
      },
    );
  }

  void _openAnalyticsSubpage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreatorAnalyticsPage(
          store: _analyticsStore,
          onRefresh: () => _syncCreatorAnalytics(force: true),
          imageBuilder: (url) => PixivImage(url, fit: BoxFit.cover),
          onOpenIllust: (id) => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => IllustLightingPage(id: id)),
          ),
        ),
      ),
    );
  }

  initMethod() async {
    if (Constants.isGooglePlay || Platform.isIOS) return;
    if (Updater.result != Result.timeout) return;
    await Updater.check();
    if (mounted) setState(() {});
  }

  Widget _buildSectionCard(BuildContext context, List<Widget> children) {
    final s = context.studio;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: s.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: s.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.studio;
    return Scaffold(
      backgroundColor: s.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppBar(
                  elevation: 0.0,
                  automaticallyImplyLeading: false,
                  forceMaterialTransparency: true,
                  backgroundColor: Colors.transparent,
                  title: Text(
                    '我的与设置',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: s.textPrimary,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.palette_outlined, color: s.textPrimary),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => ThemePage()),
                        );
                      },
                    ),
                  ],
                ),
                Observer(
                  builder: (context) {
                    final now = accountStore.now;
                    if (now == null) return const SizedBox.shrink();
                    final uid = int.tryParse(now.userId) ?? 0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Studio Profile Card with direct "我的作品" & "切换账号" buttons
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: s.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: s.border),
                          ),
                          child: Column(
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  if (uid > 0) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => UsersPage(id: uid),
                                      ),
                                    );
                                  }
                                },
                                child: Row(
                                  children: [
                                    PainterAvatar(
                                      url: now.userImage,
                                      id: uid,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            now.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: s.textPrimary,
                                            ),
                                          ),
                                          if (now.mailAddress.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 3),
                                              child: Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      hideEmail
                                                          ? now.hiddenEmail()
                                                          : now.mailAddress,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: s.textMuted,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  GestureDetector(
                                                    onTap: () => setState(() {
                                                      hideEmail = !hideEmail;
                                                    }),
                                                    child: Text(
                                                      hideEmail
                                                          ? I18n.of(context)
                                                              .reveal
                                                          : I18n.of(context)
                                                              .hide,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: s.accent,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.chevron_right_rounded,
                                        color: s.textMuted),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        if (uid > 0) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  UsersPage(id: uid),
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(
                                          Icons.collections_outlined,
                                          size: 16),
                                      label: const Text('我的作品与收藏'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: s.accent,
                                        side: BorderSide(color: s.accent),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .push(MaterialPageRoute(
                                                builder: (_) =>
                                                    AccountSelectPage()));
                                      },
                                      icon: const Icon(
                                          Icons.switch_account_outlined,
                                          size: 16),
                                      label: const Text('切换账号'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: s.textPrimary,
                                        side: BorderSide(color: s.border),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Creator Analytics Summary Card -> Dedicated Subpage (supports 100+ works)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CreatorSummaryCard(
                            store: _analyticsStore,
                            onOpenDashboard: _openAnalyticsSubpage,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                _buildSectionCard(context, <Widget>[
                  if (accountStore.now != null)
                    ListTile(
                      leading: const Icon(Icons.account_box_outlined),
                      title: Text(I18n.of(context).account_message),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                AccountEditPage()));
                      },
                    ),
                  ListTile(
                    leading: const Icon(Icons.history_rounded),
                    title: Text(I18n.of(context).history_record),
                    onTap: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                        return Constants.type == 0
                            ? HistoryPage()
                            : NovelHistory();
                      }));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.tune_rounded),
                    title: Text(I18n.of(context).quality_setting),
                    onTap: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                        return SettingQualityPage();
                      }));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.bookmark_border_rounded),
                    title: Text(I18n.of(context).favorited_tag),
                    onTap: () =>
                        Leader.pushWithScaffold(context, BookTagPage()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.block_rounded),
                    title: Text(I18n.of(context).shielding_settings),
                    onTap: () => Leader.push(context, ShieldPage()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.download_outlined),
                    title: Text(I18n.of(context).task_progress),
                    onTap: () => Leader.push(context, JobPage()),
                  ),
                  ListTile(
                    onTap: () => Leader.push(context, DataExportPage()),
                    title: Text(I18n.of(context).app_data),
                    leading: const Icon(Icons.folder_open_rounded),
                  ),
                ]),
                _buildSectionCard(context, <Widget>[
                  ListTile(
                    leading: const Icon(Icons.library_books_outlined),
                    title: Text(I18n.of(context).manga),
                    onTap: () => Leader.push(context, RecomMangaPage()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.book_outlined),
                    title: Text(I18n.of(context).novel),
                    onTap: () => Navigator.of(context, rootNavigator: true)
                        .pushReplacement(MaterialPageRoute(
                            builder: (context) => NovelRail())),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: Text(I18n.of(context).about),
                    onTap: () => Leader.push(
                      context,
                      AboutPage(newVersion: _effectiveHasNewVersion),
                    ),
                    trailing: Observer(
                      builder: (context) {
                        return Visibility(
                          child: NewVersionChip(),
                          visible: _effectiveHasNewVersion,
                        );
                      },
                    ),
                  ),
                  if (_needBoardSection)
                    ListTile(
                      leading: const Icon(Icons.article_outlined),
                      title: Text(I18n.of(context).bulletin_board),
                      onTap: () => Leader.push(
                        context,
                        BoardPage(boardList: _boardList),
                      ),
                    ),
                  Observer(builder: (context) {
                    if (accountStore.now != null)
                      return ListTile(
                        leading: const Icon(Icons.logout_rounded),
                        title: Text(I18n.of(context).logout),
                        onTap: () => _showLogoutDialog(context),
                      );
                    else
                      return ListTile(
                        leading: const Icon(Icons.login_rounded),
                        title: Text(I18n.of(context).login),
                        onTap: () => Leader.push(context, LoginPage()),
                      );
                  }),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _showLogoutDialog(BuildContext context) async {
    final result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(I18n.of(context).logout),
            actions: <Widget>[
              TextButton(
                child: Text(I18n.of(context).cancel),
                onPressed: () {
                  Navigator.of(context).pop("CANCEL");
                },
              ),
              TextButton(
                child: Text(I18n.of(context).ok),
                onPressed: () {
                  Navigator.of(context).pop("OK");
                },
              ),
            ],
          );
        });
    switch (result) {
      case "OK":
        {
          accountStore.deleteAll();
        }
        break;
      case "CANCEL":
        {}
        break;
    }
  }

  void cleanGlanceData() async {
    GlanceIllustPersistProvider glanceIllustPersistProvider =
        GlanceIllustPersistProvider();
    await glanceIllustPersistProvider.open();
    await glanceIllustPersistProvider.deleteAll();
    await glanceIllustPersistProvider.close();
  }

  bool _needBoardSection = false;
  List<BoardInfo> _boardList = [];

  fetchBoard() async {
    try {
      if (BoardInfo.boardDataLoaded) {
        setState(() {
          _boardList = BoardInfo.boardList;
          _needBoardSection = _boardList.isNotEmpty;
        });
        return;
      }
      final list = await BoardInfo.load();
      setState(() {
        BoardInfo.boardDataLoaded = true;
        _boardList = list;
        _needBoardSection = _boardList.isNotEmpty;
      });
    } catch (e) {}
  }
}
