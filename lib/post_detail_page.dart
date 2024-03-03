import 'package:flutter/material.dart';
import 'constant.dart';
import 'api.dart';

class PostDetailPage extends StatefulWidget {
  final int postNumber;

  const PostDetailPage({Key? key, required this.postNumber}) : super(key: key);

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  PostDetailResponse? _postDetailResponse;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPostDetail();
  }

  Future<void> _fetchPostDetail() async {
    var postDetailResponse =
        await PostDetailResponse.fetchPostDetailResponse(widget.postNumber);
    setState(() {
      _postDetailResponse = postDetailResponse;
      _isLoading = false;
    });
  }

  void _navigateToPostDetailPage(int postNumber) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostDetailPage(postNumber: postNumber),
        ));
  }

  Future<void> _deletePost(int postNumber) async {
    final response = await httpDelete('post/delete/$postNumber/', jwt: true);

    if (response == 204) {
      // 投稿が削除された場合の処理
      Navigator.pop(context); // 投稿詳細画面を閉じる
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('投稿を削除しました')),
      );
    } else {
      // エラーが発生した場合の処理
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('投稿の削除に失敗しました')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('投稿詳細'),
        actions: [
          IconButton(
            onPressed: () {
              if (_postDetailResponse != null) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('削除の確認'),
                      content: Text('本当に削除してもよろしいですか？'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('キャンセル'),
                        ),
                        TextButton(
                          onPressed: () {
                            _deletePost(
                                _postDetailResponse!.postDetail.postNumber);
                          },
                          child: Text('削除'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _postDetailResponse != null
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPostWidget(_postDetailResponse!.postDetail),
                      if (_postDetailResponse!.toPostDetail != null)
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
                                Text(
                                  '元の投稿',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8.0), // 適宜間隔を設ける
                                _buildPostWidget(
                                    _postDetailResponse!.toPostDetail!),
                              ],
                            ),
                          ),
                        ),
                      Divider(height: 32.0, thickness: 1.0, color: Colors.grey),
                      _buildReplyList(_postDetailResponse!.replyList),
                    ],
                  ),
                )
              : Center(child: Text('投稿の読み込みに失敗しました。')),
    );
  }

  Widget _buildPostWidget(PostDetail post) {
    return InkWell(
      onTap: () {
        // ポストの詳細画面に遷移する処理を追加する
        _navigateToPostDetailPage(post.postNumber);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/media/iconimage/${post.postUserIcon}',
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        post.postUserName,
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        '@${post.postUserId} / ${post.postCreatedAt.toString().substring(0, 10)} ${post.postCreatedAt.toString().substring(11, 16)}',
                        style: TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                      SizedBox(height: 8.0),
                      post.postText != ''
                          ? Text(
                              post.postText,
                              style: TextStyle(fontSize: 16.0),
                            )
                          : SizedBox.shrink(),
                      SizedBox(height: 4.0),
                      ...post.progressTextList
                          .map((progressText) => Text("・" + progressText,
                              style: TextStyle(
                                  fontSize: 12.0, fontWeight: FontWeight.bold)))
                          .toList(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyList(List<PostDetail> replyList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            replyList.isNotEmpty ? '↓この投稿に対する返信' : '返信はありません。',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Column(
          children: replyList.map((reply) => _buildPostWidget(reply)).toList(),
        ),
      ],
    );
  }
}
