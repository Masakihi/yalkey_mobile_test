import 'api.dart';

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
    // print(jsonData);
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
      'follower_profile': followerProfile,
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
      followingList = followingJsonList
          .map((connection) => Connection.fromJson(connection))
          .toList();
    }
    return FollowingListResponse(followingList: followingList);
  }

  static Future<FollowingListResponse> fetchFollowingListResponse(
      int userId, int page) async {
    dynamic jsonData =
        await httpGet('following-list/$userId/${page}/', jwt: true);
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
      followedList = followedJsonList
          .map((connection) => Connection.fromJson(connection))
          .toList();
    }
    return FollowedListResponse(followedList: followedList);
  }

  static Future<FollowedListResponse> fetchFollowedListResponse(
      int userId, int page) async {
    dynamic jsonData =
        await httpGet('followed-list/$userId/${page}/', jwt: true);
    return FollowedListResponse.fromJson(jsonData);
  }
}

// FollowRequestの型定義
class FollowRequest {
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

  FollowRequest({
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

  factory FollowRequest.fromJson(Map<String, dynamic> json) {
    return FollowRequest(
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

class FollowRequestListResponse {
  final List<FollowRequest> followRequestList;

  FollowRequestListResponse({required this.followRequestList});

  factory FollowRequestListResponse.fromJson(Map<String, dynamic> json) {
    List<FollowRequest> followRequestList = [];
    if (json['follow_request_list'] != null) {
      var followRequestJsonList = json['follow_request_list'] as List;
      followRequestList = followRequestJsonList
          .map((follow_request) => FollowRequest.fromJson(follow_request))
          .toList();
    }
    return FollowRequestListResponse(followRequestList: followRequestList);
  }

  static Future<FollowRequestListResponse> fetchFollowRequestListResponse(
      int page) async {
    dynamic jsonData = await httpGet('follow-request-list/${page}/', jwt: true);
    return FollowRequestListResponse.fromJson(jsonData);
  }
}
