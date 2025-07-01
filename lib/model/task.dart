import 'package:objectbox/objectbox.dart';

@Entity()
class Task {
  @Id()
  int id = 0; // ObjectBox requires `int` id for primary key

  String taskId;
  String title;
  String description;
  DateTime dateTime;

  Task({
    this.id = 0, // default 0 for new objects
    required this.taskId,
    required this.title,
    required this.description,
    required this.dateTime,
  });
}
