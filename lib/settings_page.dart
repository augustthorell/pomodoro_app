import 'package:flutter/material.dart';
import 'package:pomodoro_app/todo.dart';

class NewTodoView extends StatefulWidget {
  final Todo item;
  final increment;
  final decrement;
  final int pomodoroTotalTime;
  final int breakTime;
  final List list;
  final addItem;
  final removeItem;
  /*  String currentTodo;
  Function(String) callback; */

  NewTodoView({
    this.item,
    this.increment,
    this.pomodoroTotalTime,
    this.breakTime,
    this.decrement,
    this.list,
    this.addItem,
    this.removeItem,
    /* this.callback,
    this.currentTodo, */
  });
  @override
  _NewTodoViewState createState() => _NewTodoViewState();
}

class _NewTodoViewState extends State<NewTodoView>
    with SingleTickerProviderStateMixin {
  TextEditingController titleController;

  final String workTime = 'Work Time';
  final String breakTime = 'Break Time';

  int workTimeSettings;
  int breakTimeSettings;

  void initState() {
    workTimeSettings = widget.pomodoroTotalTime;
    breakTimeSettings = widget.breakTime;
    super.initState();
    titleController = new TextEditingController(
        text: widget.item != null ? widget.item.title : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.item != null ? 'Edit todo' : 'Settings',
            key: Key('new-item-title'),
          ),
          centerTitle: true,
        ),
        body: ListView(
          children: <Widget>[
            Container(
              height: 200,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 14.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      setTimer(
                        workTime,
                        workTimeSettings,
                        widget.increment,
                        widget.decrement,
                      ),
                      setTimer(
                        breakTime,
                        breakTimeSettings,
                        widget.increment,
                        widget.decrement,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  addTodoField(),
                ],
              ),
            ),
            Container(
              height: 10,
              child: const Divider(
                height: 5,
                thickness: 2,
                indent: 25,
                endIndent: 25,
                color: Colors.white,
              ),
            ),
            Container(
              height: 5000,
              child: todos(),
            ),
            /* todos(), */
          ],
        ));
  }

  Widget todos() {
    return ReorderableListView(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      children: <Widget>[
        for (int index = 0; index < widget.list.length; index++)
          ListTile(
            key: Key('$index'),
            title: Text(
              '${widget.list[index]}'.replaceAll('Todo:', ''),
              style: TextStyle(color: Colors.white),
            ),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Icon(Icons.menu),
              IconButton(
                onPressed: () {
                  setState(() {});
                },
                icon: Icon(Icons.cancel),
              )
            ]),
          ),
      ],
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final int item = widget.list.removeAt(oldIndex);
          widget.list.insert(newIndex, item);
        });
      },
    );
  }

  Widget setTimer(title, timeMinutes, increment, decrement) {
    final name = title;
    return Column(
      children: [
        Text(name, style: TextStyle(color: Colors.white)),
        Row(
          children: [
            incrementButton(title),
            Text(
              (timeMinutes / 60)
                      .toString()
                      .replaceAll(RegExp(r"([.]*0)(?!.*\d)"), '') +
                  ' Minutes',
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
            decrementButton(title),
          ],
        )
      ],
    );
  }

  Widget incrementButton(item) {
    return IconButton(
      color: Colors.white,
      icon: Icon(Icons.add),
      onPressed: () {
        if (item == 'Work Time') {
          widget.increment(item);
          _incrementSettings(item);
          /*  widget.callback('Current Todo'); */
        } else {
          widget.increment(item);
          _incrementSettings(item);
        }
      },
    );
  }

  Widget decrementButton(item) {
    return IconButton(
      color: Colors.white,
      icon: Icon(Icons.remove),
      onPressed: () {
        if (item == 'Work Time') {
          widget.decrement(item);
          _decrementSettings(item);
        } else {
          widget.decrement(item);
          _decrementSettings(item);
        }
      },
    );
  }

  _incrementSettings(item) {
    if (item == 'Work Time') {
      setState(() {
        workTimeSettings += 60;
      });
    } else {
      setState(() {
        breakTimeSettings += 60;
      });
    }
  }

  _decrementSettings(item) {
    if (item == 'Work Time') {
      if (workTimeSettings <= 60) {
        setState(() {
          workTimeSettings = 60;
        });
      } else {
        setState(() {
          workTimeSettings -= 60;
        });
      }
    } else {
      if (breakTimeSettings <= 60) {
        setState(() {
          breakTimeSettings = 60;
        });
      } else {
        setState(() {
          breakTimeSettings -= 60;
        });
      }
    }
  }

  Widget addTodoField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        style: TextStyle(color: Colors.white),
        controller: titleController,
        onSubmitted: (value) => submit(),
        decoration: InputDecoration(
          hintText: 'Add Todo',
          hintStyle: TextStyle(color: Colors.white),
          suffixIcon: IconButton(
            onPressed: () => submit(),
            color: Colors.white,
            icon: Icon(Icons.add),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 1.0),
            borderRadius: const BorderRadius.all(const Radius.circular(30)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey, width: 2.0),
            borderRadius: const BorderRadius.all(const Radius.circular(30)),
          ),
        ),
      ),
    );
  }

  void submit() {
    FocusScope.of(context).unfocus();
    print(titleController.text);
    widget.addItem(Todo(title: titleController.text));
    setState(() {});
    titleController.clear();
  }
}
