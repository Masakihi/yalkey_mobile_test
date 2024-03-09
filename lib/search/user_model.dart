import '../api.dart';

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

  static Future<RecommendUserListResponse>
      fetchRecommendUserListResponse() async {
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
      searchUserList = userJsonList.map((user) => User.fromJson(user)).toList();
    }
    return SearchUserListResponse(searchUserList: searchUserList);
  }

  static Future<SearchUserListResponse> fetchSearchUserListResponse(
      int page, String keyword) async {
    dynamic jsonData = await httpGet(
        'search-name-list/${page}/?keyword=${keyword}',
        jwt: true);
    // print(jsonData);
    return SearchUserListResponse.fromJson(jsonData);
  }
}

class SearchUserIdListResponse {
  final List<User> searchUserIdList;

  SearchUserIdListResponse({required this.searchUserIdList});

  factory SearchUserIdListResponse.fromJson(Map<String, dynamic> json) {
    List<User> searchUserIdList = [];
    if (json['user_list'] != "None") {
      var userJsonList = json['user_list'] as List;
      searchUserIdList =
          userJsonList.map((user) => User.fromJson(user)).toList();
    }
    return SearchUserIdListResponse(searchUserIdList: searchUserIdList);
  }

  static Future<SearchUserIdListResponse> fetchSearchUserIdListResponse(
      int page, String keyword) async {
    dynamic jsonData =
        await httpGet('search-id-list/${page}/?keyword=${keyword}', jwt: true);
    return SearchUserIdListResponse.fromJson(jsonData);
  }
}
