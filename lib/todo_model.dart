import 'package:hive/hive.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)
class TodoModel{
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String detail;
  @HiveField(2)
  final bool isCompleted;
  @HiveField(3)
  final DateTime date;
  TodoModel({this.title, this.detail, this.isCompleted, this.date});

}