import 'package:flutter/material.dart';
import '../profile/yalker_repost.dart';
import 'post_model.dart';
import 'post_detail_page.dart';
import 'reply_form.dart';
import 'linkify_util.dart';
import '../profile/yalker_profile_page.dart';
import 'post_image.dart';

const Map<String, String> badge2Explanation = {
  "超早起き": "過去1週間のうち7日間早起きしたヤルカー",
  "早起き": "過去1週間のうち3日間早起きしたヤルカー",
  "超努力家": "なんかめちゃくちゃ頑張ってるヤルカー",
  "努力家": "まあまあ頑張ってるヤルカー",
  "常連": "よく投稿する人",
};

class PostWidget extends StatefulWidget {
  final Post post;
  const PostWidget({Key? key, required this.post}) : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _liking = false;
  bool _bookmarking = false;
  bool _reposting = false;

  @override
  void initState() {
    super.initState();
  }

  void _showReplyForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 画面の9割を覆うようにする
      builder: (context) {
        return FractionallySizedBox(
          // 画面の9割の高さを調整
          heightFactor: 0.9,
          child: ReplyForm(postNumber: widget.post.postNumber),
        );
      },
    ).then((value) {
      // モーダルが閉じられた後の処理
      if (value == 'replyPosted') {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('返信しました')),
        );
      }
    });
  }

  Future<void> like() async {
    if (_liking) {
      return;
    }
    _liking = true;
    if (widget.post.postLiked) {
      await widget.post.unlike();
      setState(() {});
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('いいねを解除しました')),
      );
    } else {
      await widget.post.like();
      setState(() {});
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('いいねしました')),
      );
    }
    _liking = false;
  }

  Future<void> bookmark() async {
    if (_bookmarking) {
      return;
    }
    _bookmarking = true;
    if (widget.post.postBookmarked) {
      await widget.post.unbookmark();
      setState(() {});
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ブックマークを解除しました')),
      );
    } else {
      await widget.post.bookmark();
      setState(() {});
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ブックマークしました')),
      );
    }

    _bookmarking = false;
  }

  Future<void> _repost() async {
    if (_reposting) {
      return;
    }
    _reposting = true;
    if (widget.post.postReposted) {
      await widget.post.unrepost();
      setState(() {});
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('リポストを解除しました')),
      );
    } else {
      await widget.post.repost();
      setState(() {});
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('リポストしました')),
      );
    }
    _reposting = false;
  }

  void _navigateToPostDetailPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PostDetailPage(postNumber: widget.post.postNumber),
        ));
  }

  void _navigateToYalkerDetailPage(i) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => YalkerProfilePage(
              userNumber: widget.post.postUser.postUserNumber),
        ));
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          _navigateToPostDetailPage();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (widget.post.isRepost == 1)
                Row(
                  children: [
                    const Icon(
                      Icons.refresh,
                      color: Colors.grey,
                      size: 12.0,
                    ),
                    Text(
                      '${widget.post.repostUserName}さんがリポスト',
                      style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              if (widget.post.isRepost == 1) const SizedBox(height: 8.0),
              if (widget.post.postPinned == true)
                Row(
                  children: [
                    const Icon(
                      Icons.push_pin,
                      color: Colors.grey,
                      size: 12.0,
                    ),
                    Text(
                      'ピン留めされた投稿',
                      style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              if (widget.post.postPinned == true) const SizedBox(height: 8.0),
              if (widget.post.toPostUserName != null)
                Row(
                  children: [
                    const Icon(
                      Icons.reply,
                      color: Colors.grey,
                      size: 12.0,
                    ),
                    Text(
                      '${widget.post.toPostUserName}さんに対する返信',
                      style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              if (widget.post.toPostUserName != null)
                const SizedBox(height: 8.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      _navigateToYalkerDetailPage(
                          widget.post.postUser.postUserNumber);
                    },
                    child: widget.post.postUser.postUserIcon == ""
                        ? const CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(
                              'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/static/img/user.png',
                            ),
                          )
                        : CircleAvatar(
                            backgroundImage: NetworkImage(
                              'https://yalkey-s3.s3.ap-southeast-2.amazonaws.com/media/iconimage/${widget.post.postUser.postUserIcon}',
                            ),
                          ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.post.postUser.postUserName,
                          style: const TextStyle(fontSize: 18.0),
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            if (widget.post.postUser.postUserPrivate ?? false)
                              const Icon(
                                Icons.lock,
                                color: Colors.grey,
                                size: 12.0,
                              ),
                            Text(
                              '@${widget.post.postUser.postUserId} / ${widget.post.postCreatedAt.toString().substring(0, 10)} ${widget.post.postCreatedAt.toString().substring(11, 16)}',
                              style: const TextStyle(
                                  fontSize: 12.0, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            if (widget.post.postUser.postUserSuperEarlyBird ??
                                false)
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  _showExplanation(
                                      context, badge2Explanation['超早起き']!);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 3, vertical: 1),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFAE0103),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 3, vertical: 1),
                                      child: Text(
                                        "超早起き",
                                        style: TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (widget.post.postUser.postUserEarlyBird ??
                                false)
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  _showExplanation(
                                      context, badge2Explanation['早起き']!);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 3, vertical: 1),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFAE0103),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 3, vertical: 1),
                                      child: Text(
                                        "早起き",
                                        style: TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (widget.post.postUser.postUserSuperHardWorker ??
                                false)
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  _showExplanation(
                                      context, badge2Explanation['超努力家']!);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 3, vertical: 1),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFAE0103),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 3, vertical: 1),
                                      child: Text(
                                        "超努力家",
                                        style: TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (widget.post.postUser.postUserHardWorker ??
                                false)
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  _showExplanation(
                                      context, badge2Explanation['努力家']!);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 3, vertical: 1),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFAE0103),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 3, vertical: 1),
                                      child: Text(
                                        "努力家",
                                        style: TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (widget.post.postUser.postUserRegularCustomer ??
                                false)
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  _showExplanation(
                                      context, badge2Explanation['常連']!);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 3, vertical: 1),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFAE0103),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 3, vertical: 1),
                                      child: Text(
                                        "常連",
                                        style: TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        widget.post.postText != ''
                            ? LinkifyUtil(text: widget.post.postText)
                            : const SizedBox.shrink(),
                        const SizedBox(height: 8.0),
                        ...widget.post.progressTextList
                            .map((progressText) => Text("$progressText",
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  //fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  //decoration: TextDecoration.underline,
                                )))
                            .toList(),
                        ImageDisplay(
                          imageURLs: widget.post.postImageList,
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {
                      _showReplyForm();
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
                          like();
                        },
                        icon: Icon(
                          widget.post.postLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.post.postLiked
                              ? const Color(0xFFF75D5D)
                              : const Color(0xFF929292), // 赤色にするかどうか
                        ),
                      ),
                      Text(
                        '${widget.post.postLikeNumber}', // いいね数を表示
                        style: TextStyle(
                          fontSize: 16.0,
                          color: widget.post.postLiked
                              ? const Color(0xFFF75D5D)
                              : const Color(0xFF929292),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      bookmark();
                    },
                    icon: Icon(
                        widget.post.postBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: widget.post.postBookmarked
                            ? const Color.fromRGBO(255, 196, 67, 1)
                            : const Color(0xFF929292)),
                  ),
                  IconButton(
                    onPressed: () {
                      _repost();
                    },
                    icon: Icon(Icons.refresh,
                        color: widget.post.postReposted
                            ? const Color.fromRGBO(102, 205, 170, 1)
                            : const Color(0xFF929292)),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
