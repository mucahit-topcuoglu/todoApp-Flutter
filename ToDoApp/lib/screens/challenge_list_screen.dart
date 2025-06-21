import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../models/challenge.dart';
import 'glass_card.dart';

class ChallengeListScreen extends StatelessWidget {
  const ChallengeListScreen({Key? key}) : super(key: key);

  static const List<String> categories = [
    'Sağlık', 'Spor', 'Kariyer', 'Kişisel Gelişim', 'Alışkanlık', 'Diğer'
  ];

  @override
  Widget build(BuildContext context) {
    final CollectionReference challengesRef = FirebaseFirestore.instance.collection('challenges');

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('15 Günlük Challenge', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 26, color: const Color(0xFFD4AF37))),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: challengesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 180,
                    width: 180,
                    child: Lottie.asset(
                      'assets/lottie/empty.json',
                      width: 180,
                      height: 180,
                      repeat: true,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.inbox_outlined,
                          size: 80,
                          color: Colors.white54,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Henüz challenge yok. Hemen bir tane ekle!',
                      style: GoogleFonts.montserrat(fontSize: 18, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }
          final challenges = snapshot.data!.docs.map((doc) => Challenge.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: challenges.length + 1,
            itemBuilder: (context, index) {
              if (index == challenges.length) return const SizedBox(height: 100);
              final challenge = challenges[index];
              final completedDays = challenge.todos.where((t) => t.done).length;
              final percent = challenge.todos.isNotEmpty ? (completedDays / challenge.todos.length * 100).toStringAsFixed(0) : '0';
              return GlassCard(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  title: Row(
                    children: [
                      const Icon(Icons.flag, color: Color(0xFFD4AF37)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          challenge.title,
                          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (challenge.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Row(
                            children: [
                              const Icon(Icons.notes, size: 18, color: Color(0xFFD4AF37)),
                              const SizedBox(width: 6),
                              Expanded(child: Text(challenge.description, style: GoogleFonts.montserrat(fontSize: 15, color: Colors.white70))),
                            ],
                          ),
                        ),
                      if (challenge.category.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Chip(
                            label: Text(challenge.category),
                            backgroundColor: const Color(0xFFD4AF37),
                            labelStyle: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold),
                            avatar: const Icon(Icons.category, color: Colors.black, size: 18),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.white38),
                            const SizedBox(width: 4),
                            Text('Başlangıç: ${challenge.startDate.toLocal().toString().split(' ')[0]}', style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white38)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: LinearProgressIndicator(
                          value: completedDays / 15,
                          backgroundColor: Colors.white12,
                          color: const Color(0xFFD4AF37),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text('Tamamlanma: %$percent', style: GoogleFonts.montserrat(fontSize: 13, color: Color(0xFFD4AF37))),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        tooltip: 'Sil',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Challenge Sil'),
                              content: const Text('Bu challenge kalıcı olarak silinsin mi?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('İptal'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Sil'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await challengesRef.doc(challenge.id).delete();
                          }
                        },
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios, color: Color(0xFFD4AF37)),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/challengeDetail',
                      arguments: challenge,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton(
          mini: true,
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (context) => AddChallengeDialog(challengesRef: challengesRef),
            );
          },
          child: const Icon(Icons.add),
          tooltip: 'Challenge Ekle',
        ),
      ),
    );
  }
}

class AddChallengeDialog extends StatefulWidget {
  final CollectionReference challengesRef;
  const AddChallengeDialog({Key? key, required this.challengesRef}) : super(key: key);

  @override
  State<AddChallengeDialog> createState() => _AddChallengeDialogState();
}

class _AddChallengeDialogState extends State<AddChallengeDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  List<TextEditingController> _todoControllers = List.generate(15, (_) => TextEditingController());

  static const List<String> categories = [
    'Sağlık', 'Spor', 'Kariyer', 'Kişisel Gelişim', 'Alışkanlık', 'Diğer'
  ];

  @override
  void dispose() {
    for (var c in _todoControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Yeni Challenge Ekle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Başlık', prefixIcon: Icon(Icons.flag)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Açıklama', prefixIcon: Icon(Icons.notes)),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
              decoration: const InputDecoration(labelText: 'Kategori', prefixIcon: Icon(Icons.category)),
              borderRadius: BorderRadius.circular(16),
            ),
            const SizedBox(height: 18),
            const Text('15 Günlük Görevler', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...List.generate(15, (i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: TextField(
                controller: _todoControllers[i],
                decoration: InputDecoration(
                  labelText: 'Gün ${i + 1} Görevi',
                  prefixIcon: const Icon(Icons.check_box_outline_blank),
                ),
              ),
            )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () async {
            final title = _titleController.text.trim();
            final description = _descriptionController.text.trim();
            final category = _selectedCategory ?? '';
            final todos = _todoControllers.map((c) => {'text': c.text.trim(), 'done': false}).toList();
            if (title.isNotEmpty && todos.every((t) => t['text'] != '')) {
              await widget.challengesRef.add({
                'title': title,
                'description': description,
                'category': category,
                'startDate': DateTime.now(),
                'todos': todos,
              });
              Navigator.pop(context);
            }
          },
          child: const Text('Ekle'),
        ),
      ],
    );
  }
}

// You may want to move GlassCard to a shared widgets file if used in multiple screens. 