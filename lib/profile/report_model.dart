import '../api.dart';

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
    dynamic jsonData = await httpGet('report-list/$userId/', jwt: true);
    return ReportListResponse.fromJson(jsonData);
  }
}
