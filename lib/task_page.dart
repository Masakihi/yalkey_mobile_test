import 'package:flutter/material.dart';
import 'api.dart';
import 'task_detail_page.dart';


class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  _TaskPageState createState() => _TaskPageState();
}


class _TaskPageState extends State<TaskPage> {
  Future<dynamic>? _missionList;

  @override
  void initState() {
    super.initState();
    _fetchMissionListData();
  }

  Future<void> _fetchMissionListData() async {
    try {
      final Future<dynamic> response =
          httpGet('mission-list/', jwt: true);
      setState(() {
        _missionList = response;
      });
    } catch (error) {
      print('Error fetching mission data: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mission List'),
      ),
      body: FutureBuilder(
        future: _missionList,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました'));
          } else {
            return Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    //controller: _scrollController, // スクロールコントローラーを設定
                    itemCount: snapshot.data?.length, // リストアイテム数 + ローディングインジケーター
                    itemBuilder: (context, index) {
                      final mission = snapshot.data?["mission_list"][index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: ListTile(
                          //isThreeLine: true,
                          leading: FlutterLogo(),
                          //title: Text('sss'),
                          title: Text('${mission["mission_text"]}'),
                          subtitle: Text('・作成日: ${mission["date_created"]}\n・終了日: ${mission["end_time"]}${mission}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskDetailPage(value: int.parse('${mission["mission_number"]}')),
                                //builder: (context) => TaskDetailPage(value: int.parse('352')),
                              ),
                            );
                            print('onTap');
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
    ));
  }
}

