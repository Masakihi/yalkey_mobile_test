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

class UserRepost {
  final String dateReposted;
  final int isRepost;
  final String repostUserId;
  final String postUserIcon;
  final int postUserNumber;
  final String postUserId;
  final String postUserName;
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
    required this.dateReposted,
    required this.isRepost,
    required this.repostUserId,
    required this.postUserIcon,
    required this.postUserNumber,
    required this.postUserId,
    required this.postUserName,
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
      repostUserId: json['repost_user_id'],
      postUserIcon: json['post_user_icon'],
      postUserNumber: json['post_user_number'],
      postUserId: json['post_user_id'],
      postUserName: json['post_user_name'],
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
      'repost_date': dateReposted,
      'is_repost': isRepost,
      'repost_user_id': repostUserId,
      'post_user_icon': postUserIcon,
      'post_user_number': postUserNumber,
      'post_user_id': postUserId,
      'post_user_name': postUserName,
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
    return YalkerProgressListResponse.fromJson(jsonData);
  }

  static Future<Map<DateTime, dynamic>> fetchDataForGraphByReportTitle(
      int userId,
      DateTime startDate,
      DateTime endDate,
      String reportTitle) async {
    dynamic jsonData = await httpGet(
        'yalker-progress-list/$userId/${startDate.year}/${startDate.month}/${startDate.day}/${endDate.year}/${endDate.month}/${endDate.day}/1');
    final progressList =
        YalkerProgressListResponse.fromJson(jsonData).progressList;
    Map<DateTime, dynamic> date2DataMap = {};
    for (Progress progress in progressList) {
      if (progress.reportTitle == reportTitle) {
        final date = DateTime.parse(progress.progressDate);
        if (date2DataMap.containsKey(date)) {
          // bool型なら||でつなぎ、それ以外なら足し合わせる
          if (progress.reportType == 0) {
            date2DataMap[date] = date2DataMap[date]! || progress.extractData();
          } else {
            date2DataMap[date] = date2DataMap[date]! + progress.extractData();
          }
        } else {
          date2DataMap[date] = progress.extractData();
        }
      }
    }
    return date2DataMap;
  }
}

class ProgressTimeDataForGraph {
  final String progressTitle;
  final DateTime progressDate;
  late Duration progressDuration;

  ProgressTimeDataForGraph({
    required this.progressTitle,
    required this.progressDate,
    required this.progressDuration,
  });

  factory ProgressTimeDataForGraph.fromJson(Map<String, dynamic> json) {
    return ProgressTimeDataForGraph(
        progressTitle: json['report_title'],
        progressDate: DateTime.parse(json['progress_date']),
        progressDuration:
            Duration(hours: json['hours'], minutes: json['minutes']));
  }
}

class ProgressIntegerDataForGraph {
  final String progressTitle;
  final DateTime progressDate;
  late int progressInteger;

  ProgressIntegerDataForGraph({
    required this.progressTitle,
    required this.progressDate,
    required this.progressInteger,
  });

  factory ProgressIntegerDataForGraph.fromJson(Map<String, dynamic> json) {
    return ProgressIntegerDataForGraph(
        progressTitle: json['report_title'],
        progressDate: DateTime.parse(json['progress_date']),
        progressInteger: json["custom_data"]);
  }
}

class ProgressFloatDataForGraph {
  final String progressTitle;
  final DateTime progressDate;
  late double progressFloat;

  ProgressFloatDataForGraph({
    required this.progressTitle,
    required this.progressDate,
    required this.progressFloat,
  });

  factory ProgressFloatDataForGraph.fromJson(Map<String, dynamic> json) {
    return ProgressFloatDataForGraph(
        progressTitle: json['report_title'],
        progressDate: DateTime.parse(json['progress_date']),
        progressFloat: json["custom_float_data"]);
  }
}

class ProgressTodoDataForGraph {
  final String progressTitle;
  final DateTime progressDate;
  late bool progressTodo;

  ProgressTodoDataForGraph({
    required this.progressTitle,
    required this.progressDate,
    required this.progressTodo,
  });

  factory ProgressTodoDataForGraph.fromJson(Map<String, dynamic> json) {
    return ProgressTodoDataForGraph(
        progressTitle: json['report_title'],
        progressDate: DateTime.parse(json['progress_date']),
        progressTodo: json["todo"]);
  }
}
