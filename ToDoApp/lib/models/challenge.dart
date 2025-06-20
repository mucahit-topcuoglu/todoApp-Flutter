import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String text;
  bool done;
  Todo({required this.text, this.done = false});

  Map<String, dynamic> toMap() => {'text': text, 'done': done};
  factory Todo.fromMap(Map<String, dynamic> map) =>
      Todo(text: map['text'] ?? '', done: map['done'] ?? false);
}

class Challenge {
  String id;
  String title;
  String description;
  String category;
  DateTime startDate;
  List<Todo> todos;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.startDate,
    required this.todos,
  });

  factory Challenge.fromMap(String id, Map<String, dynamic> map) {
    return Challenge(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      todos: (map['todos'] as List<dynamic>? ?? [])
          .map((e) => Todo.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'startDate': startDate,
      'todos': todos.map((e) => e.toMap()).toList(),
    };
  }
} 