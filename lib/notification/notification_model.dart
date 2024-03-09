import '../api.dart';

// Notificationの型定義
class UserNotification {
  /*
  final int post;
  final int follow;
  */
  final int? post;
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
    required this.post,
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
      post: json['Post'],
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
      'post': post,
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
      notificationList = notificationJsonList
          .map((notification) => UserNotification.fromJson(notification))
          .toList();
    }
    return NotificationListResponse(notificationList: notificationList);
  }

  static Future<NotificationListResponse> fetchNotificationListResponse(
      int page) async {
    dynamic jsonData = await httpGet('notification/${page}/', jwt: true);
    return NotificationListResponse.fromJson(jsonData);
  }
}
