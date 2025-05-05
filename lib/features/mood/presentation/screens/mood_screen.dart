import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/mood_selector.dart';
import '../../data/models/mood_model.dart';
import '../../domain/entities/mood_entry.dart';
import '../bloc/mood_cubit.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  MoodOption? selectedMood = MoodSelector.moods.first;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _saveMood() {
    final moodEntry = MoodEntry(
      date: DateTime.now(),
      mood: selectedMood!.emoji,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      intensity: 3,
    );
    context.read<MoodCubit>().save(moodEntry);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MoodCubit, MoodState>(
      listener: (context, state) {
        state.maybeWhen(
          saved: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Estado de ánimo guardado')),
            );
            setState(() {
              selectedMood = MoodSelector.moods.first;
              _noteController.clear();
            });
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
            title: const Text('Registrar Estado de Ánimo'),
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
