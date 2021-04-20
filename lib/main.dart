import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/services.dart';

import 'package:pomodoro_app/model/status.dart';
import 'package:pomodoro_app/settings_page.dart';
import 'package:pomodoro_app/todo.dart';
import 'package:pomodoro_app/utils/constants.dart';
import './buttons.dart';

void main() => runApp(Main());

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro App',
      home: Home(),
      theme: ThemeData(
        primaryColor: Color(0XFF540C0C),
        accentColor: Color(0XFF540C0C),
        scaffoldBackgroundColor: const Color(0XFF540C0C),
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with SingleTickerProviderStateMixin {
  List<Todo> list = [];
  SharedPreferences sharedPreferences;
  static AudioCache player = AudioCache();

  /* String currentTodo = "ABC";

  callback(newAbc) {
    setState(() {
      currentTodo = newAbc;
    });
  } */

  PomodoroStatus pomodoroStatus = PomodoroStatus.initPomodoro;
  Timer _timer;

  int pomodoroTotalTime;
  int breakTime;
  int remaningTime;
  int remaningBreakTime;

  @override
  void initState() {
    pomodoroTotalTime = 25 * 60;
    breakTime = 5 * 60;
    remaningTime = pomodoroTotalTime;
    remaningBreakTime = breakTime;
    loadSharedPreferencesAndData();
    player.load('bell.mp3');
    super.initState();
  }

  void loadSharedPreferencesAndData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Pomodoro App',
            key: Key('main-app-title'),
          ),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.menu), onPressed: () => goToNewItemView())
          ]),
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 50,
          ),
          Text(
            statusDescription[pomodoroStatus],
            style: TextStyle(fontSize: 25.0, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 50,
          ),
          /* Text(currentTodo), */
          Container(
            height: 60,
            child: Center(
                child: /* list.isEmpty ? emptyList() : */ buildListView()),
          ),
          CircularPercentIndicator(
              radius: 220.0,
              backgroundColor: _timerColor(),
              lineWidth: 3.0,
              percent: _getPomodoroPercentage(),
              circularStrokeCap: CircularStrokeCap.square,
              center: Text(
                _secondsToFormatedString(remaningTime, remaningBreakTime),
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
              progressColor: statusColor[pomodoroStatus]),
          SizedBox(
            height: 100,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Buttons(
                onTap: _mainButtonPressed,
                icontest: statusIcon[pomodoroStatus],
                iconSize: 56,
              ),
              SizedBox(
                width: 100,
              ),
              Buttons(
                onTap: _resetCountdown,
                icontest: Icons.replay,
                iconSize: 56,
              ),
            ],
          )
        ],
      ),
    );
  }

  /* Widget emptyList() {
    
    return Center(
        child: Text(
      'You have no Todos',
      style: TextStyle(
        color: Colors.white,
      ),
    ));
  } */

  Widget buildListView() {
    if (list.isEmpty) return null;
    switch (pomodoroStatus) {
      case PomodoroStatus.runningPomodoro:
        return showTodo();
      case PomodoroStatus.pausedPomodoro:
        return showTodo();
      case PomodoroStatus.breakPomodoro:
        break;
      case PomodoroStatus.pausedBreak:
        break;
      case PomodoroStatus.initPomodoro:
        break;
    }
    return null;
  }

  Widget showTodo() {
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (BuildContext context, int index) {
        return buildItem(list[index], index);
      },
    );
  }

  Widget buildItem(Todo item, index) {
    return Dismissible(
      key: Key('${item.hashCode}'),
      onDismissed: (direction) => removeItem(item),
      direction: DismissDirection.startToEnd,
      child: buildListTile(item, index),
    );
  }

  Widget buildListTile(Todo item, int index) {
    return ListTile(
      onTap: () => removeItem(item),
      /* onLongPress: () => goToNewItemView(), */
      title: Text(
        item.title,
        textAlign: TextAlign.center,
        key: Key('item-$index'),
        style: TextStyle(
            fontSize: 23,
            color: item.completed ? Colors.grey : Colors.white,
            decoration: item.completed ? TextDecoration.lineThrough : null),
      ),
    );
  }

  void goToNewItemView() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return NewTodoView(
        /* item: item, */
        list: list,
        increment: increment,
        decrement: decrement,
        pomodoroTotalTime: pomodoroTotalTime,
        breakTime: breakTime,
        addItem: addItem,
        removeItem: removeItem,
        /* currentTodo: currentTodo,
        callback: callback, */
      );
    })).then((title) {
      if (title != null) {
        addItem(Todo(title: title));
      }
    });
  }

  void addItem(Todo item) {
    list.insert(0, item);
    saveData();
    setState(() {});
  }

  /* void goToEditItemView(item) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return NewTodoView(
        item: item,
        increment: increment,
        pomodoroTotalTime: pomodoroTotalTime,
      );
    })).then((title) {
      if (title != null) {
        editItem(item, title);
      }
    });
  } */

  void editItem(Todo item, String title) {
    item.title = title;
    setState(() {});
    saveData();
  }

  void removeItem(Todo item) {
    list.remove(item);
    setState(() {});
    saveData();
  }

  void loadData() {
    List<String> spList = sharedPreferences.getStringList('list');
    if (spList != null) {
      setState(() {
        list = spList.map((item) => Todo.fromMap(json.decode(item))).toList();
      });
    }
    setState(() {});
  }

  void saveData() {
    List<String> spList =
        list.map((item) => json.encode(item.toMap())).toList();
    sharedPreferences.setStringList('list', spList);
    setState(() {});
  }

  // Counter Functionality //
  void increment(checkTime) {
    if (checkTime == 'Work Time') {
      setState(() => pomodoroTotalTime = pomodoroTotalTime + 60);
      setState(() => remaningTime = remaningTime + 60);
    } else {
      setState(() => breakTime = breakTime + 60);
      setState(() => remaningBreakTime = remaningBreakTime + 60);
    }
  }

  void decrement(checkTime) {
    if (checkTime == 'Work Time') {
      if (pomodoroTotalTime <= 60) {
        setState(() => pomodoroTotalTime = 60);
        setState(() => remaningTime = 60);
      } else {
        setState(() => pomodoroTotalTime = pomodoroTotalTime - 60);
        setState(() => remaningTime = remaningTime - 60);
      }
    } else if (checkTime == 'Break Time') {
      if (breakTime <= 60) {
        setState(() => breakTime = 60);
        setState(() => remaningBreakTime = 60);
      } else {
        setState(() => breakTime = breakTime - 60);
        setState(() => remaningBreakTime = remaningBreakTime - 60);
      }
    }
  }

  _timerColor() {
    Color color;
    switch (pomodoroStatus) {
      case PomodoroStatus.runningPomodoro:
        color = Colors.white;
        break;
      case PomodoroStatus.pausedPomodoro:
        color = Colors.white;
        break;
      case PomodoroStatus.breakPomodoro:
        color = Colors.customValue;
        break;
      case PomodoroStatus.pausedBreak:
        color = Colors.customValue;
        break;
      case PomodoroStatus.initPomodoro:
        color = Colors.white;
        break;
    }
    return color;
  }

  _secondsToFormatedString(int totalSeconds, int breakSeconds) {
    int seconds;
    switch (pomodoroStatus) {
      case PomodoroStatus.runningPomodoro:
        seconds = totalSeconds;
        break;
      case PomodoroStatus.pausedPomodoro:
        seconds = totalSeconds;
        break;
      case PomodoroStatus.breakPomodoro:
        seconds = breakSeconds;
        break;
      case PomodoroStatus.pausedBreak:
        seconds = breakSeconds;
        break;
      case PomodoroStatus.initPomodoro:
        seconds = totalSeconds;
        break;
    }
    int roundedMinutes = seconds ~/ 60;
    int remainingSeconds = seconds - (roundedMinutes * 60);
    String remainingSecondsFormated;
    if (remainingSeconds < 10) {
      remainingSecondsFormated = '0$remainingSeconds';
    } else {
      remainingSecondsFormated = remainingSeconds.toString();
    }
    return '$roundedMinutes:$remainingSecondsFormated';
  }

  _getPomodoroPercentage() {
    int totalTime;
    int remaning;

    switch (pomodoroStatus) {
      case PomodoroStatus.runningPomodoro:
        totalTime = pomodoroTotalTime;
        remaning = remaningTime;
        break;
      case PomodoroStatus.pausedPomodoro:
        totalTime = pomodoroTotalTime;
        remaning = remaningTime;
        break;
      case PomodoroStatus.breakPomodoro:
        totalTime = breakTime;
        remaning = remaningBreakTime;
        break;
      case PomodoroStatus.pausedBreak:
        totalTime = breakTime;
        remaning = remaningBreakTime;
        break;
      case PomodoroStatus.initPomodoro:
        totalTime = pomodoroTotalTime;
        remaning = remaningTime;
        break;
    }
    double percentage = (totalTime - remaning) / totalTime;
    return percentage;
  }

  _mainButtonPressed() {
    switch (pomodoroStatus) {
      case PomodoroStatus.breakPomodoro:
        _pauseBreakCountdown();
        break;
      case PomodoroStatus.runningPomodoro:
        _pauseCountdown();
        break;
      case PomodoroStatus.pausedPomodoro:
        _startCountdown();
        break;
      case PomodoroStatus.pausedBreak:
        _breakCountdown();
        break;
      case PomodoroStatus.initPomodoro:
        _startCountdown();
        break;
    }
  }

  _startCountdown() {
    pomodoroStatus = PomodoroStatus.runningPomodoro;
    _cancelTimer();

    _timer = Timer.periodic(
        Duration(seconds: 1),
        (timer) => {
              if (remaningTime > 0)
                {setState(() => remaningTime--)}
              else
                {
                  _soundVibration(),
                  _cancelTimer(),
                  setState(() {
                    pomodoroStatus = PomodoroStatus.pausedBreak;
                    remaningTime = pomodoroTotalTime;
                  }),
                }
            });
  }

  _breakCountdown() {
    pomodoroStatus = PomodoroStatus.breakPomodoro;
    _cancelTimer();
    _timer = Timer.periodic(
        Duration(seconds: 1),
        (timer) => {
              if (remaningBreakTime > 0)
                {
                  setState(() {
                    remaningBreakTime--;
                  })
                }
              else
                {
                  _soundVibration(),
                  _cancelTimer(),
                  setState(() {
                    pomodoroStatus = PomodoroStatus.initPomodoro;
                    remaningBreakTime = breakTime;
                  }),
                }
            });
  }

  _cancelTimer() {
    if (_timer != null) {
      _timer.cancel();
    }
  }

  _pauseCountdown() {
    _cancelTimer();
    setState(() {
      pomodoroStatus = PomodoroStatus.pausedPomodoro;
    });
  }

  _resetCountdown() {
    _cancelTimer();
    setState(() {
      pomodoroStatus = PomodoroStatus.initPomodoro;
      remaningTime = pomodoroTotalTime;
      remaningBreakTime = breakTime;
    });
  }

  _pauseBreakCountdown() {
    _cancelTimer();
    setState(() {
      pomodoroStatus = PomodoroStatus.pausedBreak;
    });
  }

  _soundVibration() {
    HapticFeedback.mediumImpact();
    player.play('bell.mp3');
  }
}
