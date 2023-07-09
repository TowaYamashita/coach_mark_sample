import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepOrange,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  late TutorialCoachMark tutorialCoachMark;

  GlobalKey infoButtonKey = GlobalKey();
  GlobalKey favoriteButtonKey = GlobalKey();

  Map<String, bool> items = {
    'ALFA': false,
    'BRAVO': false,
    'CHARLIE': false,
    'DELTA': false,
    'ECHO': false,
    'FOXTROT': false,
    'GOLF': false,
    'HOTEL': false,
    'INDIA': false,
    'JULIETT': false,
    'KILO': false,
    'LIMA': false,
    'MIKE': false,
  };

  @override
  void initState() {
    createTutorial();
    Future.delayed(Duration.zero, showTutorial);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('コーチマークサンプル'),
        actions: [
          IconButton(
            key: infoButtonKey,
            onPressed: () {
              showLicensePage(context: context);
            },
            icon: const Icon(Icons.info),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverList.builder(
            itemBuilder: (_, index) {
              return ListTile(
                title: Text(items.keys.elementAt(index)),
                subtitle: Text('this is test message. ' * 5),
                trailing: IconButton(
                  key: index == 0 ? favoriteButtonKey : null,
                  onPressed: () {
                    setState(() {
                      items.update(
                          items.keys.elementAt(index), (value) => !value);
                    });
                  },
                  icon: Icon(
                    items.values.elementAt(index)
                        ? Icons.favorite
                        : Icons.favorite_outline,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    showDragHandle: true,
                    builder: (_) {
                      return Center(
                        child: Text('username: ${items[index]}'),
                      );
                    },
                  );
                },
              );
            },
            itemCount: items.length,
          ),
        ],
      ),
    );
  }

  void showTutorial() {
    tutorialCoachMark.show(context: context);
  }

  void createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.deepOrange,
      alignSkip: Alignment.bottomLeft,
      skipWidget: ElevatedButton.icon(
        icon: const Icon(Icons.double_arrow_rounded),
        label: const Text('スキップ'),
        onPressed: () {},
      ),
      paddingFocus: 5,
      opacityShadow: 0.8,
    );
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];

    targets.add(
      TargetFocus(
        keyTarget: infoButtonKey,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              bottom: 0,
              left: 0,
            ),
            builder: (_, controller) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: controller.next,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('次へ'),
                  ),
                ],
              );
            },
          ),
          TargetContent(
            align: ContentAlign.bottom,
            builder: (_, controller) {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ライセンス情報",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "このアプリケーションに関するライセンス情報を閲覧したい場合は、このアイコンをタップしてください。",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        keyTarget: favoriteButtonKey,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              bottom: 0,
              left: 0,
            ),
            builder: (_, controller) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: controller.next,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('次へ'),
                  ),
                ],
              );
            },
          ),
          TargetContent(
            align: ContentAlign.bottom,
            builder: (_, controller) {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "お気に入り",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "お気に入りにしたいユーザがいる場合は、そのユーザの横のハートボタンをタップしてください。",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              );
            },
          )
        ],
      ),
    );

    return targets;
  }
}
