import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../models/challenge.dart';
import 'glass_card.dart';

class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CollectionReference challengesRef = FirebaseFirestore.instance.collection('challenges');
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Aylık Rapor', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 26, color: const Color(0xFFD4AF37))),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: challengesRef
            .where('startDate', isGreaterThanOrEqualTo: firstDayOfMonth)
            .where('startDate', isLessThanOrEqualTo: lastDayOfMonth)
            .snapshots(),
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
                          Icons.bar_chart_outlined,
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
                      'Bu ay için challenge yok.',
                      style: GoogleFonts.montserrat(fontSize: 18, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }
          final challenges = snapshot.data!.docs.map((doc) => Challenge.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
          final totalChallenges = challenges.length;
          final completedChallenges = challenges.where((c) => c.todos.isNotEmpty && c.todos.every((t) => t.done)).length;
          final totalTodos = challenges.fold<int>(0, (sum, c) => sum + c.todos.length);
          final totalCompletedTodos = challenges.fold<int>(0, (sum, c) => sum + c.todos.where((t) => t.done).length);
          final avgProgress = totalChallenges > 0 ? (totalCompletedTodos / (totalTodos > 0 ? totalTodos : 1) * 100).toStringAsFixed(1) : '0';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Aylık Genel İstatistikler', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFFD4AF37))),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _statBox('Toplam Challenge', '$totalChallenges'),
                          _statBox('Tamamlanan', '$completedChallenges'),
                          _statBox('Ortalama İlerleme', '%$avgProgress'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _statBox('Toplam Görev', '$totalTodos'),
                          _statBox('Tamamlanan Görev', '$totalCompletedTodos'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              ...challenges.map((challenge) {
                final completedDays = challenge.todos.where((t) => t.done).length;
                final percent = challenge.todos.isNotEmpty ? (completedDays / challenge.todos.length * 100).toStringAsFixed(0) : '0';
                return GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.flag, color: Color(0xFFD4AF37)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                challenge.title,
                                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                              ),
                            ),
                            if (completedDays == challenge.todos.length && challenge.todos.isNotEmpty)
                              const Icon(Icons.verified, color: Colors.green, size: 28),
                          ],
                        ),
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
                            value: challenge.todos.isNotEmpty ? completedDays / challenge.todos.length : 0,
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
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (int i = 0; i < challenge.todos.length; i++)
                              _todoChip(challenge.todos[i], i),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 100),
            ],
          );
        },
      ),
    );
  }
}

Widget _statBox(String label, String value) {
  return Column(
    children: [
      Text(value, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
      const SizedBox(height: 2),
      Text(label, style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white70)),
    ],
  );
}

Widget _todoChip(Todo todo, int index) {
  return Chip(
    label: Text(
      todo.text.isNotEmpty ? todo.text : 'Gün ${index + 1}',
      style: GoogleFonts.montserrat(fontSize: 12, color: todo.done ? Colors.white : Colors.black),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    ),
    backgroundColor: todo.done ? const Color(0xFFD4AF37) : Colors.white24,
    avatar: Icon(
      todo.done ? Icons.check_circle : Icons.radio_button_unchecked,
      color: todo.done ? Colors.green : Colors.grey,
      size: 18,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
} 