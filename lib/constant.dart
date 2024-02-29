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
  /*  final String toPostUserId;
  final String toPostUserName;
  final int postUserProfileNumber;
  final bool postUserPrivate;
  final bool postUserSuperHardWorker;
  final bool postUserHardWorker;
  final bool postUserRegularCustomer;
  final bool postUserSuperEarlyBird;
  final bool postUserEarlyBird;
   */
  final int postNumber;
  final String postText;
  final List<Progress> progressList;
  final String postCreatedAt;
  int postLikeNumber;
  bool postLiked;
  bool postBookmarked;
  bool postReposted;
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
    /*
    required this.toPostUserId,
    required this.toPostUserName,
    required this.postUserProfileNumber,
    required this.postUserPrivate,
    required this.postUserSuperHardWorker,
    required this.postUserHardWorker,
    required this.postUserRegularCustomer,
    required this.postUserSuperEarlyBird,
    required this.postUserEarlyBird,
     */
    required this.postNumber,
    required this.postText,
    required this.progressList,
    required this.postCreatedAt,
    required this.postLikeNumber,
    required this.postLiked,
    required this.postBookmarked,
    required this.postReposted,
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
      if (response['post_reposted']) {
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
      if (!response['post_reposted']) {
        postReposted = false;
      } else {
        throw Exception('Post $postNumber is already unreposted in backend.');
      }
    }
  }

  factory UserRepost.fromJson(Map<String, dynamic> json) {
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
    return UserRepost(
      dateReposted: json['repost_date'],
      isRepost: json['is_repost'],
      repostDate: json['repost_date'],
      repostUserId: json['repost_user_id'],
      repostUserName: json['repost_user_name'],
      postUserIcon: json['post_user_icon'],
      postUserNumber: json['post_user_number'],
      postUserId: json['post_user_id'],
      postUserName: json['post_user_name'],
      /*
      toPostUserId: json['to_post_user_id'],
      toPostUserName: json['to_post_user_name'],
      postUserProfileNumber: json['post_user_profile_number'],
      postUserPrivate: json['post_user_private'],
      postUserSuperHardWorker: json['post_user_super_hard_worker'],
      postUserHardWorker: json['post_user_hard_worker'],
      postUserRegularCustomer: json['post_user_regular_customer'],
      postUserSuperEarlyBird: json['post_user_super_early_bird'],
      postUserEarlyBird: json['post_user_early_bird'],
      */
      postNumber: json['post_number'],
      postText: json['post_text'],
      progressList: progressList,
      postCreatedAt: json['post_created_at'],
      postLikeNumber: json['post_like_number'],
      postLiked: json['post_liked'],
      postBookmarked: json['post_bookmarked'],
      postReposted: json['post_reposted'],
      progressTextList: progressTextList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'date_reposted': dateReposted,
      'repost_date': dateReposted,
      'is_repost': isRepost,
      'repost_date': repostDate,
      'repost_user_id': repostUserId,
      'repost_user_name': repostUserName,
      'post_user_icon': postUserIcon,
      'post_user_number': postUserNumber,
      'post_user_id': postUserId,
      'post_user_name': postUserName,
      /*
      'to_post_user_id': toPostUserId,
      'to_post_user_name': toPostUserName,
      'post_user_profile_number': postUserProfileNumber,
      'post_user_private': postUserPrivate,
      'post_user_super_hard_worker': postUserSuperHardWorker,
      'post_user_hard_worker': postUserHardWorker,
      'post_user_regular_customer': postUserRegularCustomer,
      'post_user_super_early_bird': postUserSuperEarlyBird,
      'post_user_early_bird': postUserEarlyBird,
       */
      'post_number': postNumber,
      'post_text': postText,
      'progress_list':
          progressList.map((progress) => progress.toJson()).toList(),
      'post_created_at': postCreatedAt,
      'post_like_number': postLikeNumber,
      'post_liked': postLiked,
      'post_bookmarked': postBookmarked,
      'post_reposted': postReposted,
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
    return UserRepostListResponse.fromJson(jsonData);
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
