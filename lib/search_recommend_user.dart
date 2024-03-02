import 'package:flutter/material.dart';
import 'constant.dart';
import 'search_post.dart';
import 'search_user.dart';
import 'search_user_id.dart';

class SearchRecommendUserListPage extends StatefulWidget {
  const SearchRecommendUserListPage({Key? key}) : super(key: key);

  @override
  _SearchRecommendUserListPageState createState() => _SearchRecommendUserListPageState();
}

class _SearchRecommendUserListPageState extends State<SearchRecommendUserListPage> {
  late List<User> _userList = []; // user_repost_list を格納するリスト
  late ScrollController _scrollController; // ListView のスクロールを制御するコントローラー
  bool _loading = false; // データをロード中かどうかを示すフラグ
  int _page = 1; // 現在のページ番号

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _fetchRecommendUserList(); // 最初のデータを読み込む
  }

  // ListView のスクロールイベントを監視するリスナー
  void _scrollListener() {
    // スクロール位置が最下部に達したかどうかをチェック
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // 最下部に達したら新しいデータをロードする
      // _loadMoreData();
    }
  }

  Future<void> _fetchRecommendUserList() async {
    setState(() {
      _loading = true; // データのロード中フラグをtrueに設定
    });

    RecommendUserListResponse recommendUserListResponse =
    await RecommendUserListResponse.fetchRecommendUserListResponse();
    if (mounted) {
      setState(() {
        _userList
            .addAll(recommendUserListResponse.recommendUserList); // 新しいデータをリストに追加
        _loading = false; // データのロード中フラグをfalseに設定
      });
    }
    /*prefs.setStringList('user_repost_list',
        _userRepostList.map((repost) => jsonEncode(repost.toJson())).toList());

     */
  }

  Future<void> _loadMoreData() async {
    if (!_loading) {
      setState(() {
        _loading = true; // データのロード中フラグをtrueに設定
        _page++; // ページ番号をインクリメントして新しいデータを取得
      });
      await _fetchRecommendUserList();
    }
  }

  Future<void> _clearCache() async {
    try {
      //SharedPreferences prefs = await SharedPreferences.getInstance();
      //await prefs.remove('user_repost_list');
      setState(() {
        _userList.clear();
        _page = 1; // ページ番号をリセット
      });
      print("list refresh");
      await _fetchRecommendUserList(); // データを再読み込み
    } catch (error) {
      print('Error clearing cache: $error');
    }
  }


  @override
  Widget build(BuildContext context) {

    Widget searchTextField() {
      return TextField(
        onSubmitted: (value) {
          print(value);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchUserListPage(keyword:value),
            ),
          );
        },
        autofocus: true, //TextFieldが表示されるときにフォーカスする（キーボードを表示する）
        //cursorColor: Colors.white, //カーソルの色
        style: TextStyle( //テキストのスタイル
          //color: Colors.white,
          fontSize: 20,
        ),
        textInputAction: TextInputAction.search, //キーボードのアクションボタンを指定
        decoration: InputDecoration( //TextFiledのスタイル
          enabledBorder: UnderlineInputBorder( //デフォルトのTextFieldの枠線
              borderSide: BorderSide(color: Colors.grey)
          ),
          focusedBorder: UnderlineInputBorder( //TextFieldにフォーカス時の枠線
              borderSide: BorderSide(color: Colors.grey)
          ),
          hintText: 'Search', //何も入力してないときに表示されるテキスト
          hintStyle: TextStyle( //hintTextのスタイル
            //color: Colors.grey,
            fontSize: 18,
          ),
        ),
      );
    }


    return Scaffold(
      appBar: AppBar(
        title: searchTextField(),
      ),
      body:Column(
        children: <Widget>[
            !_loading ? const SizedBox(height: 20.0)
              : const SizedBox.shrink(),
            !_loading ? Container(
                alignment: Alignment.centerLeft, //任意のプロパティ
                width: double.infinity,
                child: const Text(
                  'おすすめのユーザー',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 20.0),
                )
            )
            : const SizedBox.shrink(),
            !_loading ? const SizedBox(height: 10.0)
              : const SizedBox.shrink(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController, // スクロールコントローラーを設定
                itemCount: _userList.length + 1, // リストアイテム数 + ローディングインジケーター
                itemBuilder: (context, index) {
                  if (index == _userList.length) {
                    return _loading
                        ? Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 3.0,
                      ),
                    )
                        : SizedBox.shrink(); // ローディングインジケーターを表示
                  }
                  final user = _userList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          onTap: (){
                            print("tap");
                          },
                          child:Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              if (user.iconimage=="") const CircleAvatar(
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage(
                                  'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/static/img/user.png',
                                ),
                              ),
                              if (user.iconimage!="") CircleAvatar(
                                backgroundImage: NetworkImage(
                                  'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/media/iconimage/${user.iconimage}',
                                ),
                              ),
                              SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      user.name ?? '???',
                                      style: const TextStyle(fontSize: 20.0),
                                    ),
                                    Row(
                                      children: [
                                        if (user.private ?? false) const Icon(
                                          Icons.lock,
                                          color: Colors.grey,
                                          size: 12.0,
                                        ),
                                        Text(
                                          '@${user.userId}',
                                          style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.0),
                                    Row(
                                      children: [
                                        if (user.superEarlyBird ?? false) Padding(
                                          padding: const EdgeInsets.symmetric(horizontal:3, vertical: 1),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFAE0103),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal:3, vertical: 1),
                                              child: Text(
                                                "超早起き",
                                                style: TextStyle(fontSize: 10.0, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (user.superEarlyBird ?? false) Padding(
                                          padding: const EdgeInsets.symmetric(horizontal:3, vertical: 1),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFAE0103),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal:3, vertical: 1),
                                              child: Text(
                                                "早起き",
                                                style: TextStyle(fontSize: 10.0, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (user.superHardWorker ?? false) Padding(
                                          padding: const EdgeInsets.symmetric(horizontal:3, vertical: 1),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFAE0103),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal:3, vertical: 1),
                                              child: Text(
                                                "超努力家",
                                                style: TextStyle(fontSize: 10.0, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (user.hardWorker ?? false) Padding(
                                          padding: const EdgeInsets.symmetric(horizontal:3, vertical: 1),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFAE0103),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal:3, vertical: 1),
                                              child: Text(
                                                "努力家",
                                                style: TextStyle(fontSize: 10.0, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (user.regularCustomer ?? false) Padding(
                                          padding: const EdgeInsets.symmetric(horizontal:3, vertical: 1),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFAE0103),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal:3, vertical: 1),
                                              child: Text(
                                                "常連",
                                                style: TextStyle(fontSize: 10.0, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    user.profile != ''
                                        ? Text(
                                      user.profile ?? '',
                                      style: TextStyle(fontSize: 14.0),
                                    )
                                        : SizedBox.shrink(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
    );
  }
}
