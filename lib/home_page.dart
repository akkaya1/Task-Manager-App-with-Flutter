// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
// shared_preferences
import 'package:shared_preferences/shared_preferences.dart';

// model / for our tasks
import './model/task.dart';

class HomePage extends StatefulWidget {
  // ROUTE NAME
  static const routeName = '/home_page';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // create _taskController
  // ignore: prefer_typing_uninitialized_variables
  var _taskController;

  // create tasks var
  // ignore: prefer_typing_uninitialized_variables
  var _tasks;

  // create _taskDone var
  // ignore: prefer_typing_uninitialized_variables
  var _taskDone;

  // saveData function for adding tasks
  void saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    AddTask t = AddTask.fromString(_taskController.text);
    //prefs.setString('taskName', json.encode(t.getMap()));
    //_taskController.text = "";

    String? tasks = prefs.getString('taskName');
    List tasksList = (tasks == null) ? [] : json.decode(tasks);
    //List tasksList = json.decode(tasks!);
    tasksList.add(json.encode(t.getMap()));
    prefs.setString('taskName', json.encode(tasksList));
    _taskController.text = "";
    Navigator.of(context).pop();

    _getTasks();
  }

  // create _getTasks method
  void _getTasks() async {
    _tasks = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasks = prefs.getString('taskName');
    List tasksList = (tasks == null) ? [] : json.decode(tasks);
    for (dynamic task in tasksList) {
      _tasks.add(AddTask.fromMap(json.decode(task)));
    }

    // generate a list length of _tasks' length and every item is false,
    // because at the start no task is done
    _taskDone = List.generate(_tasks.length, (index) => false);
    setState(() {});
  }

  // create a list for completed tasks
  final _completedTasks = [];

  // updateTasksList - to delete completed tasks
  void updateTasksList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List uncompletedTasks = [];

    for (var i = 0; i < _tasks.length; i++) {
      if (!_taskDone[i]) {
        uncompletedTasks.add(_tasks[i]);
      } else {
        _completedTasks.add(_tasks[i]);
      }
    }
    var uncompletedTasksEncoded = List.generate(uncompletedTasks.length,
        (i) => json.encode(uncompletedTasks[i].getMap()));
    prefs.setString('taskName', json.encode(uncompletedTasksEncoded));

    _getTasks();
  }

  // To show completed tasks
  void showCompletedTasks() async {
    showModalBottomSheet(
        context: context,
        builder: (context) => Column(
              children: [
                const ListTile(
                    title: Center(
                        child: Text(
                  "Completed Tasks",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ))),
                Column(
                  children: _completedTasks
                      .map<Widget>(
                        (e) => Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          padding: const EdgeInsets.only(left: 20),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color.fromRGBO(25, 25, 112, 1),
                                  width: 2)),
                          child: Row(
                            children: [
                              Text(e.taskName,
                                  style: const TextStyle(
                                    color: Color.fromRGBO(25, 25, 112, 1),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  )),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                )
              ],
            ));
  }

  @override
  void initState() {
    super.initState();
    // _taskController
    _taskController = TextEditingController();

    // call _getTasks method
    _getTasks();
  }

  @override
  void dispose() {
    super.dispose();
    // _taskController
    _taskController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(25, 25, 112, 1),
        title: const Text(
          'Task Manager',
        ),
        actions: [
          // Button to delete al the tasks
          IconButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('taskName', json.encode([]));
                _getTasks();
              },
              icon: const Icon(Icons.delete_sweep_outlined)),
          // Button to delete completed tasks
          IconButton(
              onPressed: updateTasksList, icon: const Icon(Icons.refresh)),
          // Button to show completed tasks
          IconButton(
              onPressed: showCompletedTasks,
              icon: const Icon(Icons.checklist_rtl))
        ],
      ),
      // Show all tasks in the Body
      body: (_tasks == null)
          ? const Center(
              child: Text('No tasks rn'),
            )
          : Column(
              children: _tasks
                  .map<Widget>(
                    (e) => Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color.fromRGBO(25, 25, 112, 1),
                              width: 2)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.taskName,
                            style: (_taskDone[_tasks.indexOf(e)])
                                ? const TextStyle(
                                    color: Color.fromRGBO(25, 25, 112, 1),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.lineThrough)
                                : const TextStyle(
                                    color: Color.fromRGBO(25, 25, 112, 1),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500),
                          ),
                          Checkbox(
                            value: _taskDone[_tasks.indexOf(e)],
                            key: GlobalKey(),
                            onChanged: (value) => setState(() {
                              _taskDone[_tasks.indexOf(e)] = value;
                            }),
                          )
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),

      // floatingActionButton is for ADD A TASK
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(25, 25, 112, 1),
        // when you press floatingActionButton, BottomSheet will be open
        // add a task page will show up
        onPressed: () => showModalBottomSheet(
          context: context,
          builder: (context) => Container(
            padding: const EdgeInsets.all(40),
            height: 250,
            color: const Color.fromRGBO(180, 200, 220, 1),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Add a task TEXT
                  const Text(
                    'Add a task',
                    style: TextStyle(
                      color: Color.fromRGBO(25, 25, 112, 1),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  // close button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close),
                  )
                ],
              ),
              // divider between 'add a task' text and 'input field'
              const Divider(
                thickness: 4,
              ),
              const SizedBox(
                height: 15,
              ),
              // input field for adding a new task
              TextField(
                // add a controller named _taskController
                controller: _taskController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(25, 25, 112, 1)),
                    ),
                    fillColor: const Color.fromRGBO(255, 255, 255, 0.6),
                    filled: true,
                    hintText: 'Enter a new task'),
              ),
              const SizedBox(
                height: 15,
              ),
              // button for adding a new task
              Container(
                padding: const EdgeInsets.only(top: 5),
                width: MediaQuery.of(context).size.width,
                height: 40,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 35,
                      child: ElevatedButton(
                        onPressed: () => saveData(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(25, 25, 112, 1),
                          textStyle: const TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 0.6),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        child: const Text('ADD'),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.center,
                    )
                  ],
                ),
              )
            ]),
          ),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
