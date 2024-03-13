import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'post_model.dart';
import 'post_widget.dart';

class PostDetailPage extends StatefulWidget {
  final int postNumber;

  const PostDetailPage({Key? key, required this.postNumber}) : super(key: key);

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  PostDetailResponse? _postDetailResponse;
  bool _isLoading = true;

  String? loginUserName;
  String? loginUserIconImage;
  String? loginUserId;
  int? loginUserNumber;

  @override
  void initState() {
    super.initState();
    _fetchPostDetail();
    _getLoginUserData();
  }

  Future<void> _fetchPostDetail() async {
    var postDetailResponse =
        await PostDetailResponse.fetchPostDetailResponse(widget.postNumber);
    setState(() {
      _postDetailResponse = postDetailResponse;
      _isLoading = false;
    });
  }

  Future<void> _getLoginUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _loginUserName = prefs.getString('login_user_name');
    var _loginUserIconImage = prefs.getString('login_user_iconimage');
    var _loginUserId = prefs.getString('login_user_id');
    var _loginUserNumber = prefs.getInt('login_user_number');
    setState(() => {
      loginUserName = _loginUserName,
      loginUserIconImage = _loginUserIconImage,
      loginUserId = _loginUserId,
      loginUserNumber = _loginUserNumber,
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('投稿詳細'),
        actions: [
          if (loginUserNumber==_postDetailResponse?.post.postUser.postUserNumber)
          IconButton(
            onPressed: () {
              if (_postDetailResponse != null) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('削除の確認'),
                      content: const Text('本当に削除してもよろしいですか？'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('キャンセル'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await _postDetailResponse!.post.delete();
                            setState(() => {});
                            Navigator.pop(context); // 投稿詳細画面を閉じる
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('投稿を削除しました')),
                            );
                          },
                          child: Text('削除'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            icon: const Icon(Icons.delete),
          ),
          if (loginUserNumber==_postDetailResponse?.post.postUser.postUserNumber)
          IconButton(
            onPressed: () async {
              if (_postDetailResponse != null) {
                await _postDetailResponse!.post.pin();
                setState(() => {});
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(_postDetailResponse!.post.postPinned!
                          ? '投稿をピン止めしました'
                          : 'ピン止めを解除しました')),
                );
              }
            },
            icon: Icon(
              _postDetailResponse != null
                  ? _postDetailResponse!.post.postPinned!
                      ? Icons.push_pin
                      : Icons.push_pin_outlined
                  : Icons.push_pin_outlined,
              color: _postDetailResponse != null
                  ? _postDetailResponse!.post.postPinned!
                      ? Colors.red
                      : Colors.grey
                  : Colors.grey,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _postDetailResponse != null
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PostWidget(post: _postDetailResponse!.post),
                      if (_postDetailResponse!.toPost != null)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(color: Colors.grey),
                            ),
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '返信先の投稿',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8.0), // 適宜間隔を設ける
                                PostWidget(post: _postDetailResponse!.toPost!),
                              ],
                            ),
                          ),
                        ),
                      const Divider(
                          height: 32.0, thickness: 1.0, color: Colors.grey),
                      _buildReplyList(_postDetailResponse!.replyList),
                    ],
                  ),
                )
              : const Center(child: Text('投稿の読み込みに失敗しました。')),
    );
  }

  Widget _buildReplyList(List<Post> replyList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            replyList.isNotEmpty ? '↓この投稿に対する返信' : '返信はありません。',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Column(
          children: replyList.map((reply) => PostWidget(post: reply)).toList(),
        ),
      ],
    );
  }
}
