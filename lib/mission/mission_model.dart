import '../api.dart';
import 'example_data.dart';

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
  final int? parentMission;
  final int missionParentType;
  final String requiredTime;
  final int priority;
  final int repeatType;
  final int repeatInterval;
  final int repeatStopType;
  final String repeatStopDate;
  final int repeatNumber;
  final String repeatDayWeek;
  final int missionNumber;
  late final bool? achieved;

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
    required this.parentMission,
    required this.missionParentType,
    required this.requiredTime,
    required this.priority,
    required this.repeatType,
    required this.repeatInterval,
    required this.repeatStopType,
    required this.repeatStopDate,
    required this.repeatNumber,
    required this.repeatDayWeek,
    required this.missionNumber,
    required this.achieved,
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
      parentMission: json['parent_mission'],
      missionParentType: json['mission_parent_type'],
      requiredTime: json['required_time'],
      priority: json['priority'],
      repeatType: json['repeat_type'],
      repeatInterval: json['repeat_interval'],
      repeatStopType: json['repeat_stop_type'],
      repeatStopDate: json['repeat_stop_date'],
      repeatNumber: json['repeat_number'],
      repeatDayWeek: json['repeat_day_week'],
      missionNumber: json['mission_number'],
      achieved: json['achieved'],
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
      'parent_mission': parentMission,
      'mission_parent_type': missionParentType,
      'required_time': requiredTime,
      'priority': priority,
      'repeat_type': repeatType,
      'repeat_interval': repeatInterval,
      'repeat_stop_type': repeatStopType,
      'repeat_stop_date': repeatStopDate,
      'repeat_number': repeatNumber,
      'repeat_day_week': repeatDayWeek,
      'mission_number': missionNumber,
      'achieved': achieved,
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
    dynamic jsonData = await httpGet('mission-list/${page}/', jwt: true);
    return MissionListResponse.fromJson(jsonData);
  }

  static Future<MissionListResponse> fetchMissionTodayListResponse(
      int page) async {
    dynamic jsonData = await httpGet('mission-today-list/${page}/', jwt: true);
    return MissionListResponse.fromJson(jsonData);
  }

  static Future<MissionListResponse> fetchMissionDailyListResponse(
      int year, int month, int day, int page)
  async {
    dynamic jsonData = await httpGet('mission-daily-list/${year}/${month}/${day}/${page}/', jwt: true);
    //dynamic jsonData = await httpGet('mission-daily-list/2024/3/10/1/', jwt: true);
    //print(jsonData);
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
    dynamic jsonData =
        await httpGet('mission/detail/${missionNumber}', jwt: true);
    return MissionResponse.fromJson(jsonData);
  }
}

