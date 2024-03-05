import 'package:flutter/material.dart';
import 'constant.dart';
import 'api.dart';
import 'linkify_util.dart';
import 'reply_form.dart';
import 'dart:convert';
import 'yalker_profile_page.dart';


class PostDetailPage extends StatefulWidget {
  final int postNumber;

  const PostDetailPage({Key? key, required this.postNumber}) : super(key: key);

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  PostDetailResponse? _postDetailResponse;
  bool _isLoading = true;
  bool _isPinned = false;
  bool _liking = false;
  bool _bookmarking = false;
  bool _reposting = false;

  @override
  void initState() {
    super.initState();
    _fetchPostDetail();
  }


  void _showReplyForm(int postNumber) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 画面の9割を覆うようにする
      builder: (context) {
        return FractionallySizedBox(
          // 画面の9割の高さを調整
          heightFactor: 0.9,
          child: ReplyForm(postNumber: postNumber),
        );
      },
    ).then((value) {
      // モーダルが閉じられた後の処理
      if (value == 'replyPosted') {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('返信しました')),
        );
      }
    });
  }

  Future<void> _fetchPostDetail() async {
    var postDetailResponse =
        await PostDetailResponse.fetchPostDetailResponse(widget.postNumber);
    setState(() {
      _postDetailResponse = postDetailResponse;
      _isPinned = _postDetailResponse!.postDetail.postPinned;
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

  void _navigateToYalkerDetailPage(int userId) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => YalkerProfilePage(userId: userId),
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

  Future<void> _togglePin(int postNumber) async {
    final response = await httpPost('pin/$postNumber/', {}, jwt: true);

    setState(() {
      _isPinned = !_isPinned; // ピン止めの状態を反転させる
    });

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isPinned ? '投稿をピン止めしました' : 'ピン止めを解除しました')),
    );
  }

  Future<void> like(PostDetail repost) async {
    if (_liking) {
      return;
    }
    _liking = true;
    if (repost.postLiked) {
      await repost.unlike();
      setState(() {});
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('いいねを解除しました')),
      );
    } else {
      await repost.like();
      setState(() {});
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('いいねしました')),
      );
    }
    _liking = false;
  }

  Future<void> bookmark(PostDetail repost) async {
    if (_bookmarking) {
      return;
    }
    _bookmarking = true;
    if (repost.postBookmarked) {
      await repost.unbookmark();
      setState(() {});
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ブックマークを解除しました')),
      );
    } else {
      await repost.bookmark();
      setState(() {});
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ブックマークしました')),
      );
    }
    _bookmarking = false;
  }

  Future<void> _repost(PostDetail repost) async {
    if (_reposting) {
      return;
    }
    _reposting = true;
    if (repost.postReposted) {
      await repost.unrepost();
      setState(() {});
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('リポストを解除しました')),
      );
    } else {
      await repost.repost();
      setState(() {});
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('リポストしました')),
      );
    }
    _reposting = false;
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
          IconButton(
            onPressed: () {
              if (_postDetailResponse != null) {
                _togglePin(_postDetailResponse!.postDetail.postNumber);
              }
            },
            icon: Icon(
              _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _isPinned ? Colors.red : Colors.grey,
            ),
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
        // _navigateToPostDetailPage(post.postNumber);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    _navigateToYalkerDetailPage(
                        post.postUserNumber);
                  },
                  child: post.postUserIcon == ""
                      ? const CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(
                      'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/static/img/user.png',
                    ),
                  )
                      : CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/media/iconimage/${post.postUserIcon}',
                    ),
                  ),
                ),
                /*
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/media/iconimage/${post.postUserIcon}',
                  ),
                ),
                 */
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
                          ? LinkifyUtil(text: post.postText)
                          : SizedBox.shrink(),
                      SizedBox(height: 4.0),
                      ...post.progressTextList
                          .map((progressText) => Text("・" + progressText,
                              style: TextStyle(
                                  fontSize: 12.0, fontWeight: FontWeight.bold)))
                          .toList(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            onPressed: () {
                              _showReplyForm(post.postNumber);
                            },
                            icon: const Icon(
                              Icons.reply,
                              color: Color(0xFF929292),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  like(post);
                                },
                                icon: Icon(
                                  post.postLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: post.postLiked
                                      ? const Color(0xFFF75D5D)
                                      : const Color(0xFF929292), // 赤色にするかどうか
                                ),
                              ),
                              Text(
                                '${post.postLikeNumber}', // いいね数を表示
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: post.postLiked
                                      ? const Color(0xFFF75D5D)
                                      : const Color(0xFF929292),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              bookmark(post);
                            },
                            icon: Icon(
                                post.postBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: post.postBookmarked
                                    ? const Color.fromRGBO(255, 196, 67, 1)
                                    : const Color(0xFF929292)),
                          ),
                          IconButton(
                            onPressed: () {
                              _repost(post);
                            },
                            icon: Icon(Icons.refresh,
                                color: post.postReposted
                                    ? const Color.fromRGBO(102, 205, 170, 1)
                                    : const Color(0xFF929292)),
                          ),
                        ],
                      ),
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
