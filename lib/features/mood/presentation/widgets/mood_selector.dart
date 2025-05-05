import 'package:flutter/material.dart';

class MoodOption {
  final String emoji;
  final String label;
  final Color color;

  const MoodOption({
    required this.emoji,
    required this.label,
    required this.color,
  });
}

class MoodSelector extends StatefulWidget {
  static const List<MoodOption> moods = [
    MoodOption(emoji: '😊', label: 'Feliz', color: Colors.green),
    MoodOption(emoji: '😌', label: 'Tranquilo', color: Colors.blue),
    MoodOption(emoji: '😐', label: 'Neutral', color: Colors.grey),
    MoodOption(emoji: '😔', label: 'Triste', color: Colors.orange),
    MoodOption(emoji: '😡', label: 'Enojado', color: Colors.red),
  ];

  final Function(MoodOption) onMoodSelected;
  final MoodOption? selectedMood;

  const MoodSelector({
    super.key,
    required this.onMoodSelected,
    this.selectedMood,
  });

  @override
  State<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.selectedMood != null
          ? MoodSelector.moods
              .indexWhere((m) => m.emoji == widget.selectedMood!.emoji)
          : 0,
      viewportFraction: 0.8,
    );
    _currentPage = _pageController.initialPage;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '¿Cómo te sientes hoy?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              widget.onMoodSelected(MoodSelector.moods[index]);
            },
            itemCount: MoodSelector.moods.length,
            itemBuilder: (context, index) {
              final mood = MoodSelector.moods[index];
              final isSelected = _currentPage == index;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? mood.color.withOpacity(0.2)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? mood.color : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: mood.color.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      mood.emoji,
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      mood.label,
                      style: TextStyle(
                        fontSize: 24,
                        color: isSelected ? mood.color : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            MoodSelector.moods.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? MoodSelector.moods[index].color
                    : Colors.grey[300],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
