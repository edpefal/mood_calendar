import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/mood_selector.dart';
import '../../data/models/mood_model.dart';
import '../../domain/entities/mood_entry.dart';
import '../bloc/mood_cubit.dart';
import 'calendar_screen.dart';
import 'package:hive/hive.dart';

class MoodScreen extends StatefulWidget {
  final DateTime? selectedDate;
  const MoodScreen({super.key, this.selectedDate});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  MoodOption? selectedMood = MoodSelector.moods.first;
  final TextEditingController _noteController = TextEditingController();
  bool isLoading = true;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadMoodForDate();
  }

  Future<void> _loadMoodForDate() async {
    final date = widget.selectedDate ?? DateTime.now();
    final moodBox = Hive.box<MoodModel>('moods');
    final moodModel = moodBox.get(date.toIso8601String());
    if (moodModel != null) {
      final idx =
          MoodSelector.moods.indexWhere((m) => m.emoji == moodModel.mood);
      setState(() {
        selectedMood = MoodSelector.moods[idx >= 0 ? idx : 0];
        _currentPage = idx >= 0 ? idx : 0;
        _pageController = PageController(initialPage: _currentPage);
        _noteController.text = moodModel.note ?? '';
        isLoading = false;
      });
    } else {
      setState(() {
        selectedMood = MoodSelector.moods.first;
        _currentPage = 0;
        _pageController = PageController(initialPage: 0);
        _noteController.clear();
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _saveMood() {
    final date = widget.selectedDate ?? DateTime.now();
    final moodEntry = MoodEntry(
      date: date,
      mood: selectedMood!.emoji,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      intensity: 3,
    );
    context.read<MoodCubit>().save(moodEntry);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return BlocConsumer<MoodCubit, MoodState>(
      listener: (context, state) {
        state.maybeWhen(
          saved: () {
            context.read<MoodCubit>().fetchAll();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CalendarScreen()),
            );
          },
          error: (msg) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.red),
            );
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE8EAF6),
                  Color(0xFFF3E5F5),
                  Color(0xFFE1BEE7),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Record Mood',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today,
                              color: Color(0xFF5F3DC4)),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const CalendarScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'How are you feeling today?',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    // Mood Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.15),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: MoodSelector.moods.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentPage = index;
                                    selectedMood = MoodSelector.moods[index];
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final mood = MoodSelector.moods[index];
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        mood.emoji,
                                        style: const TextStyle(fontSize: 96),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        mood.label,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                MoodSelector.moods.length,
                                (index) => Container(
                                  width: 8,
                                  height: 8,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentPage == index
                                        ? const Color(0xFF5F3DC4)
                                        : Colors.grey[300],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Note input
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Write a note...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Save button
                    GestureDetector(
                      onTap: _saveMood,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5F3DC4), Color(0xFF6C63FF)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
