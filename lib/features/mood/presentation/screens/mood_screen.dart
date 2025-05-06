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

  @override
  void initState() {
    super.initState();
    _loadMoodForDate();
  }

  Future<void> _loadMoodForDate() async {
    final date = widget.selectedDate ?? DateTime.now();
    final moodBox = Hive.box<MoodModel>('moods');
    final moodModel = moodBox.get(date.toIso8601String());
    if (moodModel != null) {
      setState(() {
        selectedMood = MoodSelector.moods.firstWhere(
          (m) => m.emoji == moodModel.mood,
          orElse: () => MoodSelector.moods.first,
        );
        _noteController.text = moodModel.note ?? '';
        isLoading = false;
      });
    } else {
      setState(() {
        selectedMood = MoodSelector.moods.first;
        _noteController.clear();
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
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
          appBar: AppBar(
            title: Text(
              widget.selectedDate != null
                  ? 'Edit Mood (${widget.selectedDate!.day}/${widget.selectedDate!.month}/${widget.selectedDate!.year})'
                  : 'Registrar Estado de Ánimo',
            ),
          ),
          body: state.maybeWhen(
            loading: () => const Center(child: CircularProgressIndicator()),
            orElse: () => SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MoodSelector(
                    selectedMood: selectedMood,
                    onMoodSelected: (mood) {
                      setState(() {
                        selectedMood = mood;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Nota (opcional)',
                      border: OutlineInputBorder(),
                      hintText: '¿Quieres agregar algo más?',
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveMood,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor:
                          selectedMood?.color ?? Theme.of(context).primaryColor,
                    ),
                    child: const Text(
                      'Guardar',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
