import 'api.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      reportType: json['report_type'],
      reportTitle: json['report_title'],
      reportNumber: json['report_number'],
      progressTodo: json['progress_todo'],
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
}

class UserRepost {
  final int isRepost;
  final String repostDate;
  final String repostUserId;
  final String repostUserName;
  final String postUserIcon;
  final int postUserNumber;
  final String postUserId;
  final String postUserName;
  final String? toPostUserId;
  final String? toPostUserName;
  final int? postUserProfileNumber;
  final bool? postUserPrivate;
  final bool? postUserSuperHardWorker;
  final bool? postUserHardWorker;
  final bool? postUserRegularCustomer;
  final bool? postUserSuperEarlyBird;
  final bool? postUserEarlyBird;
  final int postNumber;
  final String postText;
  final List<Progress> progressList;
  final String postCreatedAt;
  int postLikeNumber;
  bool postLiked;
  bool postBookmarked;
  bool postReposted;
  // bool postPinned;
  // final List<String> postImageList;
  final List<String> progressTextList;

  UserRepost({
    required this.isRepost,
    required this.repostDate,
    required this.repostUserId,
    required this.repostUserName,
    required this.postUserIcon,
    required this.postUserNumber,
    required this.postUserId,
    required this.postUserName,
    required this.toPostUserId,
    required this.toPostUserName,
    required this.postUserProfileNumber,
    required this.postUserPrivate,
    required this.postUserSuperHardWorker,
    required this.postUserHardWorker,
    required this.postUserRegularCustomer,
    required this.postUserSuperEarlyBird,
    required this.postUserEarlyBird,
    required this.postNumber,
    required this.postText,
    required this.progressList,
    required this.postCreatedAt,
    required this.postLikeNumber,
    required this.postLiked,
    required this.postBookmarked,
    required this.postReposted,
    // required this.postPinned,
    // required this.postImageList,
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
        throw Exception('Post $postNumber is already liked in backend.');
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
        throw Exception('Post $postNumber is already unliked in backend.');
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
        throw Exception('Post $postNumber is already bookmarked in backend.');
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
        throw Exception('Post $postNumber is already unbookmarked in backend.');
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
        throw Exception('Post $postNumber is already reposted in backend.');
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
        throw Exception('Post $postNumber is already unreposted in backend.');
      }
    }
  }

  factory UserRepost.fromJson(Map<String, dynamic> json) {
    List<Progress> progressList = [];
    List<String> progressTextList = [];
    List<String> postImageList = [];
    // print(json);
    // print(a.runtimeType);
    // print(a.length);
    if (json['progress_list'].length > 0) {
      // print('-------------------');
      // print(json['progress_list']);
      var progressJsonList = json['progress_list'] as List;
      progressList = progressJsonList
          .map((progressJson) => Progress.fromJson(progressJson))
          .toList();
      // print(_getProgressTextList(progressList));
      progressTextList.addAll(_getProgressTextList(progressList));
      // print(progressTextList);
    }
    return UserRepost(
      //dateReposted: json['repost_date'],
      isRepost: json['is_repost'],
      repostDate: json['repost_date'],
      repostUserId: json['repost_user_id'],
      repostUserName: json['repost_user_name'],
      postUserIcon: json['post_user_icon'],
      postUserNumber: json['post_user_number'],
      postUserId: json['post_user_id'],
      postUserName: json['post_user_name'],
      toPostUserId: json['to_post_user_id'],
      toPostUserName: json['to_post_user_name'],
      postUserProfileNumber: json['post_user_profile_number'],
      postUserPrivate: json['post_user_private'],
      postUserSuperHardWorker: json['post_user_super_hard_worker'],
      postUserHardWorker: json['post_user_hard_worker'],
      postUserRegularCustomer: json['post_user_regular_customer'],
      postUserSuperEarlyBird: json['post_user_super_early_bird'],
      postUserEarlyBird: json['post_user_early_bird'],
      postNumber: json['post_number'],
      postText: json['post_text'],
      progressList: progressList,
      postCreatedAt: json['post_created_at'],
      postLikeNumber: json['post_like_number'],
      postLiked: json['post_liked'],
      postBookmarked: json['post_bookmarked'],
      postReposted: json['post_reposted'],
      // postPinned: json['post_pinned'],
      // postImageList: json['post_image_list'],
      progressTextList: progressTextList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'date_reposted': dateReposted,
      //'repost_date': dateReposted,
      'is_repost': isRepost,
      'repost_date': repostDate,
      'repost_user_id': repostUserId,
      'repost_user_name': repostUserName,
      'post_user_icon': postUserIcon,
      'post_user_number': postUserNumber,
      'post_user_id': postUserId,
      'post_user_name': postUserName,
      'to_post_user_id': toPostUserId,
      'to_post_user_name': toPostUserName,
      'post_user_profile_number': postUserProfileNumber,
      'post_user_private': postUserPrivate,
      'post_user_super_hard_worker': postUserSuperHardWorker,
      'post_user_hard_worker': postUserHardWorker,
      'post_user_regular_customer': postUserRegularCustomer,
      'post_user_super_early_bird': postUserSuperEarlyBird,
      'post_user_early_bird': postUserEarlyBird,
      'post_number': postNumber,
      'post_text': postText,
      'progress_list':
          progressList.map((progress) => progress.toJson()).toList(),
      'post_created_at': postCreatedAt,
      'post_like_number': postLikeNumber,
      'post_liked': postLiked,
      'post_bookmarked': postBookmarked,
      'post_reposted': postReposted,
      // 'post_pinned': postPinned,
      // 'post_image_list': postImageList,
      'progress_text_list': progressTextList
    };
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

class UserRepostListResponse {
  final List<UserRepost> userRepostList;

  UserRepostListResponse({required this.userRepostList});

  factory UserRepostListResponse.fromJson(Map<String, dynamic> json) {
    List<UserRepost> userRepostList = [];
    if (json['user_repost_list'] != null) {
      var userRepostJsonList = json['user_repost_list'] as List;
      userRepostList = userRepostJsonList
          .map((userRepost) => UserRepost.fromJson(userRepost))
          .toList();
    }
    return UserRepostListResponse(userRepostList: userRepostList);
  }

  static Future<UserRepostListResponse> fetchUserRepostListResponse(
      int page) async {
    dynamic jsonData = await httpGet('home/$page', jwt: true);
    print(jsonData);
    return UserRepostListResponse.fromJson(jsonData);
  }
}



class Post {
  final String postUserIcon;
  final int postUserNumber;
  final String postUserId;
  final String postUserName;
  final String? toPostUserId;
  final String? toPostUserName;
  final int? postUserProfileNumber;
  final bool? postUserPrivate;
  final bool? postUserSuperHardWorker;
  final bool? postUserHardWorker;
  final bool? postUserRegularCustomer;
  final bool? postUserSuperEarlyBird;
  final bool? postUserEarlyBird;
  final int postNumber;
  final String postText;
  final List<Progress> progressList;
  final String postCreatedAt;
  int postLikeNumber;
  bool postLiked;
  bool postBookmarked;
  bool postReposted;
  // bool postPinned;
  // final List<String> postImageList;
  final List<String> progressTextList;

  Post({
    required this.postUserIcon,
    required this.postUserNumber,
    required this.postUserId,
    required this.postUserName,
    required this.toPostUserId,
    required this.toPostUserName,
    required this.postUserProfileNumber,
    required this.postUserPrivate,
    required this.postUserSuperHardWorker,
    required this.postUserHardWorker,
    required this.postUserRegularCustomer,
    required this.postUserSuperEarlyBird,
    required this.postUserEarlyBird,
    required this.postNumber,
    required this.postText,
    required this.progressList,
    required this.postCreatedAt,
    required this.postLikeNumber,
    required this.postLiked,
    required this.postBookmarked,
    required this.postReposted,
    // required this.postPinned,
    // required this.postImageList,
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
        throw Exception('Post $postNumber is already liked in backend.');
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
        throw Exception('Post $postNumber is already unliked in backend.');
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
        throw Exception('Post $postNumber is already bookmarked in backend.');
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
        throw Exception('Post $postNumber is already unbookmarked in backend.');
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
        throw Exception('Post $postNumber is already reposted in backend.');
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
        throw Exception('Post $postNumber is already unreposted in backend.');
      }
    }
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    List<Progress> progressList = [];
    List<String> progressTextList = [];
    // print(json);
    // print(a.runtimeType);
    // print(a.length);
    if (json['progress_list'].length > 0) {
      // print('-------------------');
      // print(json['progress_list']);
      var progressJsonList = json['progress_list'] as List;
      progressList = progressJsonList
          .map((progressJson) => Progress.fromJson(progressJson))
          .toList();
      // print(_getProgressTextList(progressList));
      progressTextList.addAll(_getProgressTextList(progressList));
      // print(progressTextList);
    }
    return Post(
      postUserIcon: json['post_user_icon'],
      postUserNumber: json['post_user_number'],
      postUserId: json['post_user_id'],
      postUserName: json['post_user_name'],
      toPostUserId: json['to_post_user_id'],
      toPostUserName: json['to_post_user_name'],
      postUserProfileNumber: json['post_user_profile_number'],
      postUserPrivate: json['post_user_private'],
      postUserSuperHardWorker: json['post_user_super_hard_worker'],
      postUserHardWorker: json['post_user_hard_worker'],
      postUserRegularCustomer: json['post_user_regular_customer'],
      postUserSuperEarlyBird: json['post_user_super_early_bird'],
      postUserEarlyBird: json['post_user_early_bird'],
      postNumber: json['post_number'],
      postText: json['post_text'],
      progressList: progressList,
      postCreatedAt: json['post_created_at'],
      postLikeNumber: json['post_like_number'],
      postLiked: json['post_liked'],
      postBookmarked: json['post_bookmarked'],
      postReposted: json['post_reposted'],
      // postPinned: json['post_pinned'],
      // postImageList: json['post_image_list'],
      progressTextList: progressTextList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'post_user_icon': postUserIcon,
      'post_user_number': postUserNumber,
      'post_user_id': postUserId,
      'post_user_name': postUserName,
      'to_post_user_id': toPostUserId,
      'to_post_user_name': toPostUserName,
      'post_user_profile_number': postUserProfileNumber,
      'post_user_private': postUserPrivate,
      'post_user_super_hard_worker': postUserSuperHardWorker,
      'post_user_hard_worker': postUserHardWorker,
      'post_user_regular_customer': postUserRegularCustomer,
      'post_user_super_early_bird': postUserSuperEarlyBird,
      'post_user_early_bird': postUserEarlyBird,
      'post_number': postNumber,
      'post_text': postText,
      'progress_list':
      progressList.map((progress) => progress.toJson()).toList(),
      'post_created_at': postCreatedAt,
      'post_like_number': postLikeNumber,
      'post_liked': postLiked,
      'post_bookmarked': postBookmarked,
      'post_reposted': postReposted,
      // 'post_pinned': postPinned,
      // 'post_image_list': postImageList,
      'progress_text_list': progressTextList
    };
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

class PostListResponse {
  final List<Post> postList;

  PostListResponse({required this.postList});

  factory PostListResponse.fromJson(Map<String, dynamic> json) {
    List<Post> postList = [];
    if (json['post_list'] != null) {
      var postJsonList = json['post_list'] as List;
      postList = postJsonList
          .map((post) => Post.fromJson(post))
          .toList();
    }
    return PostListResponse(postList: postList);
  }

  static Future<PostListResponse> fetchSearchPostListResponse(
      int page) async {
    dynamic jsonData = await httpGet('search-list/$page', jwt: true);
    return PostListResponse.fromJson(jsonData);
  }
}



// Reportの型定義
class Report {
  final String reportName;
  final String reportUnit;
  final String graphType;
  final int reportType;
  final int userId;

  Report({
    required this.reportName,
    required this.reportUnit,
    required this.graphType,
    required this.reportType,
    required this.userId,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      reportName: json['report_name'],
      reportUnit: json['report_unit'],
      graphType: json["graph_type"],
      reportType: json['report_type'],
      userId: json['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_name': reportName,
      'report_unit': reportUnit,
      'graph_type': graphType,
      'report_type': reportType,
      'user': userId,
    };
  }
}

class ReportListResponse {
  final List<Report> reportList;

  ReportListResponse({required this.reportList});

  factory ReportListResponse.fromJson(Map<String, dynamic> json) {
    List<Report> reportList = [];
    if (json['yalker_report_list'] != null) {
      var reportJsonList = json['yalker_report_list'] as List;
      reportList =
          reportJsonList.map((report) => Report.fromJson(report)).toList();
    }
    return ReportListResponse(reportList: reportList);
  }

  static Future<ReportListResponse> fetchReportListResponse(int userId) async {
    dynamic jsonData = await httpGet('report-list/$userId', jwt: true);
    return ReportListResponse.fromJson(jsonData);
  }
}

// ProgressListの型定義
class YalkerProgressListResponse {
  final List<Progress> progressList;

  YalkerProgressListResponse({required this.progressList});

  factory YalkerProgressListResponse.fromJson(Map<String, dynamic> json) {
    List<Progress> progressList = [];
    if (json['yalker_progress_list'] != null) {
      var progressJsonList = json['yalker_progress_list'] as List;
      progressList = progressJsonList
          .map((progress) => Progress.fromJson2(progress))
          .toList();
    }
    return YalkerProgressListResponse(progressList: progressList);
  }

  static Future<YalkerProgressListResponse> fetchYalkerProgressListResponse(
      int userId, DateTime startDate, DateTime endDate) async {
    dynamic jsonData = await httpGet(
        'yalker-progress-list/$userId/${startDate.year}/${startDate.month}/${startDate.day}/${endDate.year}/${endDate.month}/${endDate.day}/1');
    print(jsonData);
    return YalkerProgressListResponse.fromJson(jsonData);
  }
}


// Connectionの型定義
class Connection {
  final String dateCreated;
  final int followerUserNumber;
  final String followerName;
  final String followerIconimage;
  final String followerUserId;
  final String followerProfile;
  final int followerProfileNumber;
  final bool followerPrivate;
  final bool followerSuperHardWorker;
  final bool followerHardWorker;
  final bool followerRegularCustomer;
  final bool followerSuperEarlyBird;
  final bool followerEarlyBird;
  final int followedUserNumber;
  final String followedName;
  final String followedIconimage;
  final String followedUserId;
  final String followedProfile;
  final int followedProfileNumber;
  final bool followedPrivate;
  final bool followedSuperHardWorker;
  final bool followedHardWorker;
  final bool followedRegularCustomer;
  final bool followedSuperEarlyBird;
  final bool followedEarlyBird;

  Connection({
    required this.dateCreated,
    required this.followerUserNumber,
    required this.followerName,
    required this.followerIconimage,
    required this.followerUserId,
    required this.followerProfile,
    required this.followerProfileNumber,
    required this.followerPrivate,
    required this.followerSuperHardWorker,
    required this.followerHardWorker,
    required this.followerRegularCustomer,
    required this.followerSuperEarlyBird,
    required this.followerEarlyBird,
    required this.followedUserNumber,
    required this.followedName,
    required this.followedIconimage,
    required this.followedUserId,
    required this.followedProfile,
    required this.followedProfileNumber,
    required this.followedPrivate,
    required this.followedSuperHardWorker,
    required this.followedHardWorker,
    required this.followedRegularCustomer,
    required this.followedSuperEarlyBird,
    required this.followedEarlyBird,
  });

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      dateCreated: json['date_created'],
      followerUserNumber: json['follower_user_number'],
      followerName: json['follower_name'],
      followerIconimage: json['follower_iconimage'],
      followerUserId: json['follower_user_id'],
      followerProfile: json['follower_profile'],
      followerProfileNumber: json['follower_profile_number'],
      followerPrivate: json['follower_private'],
      followerSuperHardWorker: json['follower_super_hard_worker'],
      followerHardWorker: json['follower_hard_worker'],
      followerRegularCustomer: json['follower_regular_customer'],
      followerSuperEarlyBird: json['follower_super_early_bird'],
      followerEarlyBird: json['follower_early_bird'],
      followedUserNumber: json['followed_user_number'],
      followedName: json['followed_name'],
      followedIconimage: json['followed_iconimage'],
      followedUserId: json['followed_user_id'],
      followedProfile: json['followed_profile'],
      followedProfileNumber: json['followed_profile_number'],
      followedPrivate: json['followed_private'],
      followedSuperHardWorker: json['followed_super_hard_worker'],
      followedHardWorker: json['followed_hard_worker'],
      followedRegularCustomer: json['followed_regular_customer'],
      followedSuperEarlyBird: json['followed_super_early_bird'],
      followedEarlyBird: json['followed_early_bird'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date_created': dateCreated,
      'follower_user_number': followerUserNumber,
      'follower_name': followerName,
      'follower_iconimage': followerIconimage,
      'follower_user_id': followerUserId,
      'follower_profile':followerProfile,
      'follower_profile_number': followerProfileNumber,
      'follower_private': followerPrivate,
      'follower_super_hard_worker': followerSuperHardWorker,
      'follower_hard_worker': followerHardWorker,
      'follower_regular_customer': followerRegularCustomer,
      'follower_super_early_bird': followerSuperEarlyBird,
      'follower_early_bird': followerEarlyBird,
      'followed_user_number': followedUserNumber,
      'followed_name': followedName,
      'followed_iconimage': followedIconimage,
      'followed_user_id': followedUserId,
      'followed_profile': followedProfile,
      'followed_profile_number': followedProfileNumber,
      'followed_private': followedPrivate,
      'followed_super_hard_worker': followedSuperHardWorker,
      'followed_hard_worker': followedHardWorker,
      'followed_regular_customer': followedRegularCustomer,
      'followed_super_early_bird': followedSuperEarlyBird,
      'followed_early_bird': followedEarlyBird,
    };
  }
}

class FollowingListResponse {
  final List<Connection> followingList;

  FollowingListResponse({required this.followingList});

  factory FollowingListResponse.fromJson(Map<String, dynamic> json) {
    List<Connection> followingList = [];
    if (json['following_list'] != null) {
      var followingJsonList = json['following_list'] as List;
      followingList =
          followingJsonList.map((connection) => Connection.fromJson(connection)).toList();
    }
    return FollowingListResponse(followingList: followingList);
  }

  static Future<FollowingListResponse> fetchFollowingListResponse(int userId) async {
    dynamic jsonData = await httpGet('following-list/$userId', jwt: true);
    return FollowingListResponse.fromJson(jsonData);
  }
}


class FollowedListResponse {
  final List<Connection> followedList;

  FollowedListResponse({required this.followedList});

  factory FollowedListResponse.fromJson(Map<String, dynamic> json) {
    List<Connection> followedList = [];
    if (json['followed_list'] != null) {
      var followedJsonList = json['followed_list'] as List;
      followedList =
          followedJsonList.map((connection) => Connection.fromJson(connection)).toList();
    }
    return FollowedListResponse(followedList: followedList);
  }

  static Future<FollowedListResponse> fetchFollowedListResponse(int userId) async {
    dynamic jsonData = await httpGet('followed-list/$userId', jwt: true);
    return FollowedListResponse.fromJson(jsonData);
  }
}



// Notificationの型定義
class UserNotification {
  /*
  final int post;
  final int follow;
  */
  final bool? newNotification;
  final bool? already;
  final String? dateCreated;
  final String? text;
  final int? fromUserNumber;
  final String? fromName;
  final String? fromIconimage;
  final String? fromUserId;
  final int? toUserNumber;
  final String? toName;
  final String? toIconimage;
  final String? toUserId;
  final int? senderType;
  final int notificationType;


  UserNotification({
    required this.newNotification,
    required this.already,
    required this.dateCreated,
    required this.text,
    required this.fromUserNumber,
    required this.fromName,
    required this.fromIconimage,
    required this.fromUserId,
    required this.toUserNumber,
    required this.toName,
    required this.toIconimage,
    required this.toUserId,
    required this.senderType,
    required this.notificationType,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      newNotification: json['New'],
      already: json['Already'],
      dateCreated: json['Date'],
      text: json['text'],
      fromUserNumber: json['from_user_number'],
      fromName: json['from_name'],
      fromIconimage: json['from_iconimage'],
      fromUserId: json['from_user_id'],
      toUserNumber: json['to_user_number'],
      toName: json['to_name'],
      toIconimage: json['to_iconimage'],
      toUserId: json['to_user_id'],
      senderType: json['sender_type'],
      notificationType: json['notification_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'New': newNotification,
      'Already': already,
      'Date': dateCreated,
      'text': text,
      'from_user_number': fromUserNumber,
      'form_name': fromName,
      'from_iconimage': fromIconimage,
      'from_user_id': fromUserId,
      'to_user_number': toUserNumber,
      'to_name': toName,
      'to_iconimage': toIconimage,
      'to_user_id': toUserId,
      'sender_type': senderType,
      'notification_type': notificationType,
    };
  }
}

class NotificationListResponse {
  final List<UserNotification> notificationList;

  NotificationListResponse({required this.notificationList});

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    List<UserNotification> notificationList = [];
    if (json['notification_list'] != null) {

      var notificationJsonList = json['notification_list'] as List;
      notificationList =
          notificationJsonList.map((notification) => UserNotification.fromJson(notification)).toList();
    }
    return NotificationListResponse(notificationList: notificationList);
  }

  static Future<NotificationListResponse> fetchNotificationListResponse(int page) async {
    dynamic jsonData = await httpGet('notification', jwt: true);
    return NotificationListResponse.fromJson(jsonData);
  }
}



// Goalの型定義
class Goal {
  final int userNumber;
  final String goalText;
  final int goalType;
  final String? purpose;
  final String? benefit;
  final String? loss;
  final String? note;
  final String deadline;
  final String dateCreated;
  final int goalNumber;

  Goal({
    required this.userNumber,
    required this.goalText,
    required this.goalType,
    required this.purpose,
    required this.benefit,
    required this.loss,
    required this.note,
    required this.deadline,
    required this.dateCreated,
    required this.goalNumber,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      userNumber: json['user'],
      goalText: json['goal_text'],
      goalType: json['goal_type'],
      purpose: json['purpose'],
      benefit: json['benefit'],
      loss: json['loss'],
      note: json['note'],
      deadline: json['deadline'],
      dateCreated: json['date_created'],
      goalNumber: json['goal_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userNumber,
      'goal_text': goalText,
      'goal_type': goalType,
      'purpose': purpose,
      'benefit': benefit,
      'loss': loss,
      'note': note,
      'deadline': deadline,
      'date_created': dateCreated,
      'goal_number': goalNumber,
    };
  }
}

class GoalListResponse {
  final List<Goal> goalList;

  GoalListResponse({required this.goalList});

  factory GoalListResponse.fromJson(Map<String, dynamic> json) {
    List<Goal> goalList = [];
    if (json['goal_list'] != null) {

      var goalJsonList = json['goal_list'] as List;
      goalList =
          goalJsonList.map((goal) => Goal.fromJson(goal)).toList();
    }
    return GoalListResponse(goalList: goalList);
  }

  static Future<GoalListResponse> fetchGoalListResponse(int page) async {
    dynamic jsonData = await httpGet('goal-list/', jwt: true);
    return GoalListResponse.fromJson(jsonData);
  }
}


class GoalResponse {
  final Goal goal;

  GoalResponse({required this.goal});

  factory GoalResponse.fromJson(Map<String, dynamic> json) {
    Goal goal;

    goal = Goal.fromJson(json);

    return GoalResponse(goal: goal);
  }

  static Future<GoalResponse> fetchGoalResponse(int goalNumber) async {
    dynamic jsonData = await httpGet('goal/detail/${goalNumber}', jwt: true);
    return GoalResponse.fromJson(jsonData);
  }
}


// Missionの型定義
class Mission {
  final int userNumber;
  final String missionText;
  final int missionType;
  final String? repeat;
  final String? reward;
  final String? penalty;
  final String starTime;
  final String endTime;
  final String? note;
  final String? opportunity;
  final String dateCreated;
  final int missionNumber;


  Mission({
    required this.userNumber,
    required this.missionText,
    required this.missionType,
    required this.repeat,
    required this.reward,
    required this.penalty,
    required this.starTime,
    required this.endTime,
    required this.note,
    required this.opportunity,
    required this.dateCreated,
    required this.missionNumber,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      userNumber: json['user'],
      missionText: json['mission_text'],
      missionType: json['mission_type'],
      repeat: json['repeat'],
      reward: json['reward'],
      penalty: json['penalty'],
      starTime: json['start_time'],
      endTime: json['end_time'],
      note: json['note'],
      opportunity: json['opportunity'],
      dateCreated: json['date_created'],
      missionNumber: json['mission_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userNumber,
      'mission_text': missionText,
      'mission_type': missionType,
      'repeat': repeat,
      'reward': reward,
      'penalty': penalty,
      'start_time': starTime,
      'end_time': endTime,
      'note': note,
      'opportunity': opportunity,
      'date_created': dateCreated,
      'mission_number': missionNumber,
    };
  }
}

class MissionListResponse {
  final List<Mission> missionList;

  MissionListResponse({required this.missionList});

  factory MissionListResponse.fromJson(Map<String, dynamic> json) {
    List<Mission> missionList = [];
    if (json['mission_list'] != null) {

      var missionJsonList = json['mission_list'] as List;
      missionList =
          missionJsonList.map((mission) => Mission.fromJson(mission)).toList();
    }
    return MissionListResponse(missionList: missionList);
  }

  static Future<MissionListResponse> fetchMissionListResponse(int page) async {
    dynamic jsonData = await httpGet('mission-list/', jwt: true);
    return MissionListResponse.fromJson(jsonData);
  }
}


class MissionResponse {
  final Mission mission;

  MissionResponse({required this.mission});

  factory MissionResponse.fromJson(Map<String, dynamic> json) {
    Mission mission;

    mission = Mission.fromJson(json);

    return MissionResponse(mission: mission);
  }

  static Future<MissionResponse> fetchMissionResponse(int missionNumber) async {
    dynamic jsonData = await httpGet('mission/detail/${missionNumber}', jwt: true);
    return MissionResponse.fromJson(jsonData);
  }
}



// Userの型定義
class User {
  final bool isActive;
  final String dateJoined;
  final int? userNumber;
  final String? name;
  final String? iconimage;
  final String? userId;
  final String? profile;
  final int? profileNumber;
  final bool? private;
  final bool? superHardWorker;
  final bool? hardWorker;
  final bool? regularCustomer;
  final bool? superEarlyBird;
  final bool? earlyBird;

  User({
    required this.isActive,
    required this.dateJoined,
    required this.userNumber,
    required this.name,
    required this.iconimage,
    required this.userId,
    required this.profile,
    required this.profileNumber,
    required this.private,
    required this.superHardWorker,
    required this.hardWorker,
    required this.regularCustomer,
    required this.superEarlyBird,
    required this.earlyBird,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      isActive: json['is_active'],
      dateJoined: json['date_joined'],
      userNumber: json['user_number'],
      name: json['name'],
      iconimage: json['iconimage'],
      userId: json['user_id'],
      profile: json['profile'],
      profileNumber: json['profile_number'],
      private: json['private'],
      superHardWorker: json['super_hard_worker'],
      hardWorker: json['hard_worker'],
      regularCustomer: json['regular_customer'],
      superEarlyBird: json['super_early_bird'],
      earlyBird: json['early_bird'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_active': isActive,
      'date_joined': dateJoined,
      'user_number': userNumber,
      'name': name,
      'iconimage': iconimage,
      'user_id': userId,
      'profile': profile,
      'profile_number': profileNumber,
      'private': private,
      'super_hard_worker': superHardWorker,
      'hard_worker': hardWorker,
      'regular_customer': regularCustomer,
      'super_early_bird': superEarlyBird,
      'early_bird': earlyBird,
    };
  }
}

class RecommendUserListResponse {
  final List<User> recommendUserList;

  RecommendUserListResponse({required this.recommendUserList});

  factory RecommendUserListResponse.fromJson(Map<String, dynamic> json) {
    List<User> recommendUserList = [];
    if (json['recommend_user_list'] != null) {
      var userJsonList = json['recommend_user_list'] as List;
      recommendUserList =
          userJsonList.map((user) => User.fromJson(user)).toList();
    }
    return RecommendUserListResponse(recommendUserList: recommendUserList);
  }

  static Future<RecommendUserListResponse> fetchRecommendUserListResponse() async {
    dynamic jsonData = await httpGet('recommend-user-list/', jwt: true);
    return RecommendUserListResponse.fromJson(jsonData);
  }
}



class SearchUserListResponse {
  final List<User> searchUserList;

  SearchUserListResponse({required this.searchUserList});

  factory SearchUserListResponse.fromJson(Map<String, dynamic> json) {
    List<User> searchUserList = [];
    if (json['user_list'] != null) {
      var userJsonList = json['user_list'] as List;
      searchUserList =
          userJsonList.map((user) => User.fromJson(user)).toList();
    }
    return SearchUserListResponse(searchUserList: searchUserList);
  }

  static Future<SearchUserListResponse> fetchSearchUserListResponse(int page,String keyword) async {
    dynamic jsonData = await httpGet('search-name-list/${page}/?keyword=${keyword}', jwt: true);
    print(jsonData);
    return SearchUserListResponse.fromJson(jsonData);
  }
}


class SearchUserIdListResponse {
  final List<User> searchUserIdList;

  SearchUserIdListResponse({required this.searchUserIdList});

  factory SearchUserIdListResponse.fromJson(Map<String, dynamic> json) {
    List<User> searchUserIdList = [];
    if (json['user_list'] != null) {
      var userJsonList = json['user_list'] as List;
      searchUserIdList =
          userJsonList.map((user) => User.fromJson(user)).toList();
    }
    return SearchUserIdListResponse(searchUserIdList: searchUserIdList);
  }

  static Future<SearchUserIdListResponse> fetchSearchUserIdListResponse(int page,String keyword) async {
    dynamic jsonData = await httpGet('search-id-list/${page}/?keyword=${keyword}', jwt: true);
    return SearchUserIdListResponse.fromJson(jsonData);
  }
}





