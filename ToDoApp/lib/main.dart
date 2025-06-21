import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui';
import 'models/challenge.dart';
import 'firebase_options.dart';
import 'screens/challenge_list_screen.dart';
import 'screens/monthly_report_screen.dart';
import 'screens/challenge_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '15 Günlük Challenge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF181818),
        scaffoldBackgroundColor: const Color(0xFF181818),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD4AF37)),
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFFD4AF37)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFD4AF37),
          foregroundColor: Colors.black,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF181818),
        scaffoldBackgroundColor: const Color(0xFF181818),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD4AF37), brightness: Brightness.dark),
        textTheme: GoogleFonts.montserratTextTheme(
          ThemeData.dark().textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFFD4AF37)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFD4AF37),
          foregroundColor: Colors.black,
        ),
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/challengeDetail') {
          return MaterialPageRoute(
            builder: (context) => const ChallengeDetailScreen(),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (context) => const MainNavigation(),
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const ChallengeListScreen(),
    const MonthlyReportScreen(),
    // Profil veya ayarlar ekranı eklenebilir
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            selectedItemColor: const Color(0xFFD4AF37),
            unselectedItemColor: Colors.white70,
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.flag),
                label: 'Challenge',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Rapor',
              ),
            ],
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            showUnselectedLabels: false,
          ),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  const GlassCard({required this.child, this.margin, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

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
                            Text('Başlangıç: ${challenge.startDate.toLocal().toString().split(' ')[0]}', style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white38)),
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
                  labelText: 'Gün ${i + 1} Görevi',
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
                              Text('Başlangıç: ${challenge.startDate.toLocal().toString().split(' ')[0]}', style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white38)),
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
      todo.text.isNotEmpty ? todo.text : 'Gün ${index + 1}',
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
