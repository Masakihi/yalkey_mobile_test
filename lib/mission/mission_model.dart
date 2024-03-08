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
    dynamic jsonData = await httpGet('mission-list/${page}/', jwt: true);
    return MissionListResponse.fromJson(jsonData);
  }

  static Future<MissionListResponse> fetchMissionTodayListResponse(
      int page) async {
    dynamic jsonData = await httpGet('mission-today-list/${page}/', jwt: true);
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

class NewMission {
  final int missionNumber;
  final int userNumber;
  final String title;
  final String? repeat;
  final String? reward;
  final String? penalty;
  final String? note;
  final String starTime;
  final String endTime;
  final String? opportunity;
  final String dateCreated;
  late bool achieved;
  late Map<String, bool> tasks;

  NewMission({
    required this.missionNumber,
    required this.userNumber,
    required this.title,
    required this.repeat,
    required this.reward,
    required this.penalty,
    required this.note,
    required this.starTime,
    required this.endTime,
    required this.opportunity,
    required this.dateCreated,
    required this.achieved,
    required this.tasks,
  });

  factory NewMission.fromJson(Map<String, dynamic> json) {
    return NewMission(
        missionNumber: json['mission_number'],
        userNumber: json['userId'],
        title: json['title'],
        repeat: json['repeat'],
        reward: json['reward'],
        penalty: json['penalty'],
        note: json['note'],
        starTime: json['start_time'],
        endTime: json['end_time'],
        opportunity: json['opportunity'],
        dateCreated: json['date_created'],
        achieved: json['achieved'],
        tasks: json['tasks']);
  }

  Future<void> handleAchieved() async {
    // 下のようなAPIを叩いていると仮定
    // httpPost("mission/achieve/$missionNumber",{}, jwt: true);
    await Future.delayed(const Duration(milliseconds: 100));
    achieved = !achieved;
  }

  Future<void> addTask(String taskTitle) async {
    // 下のようなAPIを叩いていると仮定
    // httpPost("mission/$missionNumber/add-task", {"task_title": taskTitle}, jwt: true);
    await Future.delayed(const Duration(milliseconds: 100));
    tasks[taskTitle] = false;
  }

  Future<void> deleteTask(String taskTitle) async {
    // 下のようなAPIを叩いていると仮定
    // httpPost("mission/$missionNumber/delete-task", {"task_title": taskTitle}, jwt: true);
    await Future.delayed(const Duration(milliseconds: 100));
    tasks.remove(taskTitle);
  }

  Future<void> handleTaskAchieved(String taskTitle) async {
    // 下のようなAPIを叩いていると仮定
    // httpPost("mission/achieve-task/$missionNumber",{}, jwt: true);
    await Future.delayed(const Duration(milliseconds: 100));
    tasks[taskTitle] = !tasks[taskTitle]!;
  }

  static Future<NewMission> create(Map<String, dynamic> body) async {
    // 下のようなAPIを叩いていると仮定
    // dynamic response = httpPost("mission/create", body, jwt: true);
    // return NewMission.fromJson(response)
    await Future.delayed(const Duration(milliseconds: 100));
    return NewMission.fromJson(newMissionJsonExample);
  }
}

class NewMissionListResponse {
  final List<NewMission> newMissionList;

  NewMissionListResponse({required this.newMissionList});

  factory NewMissionListResponse.fromJson(Map<String, dynamic> json) {
    List<NewMission> newMissionList = [];
    if (json['mission_list'] != null) {
      var newMissionJsonList = json['mission_list'] as List;
      print(newMissionJsonListExample.length);
      newMissionList = newMissionJsonList
          .map((mission) => NewMission.fromJson(mission))
          .toList();
    }
    return NewMissionListResponse(newMissionList: newMissionList);
  }

  static Future<NewMissionListResponse> fetchNewMissionListResponse(
      int page) async {
    // APIをたたくと仮定
    // dynamic jsonData = await httpGet('mission-list/${page}/', jwt: true);
    await Future.delayed(const Duration(milliseconds: 100));
    return NewMissionListResponse.fromJson(
        {"mission_list": newMissionJsonListExample});
  }

  static Future<NewMissionListResponse> fetchNewMissionTodayListResponse(
      int page) async {
    // APIをたたくと仮定
    // dynamic jsonData = await httpGet('mission-today-list/${page}/', jwt: true);
    await Future.delayed(const Duration(milliseconds: 100));
    return NewMissionListResponse.fromJson(
        {"mission_list": newMissionJsonListExample});
  }
}
