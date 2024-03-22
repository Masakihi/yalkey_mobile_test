import '../api.dart';

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
      goalList = goalJsonList.map((goal) => Goal.fromJson(goal)).toList();
    }
    return GoalListResponse(goalList: goalList);
  }

  static Future<GoalListResponse> fetchGoalListResponse(int page) async {
    dynamic jsonData = await httpGet('goal-list/${page}/', jwt: true);
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
    dynamic jsonData = await httpGet('goal/detail/${goalNumber}/', jwt: true);
    return GoalResponse.fromJson(jsonData);
  }
}
