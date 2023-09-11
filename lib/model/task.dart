class AddTask {
  String taskName;
  DateTime creationTime;

  AddTask({required this.taskName, required this.creationTime});

  factory AddTask.fromString(String taskName) {
    return AddTask(taskName: taskName, creationTime: DateTime.now());
  }

  factory AddTask.fromMap(Map<String, dynamic> map) {
    return AddTask(
        taskName: map['taskName'],
        creationTime: DateTime.fromMillisecondsSinceEpoch(map['creationTime']));
  }

  Map<String, dynamic> getMap() {
    return {
      'taskName': taskName,
      'creationTime': creationTime.millisecondsSinceEpoch
    };
  }
}
