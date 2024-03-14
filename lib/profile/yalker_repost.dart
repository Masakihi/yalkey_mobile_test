import 'dart:convert';
import 'package:flutter/material.dart';
import '../api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../followed_list_page.dart';
import '../following_list_page.dart';
import '../post/post_model.dart';
import '../post/post_widget.dart';
import 'profile_edit_page.dart';
import 'bar_graph.dart';
import 'report_model.dart';

const Map<String, String> badge2Explanation = {
  "超早起き": "超早起き：過去1週間のうち7日早起き投稿したyalker",
  "早起き": "早起き：過去1週間のうち3日早起き投稿したyalker",
  "超努力家": "超努力家：めちゃくちゃ頑張って投稿してるyalker",
  "努力家": "努力家：けっこう頑張って投稿してるyalker",
  "常連": "常連：継続して投稿してるyalker",
};

class YalkerRepostPage extends StatefulWidget {
  final int userNumber;
  YalkerRepostPage({Key? key, required this.userNumber}) : super(key: key);

  @override
  _YalkerRepostPageState createState() => _YalkerRepostPageState();
}

class _YalkerRepostPageState extends State<YalkerRepostPage> {
  Map<String, dynamic>? _profileData;
  late Map<String, List<Report>> _reportListMap = {
    'num_report_list': [],
    'bool_report_list': []
  };
  late bool _loadingReportList = false;
  int relationType = 1;

  late List<Post> _postList = []; // user_repost_list を格納するリスト
  late List<Post> _pinnedPostList = [];
  late ScrollController _scrollController; // ListView のスクロールを制御するコントローラー
  bool _loading = false; // データをロード中かどうかを示すフラグ
  bool _loadingPinnedPost = false;
  int _page = 1; // 現在のページ番号

  @override
  void initState() {
    super.initState();
    _clearCache();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _fetchPostList(); // 最初のデータを読み込む
    //_fetchPinnedPostList();
    _fetchProfileData();
    // _fetchReportList();
    if (_profileData != null) {
      if (_profileData!['relation_type'] != null) {
        relationType = _profileData!['relation_type'];
      }
    } else {
      relationType = 1;
    }
  }

  // ListView のスクロールイベントを監視するリスナー
  void _scrollListener() {
    // スクロール位置が最下部に達したかどうかをチェック
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // 最下部に達したら新しいデータをロードする
      _loadMoreData();
    }
  }

  Future<void> _fetchPinnedPostList() async {
    setState(() {
      _loadingPinnedPost = true; // データのロード中フラグをtrueに設定
    });
    PostListResponse postListResponse =
    await PostListResponse.fetchYalkerPinnedPostResponse(widget.userNumber, 1);
    if (mounted) {
      setState(() {
        _pinnedPostList.addAll(postListResponse.postList); // 新しいデータをリストに追加
        _loadingPinnedPost = false; // データのロード中フラグをfalseに設定
      });
    }
  }

  Future<void> _fetchPostList() async {
    setState(() {
      _loading = true; // データのロード中フラグをtrueに設定
    });
    PostListResponse postListResponse =
    await PostListResponse.fetchYalkerPostResponse(widget.userNumber, _page);
    if (mounted) {
      setState(() {
        _postList.addAll(postListResponse.postList); // 新しいデータをリストに追加
        _loading = false; // データのロード中フラグをfalseに設定
      });
    }
  }

  Future<void> _loadMoreData() async {
    if (!_loading) {
      setState(() {
        _loading = true; // データのロード中フラグをtrueに設定
        _page++; // ページ番号をインクリメントして新しいデータを取得
      });
      await _fetchPostList();
    }
  }

  Future<void> _clearCache() async {
    try {
      setState(() {
        _postList.clear();
        _page = 1; // ページ番号をリセット
      });
      //print("list refresh");
      await _fetchPostList(); // データを再読み込み
    } catch (error) {
      //print('Error clearing cache: $error');
    }
  }

  Future<void> _fetchProfileData() async {
    try {
      final Map<String, dynamic> response =
      await httpGet('yalker-profile/${widget.userNumber}', jwt: true);
      setState(() {
        print(response);
        _profileData = response;
      });
    } catch (error) {
      print('Error fetching profile data: $error');
    }
  }

  Future<void> _fetchReportList() async {
    setState(() {
      _loadingReportList = true;
    });
    ReportListResponse reportListResponse =
    await ReportListResponse.fetchReportListResponse(widget.userNumber);
    if (mounted) {
      setState(() {
        reportListResponse.reportList.forEach((report) => {
          if (report.reportType == 4)
            {_reportListMap['bool_report_list']?.add(report)}
          else
            {_reportListMap['num_report_list']?.add(report)}
        });
        _loadingReportList = false;
      });
    }
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEditPage(profileData: _profileData!),
      ),
    );
  }

  void _showExplanation(BuildContext context, String explanation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('説明'),
          content: Text(explanation),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  void _onPressedButton() {
    setState(() {
      switch (relationType) {
        case 1:
          relationType++;
          break;
        case 2:
          relationType--;
          break;
        case 3:
          relationType++;
          break;
        case 4:
          relationType--;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('yalker投稿一覧'),
        ),
        body:
        RefreshIndicator(
          displacement: 0,
          onRefresh: () async {
            _clearCache();
          },
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  controller: _scrollController, // スクロールコントローラーを設定
                  itemCount: _postList.length + 1, // リストアイテム数 + ローディングインジケーター
                  itemBuilder: (context, index) {
                    if (index == _postList.length) {
                      return _loading
                          ? Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(16.0),
                        child: const CircularProgressIndicator(
                          strokeWidth: 3.0,
                        ),
                      )
                          : const SizedBox.shrink(); // ローディングインジケーターを表示
                    }
                    final post = _postList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          PostWidget(post: post),
                          if (index != _postList.length - 1)
                            const Divider(
                                height: 4.0,
                                thickness: 0.3,
                                color: Color(0xFF929292)), // 最後のポストの後には区切り線を表示しない
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
    );
  }
}
