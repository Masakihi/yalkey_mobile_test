import 'dart:math';
import 'package:flutter/material.dart';

List<int> generateRandomData(int numberOfDays) {
  Random random = Random();
  List<int> data = [];
  for (int i = 0; i < numberOfDays; i++) {
    data.add(random.nextInt(100)); // 0から99までのランダムな数値を生成
  }
  return data;
}

class MonthlyBarChart extends StatelessWidget {
  final int numberOfDays;
  final List<int> data;

  MonthlyBarChart({required this.numberOfDays, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: numberOfDays,
        itemBuilder: (context, index) {
          // ランダムな数値を生成して高さとする
          int value = data[index];
          double height = value.toDouble();

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 20, // 棒グラフの幅
                height: height,
                color: Colors.blue,
              ),
              SizedBox(height: 4),
              Text('${index + 1}日'),
            ],
          );
        },
      ),
    );
  }
}
