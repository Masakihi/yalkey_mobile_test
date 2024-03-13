import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/src/widgets/framework.dart';

class BarChartWidget extends StatelessWidget {
  // 棒グラフの棒の横幅
  static const double barWidth = 20.0;

  // グラフタイトルのラベル書式
  final TextStyle _labelStyle =
      const TextStyle(fontSize: 16, fontWeight: FontWeight.w800);

  // ダミーデータ
  final blogLog = <double>[11, 17, 10, 6, 5, 3, 5, 3, 4, 3, 16, 15];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: BarChart(
        BarChartData(
            maxY: 20, //Y軸の最大値を指定

            // 棒グラフの位置
            alignment: BarChartAlignment.spaceEvenly,

            // 棒グラフタッチ時の動作設定
            barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.black,
            )),

            // グラフタイトルのパラメータ
            titlesData: FlTitlesData(
              show: true,
              //右タイトル
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              //上タイトル
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              //下タイトル
              bottomTitles: AxisTitles(
                axisNameWidget: Text(
                  'ブログ運営年月',
                  style: _labelStyle,
                ),
                axisNameSize: 40,
                sideTitles: SideTitles(
                  showTitles: true,
                ),
              ),
              // 左タイトル
              leftTitles: AxisTitles(
                axisNameWidget: Container(
                    alignment: Alignment.topCenter,
                    child: Text(
                      '記事数',
                      style: _labelStyle,
                    )),
                axisNameSize: 25,
                sideTitles: SideTitles(
                  showTitles: true,
                ),
              ),
            ),

            // 外枠表の線を表示/非表示
            borderData: FlBorderData(
                border: const Border(
              top: BorderSide.none,
              right: BorderSide.none,
              left: BorderSide(width: 1),
              bottom: BorderSide(width: 1),
            )),

            // barGroups: 棒グラフのグループを表す
            // BarChartGroupData: 棒グラフの1つのグループを表す
            // X : 横軸
            // barRods: 棒グラフのデータを含むBarRodクラスのリスト
            // BarChartRodData
            // toY : 高さ
            // width : 棒の幅
            barGroups: [
              BarChartGroupData(x: 2, barRods: [
                BarChartRodData(toY: blogLog[0], width: barWidth),
              ]),
              BarChartGroupData(x: 3, barRods: [
                BarChartRodData(toY: blogLog[1], width: barWidth),
              ]),
              BarChartGroupData(x: 4, barRods: [
                BarChartRodData(toY: blogLog[2], width: barWidth),
              ]),
              BarChartGroupData(x: 5, barRods: [
                BarChartRodData(toY: blogLog[3], width: barWidth),
              ]),
              BarChartGroupData(x: 6, barRods: [
                BarChartRodData(toY: blogLog[4], width: barWidth),
              ]),
              BarChartGroupData(x: 7, barRods: [
                BarChartRodData(toY: blogLog[5], width: barWidth),
              ]),
              BarChartGroupData(x: 8, barRods: [
                BarChartRodData(toY: blogLog[6], width: barWidth),
              ]),
              BarChartGroupData(x: 9, barRods: [
                BarChartRodData(toY: blogLog[7], width: barWidth),
              ]),
              BarChartGroupData(x: 10, barRods: [
                BarChartRodData(toY: blogLog[8], width: barWidth),
              ]),
              BarChartGroupData(x: 11, barRods: [
                BarChartRodData(toY: blogLog[9], width: barWidth),
              ]),
              BarChartGroupData(x: 12, barRods: [
                BarChartRodData(toY: blogLog[10], width: barWidth),
              ]),
              BarChartGroupData(x: 1, barRods: [
                BarChartRodData(toY: blogLog[11], width: barWidth),
              ]),
            ]),
      ),
    );
  }
}
