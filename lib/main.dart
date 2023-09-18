import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((_) {
  throw UnimplementedError();
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

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

final globalKeysProvider = Provider<Map<String, GlobalKey>>((ref) {
  return {
    'infoButtonKey': GlobalKey(),
    'favoriteButtonKey': GlobalKey(),
  };
});

final fetcher = FutureProvider<Map<String, bool>>((_) async {
  return Future.delayed(const Duration(seconds: 3), () {
    return {
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
  });
});

final coachMarkProvider = StateNotifierProvider<CoachMarkNotifier, bool>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  final showTutorial = sharedPreferences.getBool('showTutorial');

  return CoachMarkNotifier(
    init: showTutorial ?? true,
    coachMark: ref.watch(tutorialProvider),
    onShowedTutorial: () {
      sharedPreferences.setBool('showTutorial', false);
    },
  );
});

class CoachMarkNotifier extends StateNotifier<bool> {
  CoachMarkNotifier({
    required bool init,
    required this.coachMark,
    required this.onShowedTutorial,
  }) : super(init);

  final TutorialCoachMark coachMark;
  final void Function() onShowedTutorial;

  /// コーチマークを表示する
  /// - 一度でも表示していれば何もしない
  void show(BuildContext context) {
    if (state == false || context.mounted == false) {
      return;
    }

    coachMark.show(context: context);
    onShowedTutorial();
    state = false;
  }
}

final tutorialProvider = Provider<TutorialCoachMark>((ref) {
  List<TargetFocus> targets = [];

  final infoButtonKey = ref.watch(globalKeysProvider)['infoButtonKey'];
  final favoriteButtonKey = ref.watch(globalKeysProvider)['favoriteButtonKey'];

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

  return TutorialCoachMark(
    targets: targets,
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
});

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    ref.listen(fetcher, (previous, next) {
      print('コーチマーク表示処理処理: 開始');

      // データ取得が完了するまで何もしない
      if (next is! AsyncData) {
        print('コーチマーク表示処理処理: 中断');
        return;
      }

      ref.watch(coachMarkProvider.notifier).show(context);
      print('コーチマーク表示処理処理: 終了');
    });

    return ref.watch(fetcher).when(
      loading: () {
        print('ロード中');

        return const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
      error: (error, stackTrace) {
        print('エラー発生');

        return const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
      data: (data) {
        print('データ取得完了');

        final infoButtonKey = ref.read(globalKeysProvider)['infoButtonKey'];
        final favoriteButtonKey =
            ref.read(globalKeysProvider)['favoriteButtonKey'];

        final items = data;
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
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              print('データ再取得処理: 開始');
              ref.refresh(fetcher);
              print('データ再取得処理: 終了');
            },
            child: const Icon(Icons.refresh),
          ),
        );
      },
    );
  }
}
