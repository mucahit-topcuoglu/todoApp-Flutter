import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/challenge.dart';
import 'glass_card.dart';

class ChallengeDetailScreen extends StatefulWidget {
  const ChallengeDetailScreen({Key? key}) : super(key: key);

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  late Challenge challenge;
  late List<Todo> todos;
  late String title;
  late String description;
  late String category;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Challenge) {
      challenge = args;
      todos = List<Todo>.from(challenge.todos);
      title = challenge.title;
      description = challenge.description;
      category = challenge.category;
    }
  }

  Future<void> _toggleDone(int index) async {
    setState(() {
      todos[index] = Todo(text: todos[index].text, done: !todos[index].done);
    });
    await FirebaseFirestore.instance.collection('challenges').doc(challenge.id).update({
      'todos': todos.map((e) => e.toMap()).toList(),
    });
  }

  Future<void> _editTodo(int index) async {
    final controller = TextEditingController(text: todos[index].text);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Görevi Düzenle'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Görev'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && result != todos[index].text) {
      setState(() {
        todos[index] = Todo(text: result, done: todos[index].done);
      });
      await FirebaseFirestore.instance.collection('challenges').doc(challenge.id).update({
        'todos': todos.map((e) => e.toMap()).toList(),
      });
    }
  }

  Future<void> _deleteTodo(int index) async {
    setState(() {
      todos.removeAt(index);
    });
    await FirebaseFirestore.instance.collection('challenges').doc(challenge.id).update({
      'todos': todos.map((e) => e.toMap()).toList(),
    });
  }

  Future<void> _editTitle() async {
    final controller = TextEditingController(text: title);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Challenge Başlığını Düzenle'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Başlık'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && result != title) {
      await FirebaseFirestore.instance.collection('challenges').doc(challenge.id).update({
        'title': result,
      });
      setState(() {
        title = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (challenge == null) {
      return const Scaffold(
        body: Center(child: Text('Challenge bulunamadı.')),
      );
    }
    final completedTodos = todos.where((t) => t.done).length;
    final percent = todos.isNotEmpty ? (completedTodos / todos.length * 100).toStringAsFixed(0) : '0';
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF181818), Color(0xFF232526)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 26, color: const Color(0xFFD4AF37))),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editTitle,
              tooltip: 'Başlığı Düzenle',
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flag, color: Color(0xFFD4AF37)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      if (description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Row(
                            children: [
                              const Icon(Icons.notes, size: 18, color: Color(0xFFD4AF37)),
                              const SizedBox(width: 6),
                              Expanded(child: Text(description, style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white70))),
                            ],
                          ),
                        ),
                      if (category.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Chip(
                            label: Text(category),
                            backgroundColor: const Color(0xFFD4AF37),
                            labelStyle: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold),
                            avatar: const Icon(Icons.category, color: Colors.black, size: 18),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 14.0),
                        child: LinearProgressIndicator(
                          value: todos.isNotEmpty ? completedTodos / todos.length : 0,
                          backgroundColor: Colors.white12,
                          color: const Color(0xFFD4AF37),
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text('Tamamlanma: %$percent', style: GoogleFonts.montserrat(fontSize: 15, color: Color(0xFFD4AF37))),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ...List.generate(todos.length, (index) {
                  final todo = todos[index];
                  return GlassCard(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                    child: ListTile(
                      leading: Checkbox(
                        value: todo.done,
                        onChanged: (_) => _toggleDone(index),
                        activeColor: const Color(0xFFD4AF37),
                      ),
                      title: Text(todo.text, style: GoogleFonts.montserrat(fontSize: 16, color: todo.done ? Colors.white38 : Colors.white)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFFD4AF37)),
                            onPressed: () => _editTodo(index),
                            tooltip: 'Düzenle',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _deleteTodo(index),
                            tooltip: 'Sil',
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 