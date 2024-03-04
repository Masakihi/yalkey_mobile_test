import 'package:flutter/material.dart';


class SamplePage extends StatefulWidget {
  const SamplePage({Key? key}) : super(key: key);

  @override
  _SamplePageState createState() => _SamplePageState();
}


class _SamplePageState extends State<SamplePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: _clearCache,
            icon: Icon(Icons.refresh),
            tooltip: 'Clear Cache',
          ),
        ],
      ),
       */
      body: RefreshIndicator(
        displacement: 0,
        onRefresh: () async {
        },
        child:Column(

        ),
      ),
    );
  }
}

