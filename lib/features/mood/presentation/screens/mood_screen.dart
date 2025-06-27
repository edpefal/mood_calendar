import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/models/mood_model.dart';
import '../../domain/entities/mood_entry.dart';
import '../bloc/mood_cubit.dart';
import 'calendar_screen.dart';
import 'package:hive/hive.dart';
import 'package:mood_calendar/features/ads/ad_service.dart';

class MoodScreen extends StatefulWidget {
  final DateTime? selectedDate;
  const MoodScreen({super.key, this.selectedDate});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen>
    with SingleTickerProviderStateMixin {
  MoodOption selectedMood = moods.first;
  int _currentPage = 0;
  final TextEditingController _noteController = TextEditingController();
  bool isLoading = true;
  late PageController _pageController;
  late final AdService _adService;

  @override
  void initState() {
    super.initState();
    _adService = AdService();
    _adService.loadInterstitialAd();
    _pageController = PageController(initialPage: 0);
    _loadMoodForDate();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadMoodForDate() async {
    final date = widget.selectedDate ?? DateTime.now();
    final moodBox = Hive.box<MoodModel>('moods');
    final moodModel = moodBox.get(date.toIso8601String());
    if (moodModel != null) {
      final idx = moods.indexWhere((m) => m.animationPath == moodModel.mood);
      setState(() {
        selectedMood = moods[idx >= 0 ? idx : 0];
        _currentPage = idx >= 0 ? idx : 0;
        _noteController.text = moodModel.note ?? '';
        isLoading = false;
      });
      _pageController = PageController(initialPage: _currentPage);
    } else {
      setState(() {
        selectedMood = moods.first;
        _currentPage = 0;
        _noteController.clear();
        isLoading = false;
      });
      _pageController = PageController(initialPage: 0);
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
      selectedMood = moods[index];
    });
  }

  void _saveMood() {
    final save = () {
      final date = widget.selectedDate ?? DateTime.now();
      final moodEntry = MoodEntry(
        date: date,
        mood: selectedMood.animationPath,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        intensity: 3,
      );
      context.read<MoodCubit>().save(moodEntry);
    };

    if (_adService.shouldShowAd()) {
      _adService.showInterstitialAd(onAdDismissed: save);
    } else {
      save();
    }
  }

  LinearGradient _backgroundGradientForMood(MoodOption mood) {
    switch (mood.label.toLowerCase()) {
      case 'happy':
        return const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'calm':
        return const LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'neutral':
        return const LinearGradient(
          colors: [Color(0xFFF5F5F5), Color(0xFFEEEEEE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'sad':
        return const LinearGradient(
          colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'angry':
        return const LinearGradient(
          colors: [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
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
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CalendarScreen()),
              );
            }
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
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: _backgroundGradientForMood(selectedMood),
            ),
            child: SafeArea(
              child: SizedBox.expand(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Header y pregunta
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDate(
                                    widget.selectedDate ?? DateTime.now()),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.calendar_today,
                                    color: Color(0xFF5F3DC4)),
                                onPressed: () {
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  } else {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const CalendarScreen()),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'How are you feeling today?',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF5F3DC4),
                                ),
                          ),
                        ],
                      ),
                      // Animación y label
                      Column(
                        children: [
                          SizedBox(
                            height: 220,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: moods.length,
                              onPageChanged: _onPageChanged,
                              itemBuilder: (context, index) {
                                final mood = moods[index];
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      mood.animationPath,
                                      height: 150,
                                      width: 150,
                                      fit: BoxFit.contain,
                                      placeholderBuilder: (context) =>
                                          const CircularProgressIndicator(),
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        print('Error loading SVG: $error');
                                        return const Icon(
                                          Icons.error_outline,
                                          size: 150,
                                          color: Colors.red,
                                        );
                                      },
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
                              moods.length,
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
                      // Nota y botón
                      Column(
                        children: [
                          // TextField(
                          //   controller: _noteController,
                          //   maxLines: 3,
                          //   decoration: InputDecoration(
                          //     hintText: 'Write a note...',
                          //     filled: true,
                          //     fillColor: Colors.white,
                          //     border: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(16),
                          //       borderSide: BorderSide.none,
                          //     ),
                          //     contentPadding: const EdgeInsets.symmetric(
                          //         horizontal: 16, vertical: 12),
                          //   ),
                          // ),
                          // const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _saveMood,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF5F3DC4),
                                    Color(0xFF6C63FF)
                                  ],
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class MoodOption {
  final String animationPath;
  final String label;
  final Color color;

  const MoodOption({
    required this.animationPath,
    required this.label,
    required this.color,
  });
}

const List<MoodOption> moods = [
  MoodOption(
    animationPath: 'assets/icon/happy.svg',
    label: 'Happy',
    color: Colors.green,
  ),
  MoodOption(
    animationPath: 'assets/icon/calm.svg',
    label: 'Calm',
    color: Colors.blue,
  ),
  MoodOption(
    animationPath: 'assets/icon/neutral.svg',
    label: 'Neutral',
    color: Colors.grey,
  ),
  MoodOption(
    animationPath: 'assets/icon/sad.svg',
    label: 'Sad',
    color: Colors.orange,
  ),
  MoodOption(
    animationPath: 'assets/icon/angry.svg',
    label: 'Angry',
    color: Colors.red,
  ),
];
