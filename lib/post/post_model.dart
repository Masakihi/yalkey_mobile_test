import '../api.dart';

// ProgressとUserRepostの型定義
class Progress {
  final int reportType;
  final String reportTitle;
  final int reportNumber;
  final bool progressTodo;
  final int progressHours;
  final int progressMinutes;
  final int progressCustomData;
  final double progressCustomFloatData;
  final String progressUnit;
  final String progressDate;
  late DateTime progressDateTime;
  late Duration progressDuration;

  Progress({
    required this.reportType,
    required this.reportTitle,
    required this.reportNumber,
    required this.progressTodo,
    required this.progressHours,
    required this.progressMinutes,
    required this.progressCustomData,
    required this.progressCustomFloatData,
    required this.progressUnit,
    required this.progressDate,
  })  : progressDateTime = DateTime.parse(progressDate),
        progressDuration =
            Duration(hours: progressHours, minutes: progressMinutes);

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      reportType: json['report_type'],
      reportTitle: json['report_title'],
      reportNumber: json['report_number'],
      progressTodo: json['progress_todo'] as bool,
      progressHours: json['progress_hours'],
      progressMinutes: json['progress_minutes'],
      progressCustomData: json['progress_custom_data'],
      progressCustomFloatData: json['progress_custom_float_data'],
      progressUnit: json['progress_unit'],
      progressDate: json['progress_date'],
    );
  }

  factory Progress.fromJson2(Map<String, dynamic> json) {
    return Progress(
      reportType: json['report_type'],
      reportTitle: json['report_title'],
      reportNumber: json['report_number'],
      progressTodo: json['todo'],
      progressHours: json['hours'],
      progressMinutes: json['minutes'],
      progressCustomData: json['custom_data'],
      progressCustomFloatData: json['custom_float_data'],
      progressUnit: json['unit'],
      progressDate: json['progress_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_type': reportType,
      'report_title': reportTitle,
      'report_number': reportNumber,
      'progress_todo': progressTodo,
      'progress_hours': progressHours,
      'progress_minutes': progressMinutes,
      'progress_custom_data': progressCustomData,
      'progress_custom_float_data': progressCustomFloatData,
      'progress_unit': progressUnit,
      'progress_date': progressDate,
    };
  }

  // 足し合わせるためのデータ抽出
  dynamic extractData() {
    switch (reportType) {
      case 0:
        return progressDuration;
      case 1:
        return;
      case 2:
        return progressCustomData;
      case 3:
        return progressCustomFloatData;
      case 4:
        return progressTodo;
    }
  }
}

class Post {
  final int postNumber;
  final PostUser postUser;
  final String? toPostUserId;
  final String? toPostUserName;
  final String postText;
  final List<Progress> progressList;
  final String postCreatedAt;
  int postLikeNumber;
  bool postLiked;
  bool postBookmarked;
  bool postReposted;
  bool? postPinned;
  final List<String> postImageList;
  final List<String> progressTextList;
  final int? isRepost;
  final String? repostDate;
  final String? repostUserId;
  final String? repostUserName;

  Post({
    required this.isRepost,
    required this.postUser,
    required this.toPostUserId,
    required this.toPostUserName,
    required this.repostDate,
    required this.repostUserId,
    required this.repostUserName,
    required this.postNumber,
    required this.postText,
    required this.progressList,
    required this.postCreatedAt,
    required this.postLikeNumber,
    required this.postLiked,
    required this.postBookmarked,
    required this.postReposted,
    required this.postPinned,
    required this.postImageList,
    required this.progressTextList,
  });

  Future<void> like() async {
    if (postLiked) {
      throw Exception('Post $postNumber is already liked.');
    } else {
      final response = await httpPost('like/$postNumber/', null, jwt: true);
      if (response['liked']) {
        postLiked = true;
        postLikeNumber++;
      } else {
        // throw Exception('Post $postNumber is already liked in backend.');
        postLiked = true;
        postLikeNumber++;
        await httpPost('like/$postNumber/', null, jwt: true);
      }
    }
  }

  Future<void> unlike() async {
    if (!postLiked) {
      throw Exception('Post $postNumber is already unliked.');
    } else {
      final response = await httpPost('like/$postNumber/', null, jwt: true);
      if (!response['liked']) {
        postLiked = false;
        postLikeNumber--;
      } else {
        // throw Exception('Post $postNumber is already unliked in backend.');
        postLiked = false;
        postLikeNumber--;
        await httpPost('like/$postNumber/', null, jwt: true);
      }
    }
  }

  Future<void> bookmark() async {
    if (postBookmarked) {
      throw Exception('Post $postNumber is already bookmarked.');
    } else {
      final response = await httpPost('bookmark/$postNumber/', null, jwt: true);
      if (response['bookmarked']) {
        postBookmarked = true;
      } else {
        // throw Exception('Post $postNumber is already bookmarked in backend.');
        postBookmarked = true;
        await httpPost('bookmark/$postNumber/', null, jwt: true);
      }
    }
  }

  Future<void> unbookmark() async {
    if (!postBookmarked) {
      throw Exception('Post $postNumber is already unbookmarked.');
    } else {
      final response = await httpPost('bookmark/$postNumber/', null, jwt: true);
      if (!response['bookmarked']) {
        postBookmarked = false;
      } else {
        // throw Exception('Post $postNumber is already unbookmarked in backend.');
        postBookmarked = false;
        await httpPost('bookmark/$postNumber/', null, jwt: true);
      }
    }
  }

  Future<void> repost() async {
    if (postReposted) {
      throw Exception('Post $postNumber is already reposted.');
    } else {
      final response = await httpPost('repost/$postNumber/', null, jwt: true);
      if (response['reposted']) {
        postReposted = true;
      } else {
        // throw Exception('Post $postNumber is already reposted in backend.');
        postReposted = true;
        await httpPost('repost/$postNumber/', null, jwt: true);
      }
    }
  }

  Future<void> unrepost() async {
    if (!postReposted) {
      throw Exception('Post $postNumber is already unreposted.');
    } else {
      final response = await httpPost('repost/$postNumber/', null, jwt: true);
      if (!response['reposted']) {
        postReposted = false;
      } else {
        // throw Exception('Post $postNumber is already unreposted in backend.');
        postReposted = false;
        await httpPost('repost/$postNumber/', null, jwt: true);
      }
    }
  }

  Future<void> delete() async {
    final response = await httpDelete('post/delete/$postNumber/', jwt: true);

    if (response != 204) {
      // エラーが発生した場合の処理
      throw Exception('Post $postNumber is already unreposted in backend.');
    }
  }

  Future<void> pin() async {
    await httpPost('pin/$postNumber/', {}, jwt: true);
    postPinned = true;
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    List<String> postImageList = [];
    List<Progress> progressList = [];
    List<String> progressTextList = [];
    if (json['progress_list'].length > 0) {
      var progressJsonList = json['progress_list'] as List;
      progressList = progressJsonList
          .map((progressJson) => Progress.fromJson(progressJson))
          .toList();
      progressTextList.addAll(_getProgressTextList(progressList));
    }

    if (json['post_image_list'] != null) {
      if (json['post_image_list'].length > 0) {
        var postImageJsonList = json["post_image_list"] as List;
        postImageList =
            postImageJsonList.map((postImage) => postImage.toString()).toList();
      }
    }

    return Post(
      postNumber: json['post_number'],
      postUser: PostUser.fromJson(json),
      toPostUserId: json['to_post_user_id'],
      toPostUserName: json['to_post_user_name'],
      postText: json['post_text'],
      progressList: progressList,
      postCreatedAt: json['post_created_at'],
      postLikeNumber: json['post_like_number'],
      postLiked: json['post_liked'],
      postBookmarked: json['post_bookmarked'],
      postReposted: json['post_reposted'],
      postPinned: json['post_pinned'],
      postImageList: postImageList,
      progressTextList: progressTextList,
      isRepost: json['is_repost'],
      repostDate: json['repost_date'],
      repostUserId: json['repost_user_id'],
      repostUserName: json['repost_user_name'],
    );
  }

  static List<String> _getProgressTextList(List<Progress> progressList) {
    List<String> progressTextList = [];
    for (var progress in progressList) {
      switch (progress.reportType) {
        case 0: // 時間型
          progressTextList.add(
              '${progress.reportTitle}:${progress.progressHours}時間${progress.progressMinutes}分 (${progress.progressDate})');
          break;
        case 1: // None
          break;
        case 2: // int
          progressTextList.add(
              '${progress.reportTitle}:${progress.progressCustomData}${progress.progressUnit} (${progress.progressDate})');
          break;
        case 3: // float
          progressTextList.add(
              '${progress.reportTitle}:${progress.progressCustomFloatData}${progress.progressUnit} (${progress.progressDate})');
          break;
        case 4: // bool
          progressTextList.add(
              '${progress.reportTitle}:${progress.progressTodo ? '達成' : '未達成'} (${progress.progressDate})');
          break;
      }
    }
    return (progressTextList);
  }
}

class PostUser {
  final String postUserIcon;
  final int postUserNumber;
  final String postUserId;
  final String postUserName;
  final int? postUserProfileNumber;
  final bool? postUserPrivate;
  final bool? postUserSuperHardWorker;
  final bool? postUserHardWorker;
  final bool? postUserRegularCustomer;
  final bool? postUserSuperEarlyBird;
  final bool? postUserEarlyBird;

  PostUser({
    required this.postUserIcon,
    required this.postUserNumber,
    required this.postUserId,
    required this.postUserName,
    required this.postUserProfileNumber,
    required this.postUserPrivate,
    required this.postUserSuperHardWorker,
    required this.postUserHardWorker,
    required this.postUserRegularCustomer,
    required this.postUserSuperEarlyBird,
    required this.postUserEarlyBird,
  });

  factory PostUser.fromJson(Map<String, dynamic> json) {
    return PostUser(
      postUserIcon: json['post_user_icon'],
      postUserNumber: json['post_user_number'],
      postUserId: json['post_user_id'],
      postUserName: json['post_user_name'],
      postUserProfileNumber: json['post_user_profile_number'],
      postUserPrivate: json['post_user_private'],
      postUserSuperHardWorker: json['post_user_super_hard_worker'],
      postUserHardWorker: json['post_user_hard_worker'],
      postUserRegularCustomer: json['post_user_regular_customer'],
      postUserSuperEarlyBird: json['post_user_super_early_bird'],
      postUserEarlyBird: json['post_user_early_bird'],
    );
  }
}

// Postリストのレスポンスモデル
class PostListResponse {
  final List<Post> postList;

  PostListResponse({required this.postList});

  factory PostListResponse.fromResponseUserRepostList(
      Map<String, dynamic> json) {
    List<Post> postList = [];
    if (json['user_repost_list'] != null) {
      var postJsonList = json['user_repost_list'] as List;
      postList = postJsonList.map((post) => Post.fromJson(post)).toList();
    }
    return PostListResponse(postList: postList);
  }

  factory PostListResponse.fromResponseYalkerRepostList(
      Map<String, dynamic> json) {
    List<Post> postList = [];
    List<Post> pinnedPostList = [];
    if (json['pinned_repost_list'] != null) {
      var pinnedPostJsonList = json['pinned_repost_list'] as List;
      pinnedPostList =
          pinnedPostJsonList.map((post) => Post.fromJson(post)).toList();
    }
    if (json['repost_list'] != null) {
      var postJsonList = json['repost_list'] as List;
      postList = postJsonList.map((post) => Post.fromJson(post)).toList();
    }
    postList = pinnedPostList + postList;
    return PostListResponse(postList: postList);
  }

  factory PostListResponse.fromResponseYalkerPinnedRepostList(
      Map<String, dynamic> json) {
    List<Post> postList = [];
    if (json['pinned_repost_list'] != null) {
      var postJsonList = json['pinned_repost_list'] as List;
      postList = postJsonList.map((post) => Post.fromJson(post)).toList();
    }
    return PostListResponse(postList: postList);
  }

  static Future<PostListResponse> fetchPostListResponse(int page) async {
    dynamic jsonData = await httpGet('home/$page', jwt: true);
    // print(jsonData);
    return PostListResponse.fromResponseUserRepostList(jsonData);
  }

  factory PostListResponse.fromResponsePostList(Map<String, dynamic> json) {
    List<Post> postList = [];
    if (json['post_list'] != null) {
      var postJsonList = json['post_list'] as List;
      postList = postJsonList.map((post) => Post.fromJson(post)).toList();
    }
    return PostListResponse(postList: postList);
  }

  static Future<PostListResponse> fetchSearchPostResponse(
      int page, String keyword) async {
    // URLエンコードされたクエリを生成
    String encodedKeyword = Uri.encodeQueryComponent(keyword);
    dynamic jsonData = await httpGet(
        'search-list/${page}/?keyword=${encodedKeyword}',
        jwt: true);
    return PostListResponse.fromResponsePostList(jsonData);
  }

  static Future<PostListResponse> fetchBookmarkPostResponse(int page) async {
    dynamic jsonData = await httpGet('user-bookmark/$page', jwt: true);
    return PostListResponse.fromResponsePostList(
        jsonData['user_bookmark_list'][0]);
  }

  static Future<PostListResponse> fetchAllPostResponse(int page) async {
    dynamic jsonData = await httpGet('latest-post/${page}', jwt: true);
    return PostListResponse.fromResponseUserRepostList(jsonData);
  }

  static Future<PostListResponse> fetchYalkerPostResponse(
      int userNumber, int page) async {
    dynamic jsonData = await httpGet(
        'yalker-detail-repost-list/${userNumber}/${page}',
        jwt: true);
    return PostListResponse.fromResponseYalkerRepostList(jsonData);
  }

  static Future<PostListResponse> fetchYalkerPinnedPostResponse(
      int userNumber, int page) async {
    dynamic jsonData = await httpGet(
        'yalker-detail-repost-list/${userNumber}/${page}',
        jwt: true);
    return PostListResponse.fromResponseYalkerPinnedRepostList(jsonData);
  }
}

// PostDetailPage用レスポンスモデル
class PostDetailResponse {
  final Post post;
  final Post? toPost;
  final List<Post> replyList;

  PostDetailResponse({
    required this.post,
    required this.toPost,
    required this.replyList,
  });

  factory PostDetailResponse.fromJson(Map<String, dynamic> json) {
    Post? toPost = json['to_post_detail'] != null
        ? Post.fromJson(json['to_post_detail'])
        : null;
    if (json['reply_list'].isNotEmpty) {
      print(json['reply_list']
          .map((json) => {Post.fromJson(json) as Post})
          .toList());
    }
    if (json['reply_list'].isNotEmpty) {
      print(json['reply_list']
          .map((json) => {Post.fromJson(json) as Post})
          .toList()
          .runtimeType);
    }
    List<Post> replyList = json['reply_list'].isNotEmpty
        ? (json['reply_list'] as List<dynamic>)
            .map((json) => Post.fromJson(json as Map<String, dynamic>))
            .toList()
        : [];
    return PostDetailResponse(
        post: Post.fromJson(json['post_detail']),
        toPost: toPost,
        replyList: replyList);
  }

  static Future<PostDetailResponse> fetchPostDetailResponse(
      int postNumber) async {
    dynamic jsonData = await httpGet('detail/$postNumber', jwt: true);
    return PostDetailResponse.fromJson(jsonData);
  }
}
