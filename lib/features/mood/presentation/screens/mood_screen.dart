import 'package:flutter/material.dart';
import '../widgets/mood_selector.dart';
import '../../data/models/mood_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

  Future<void> _saveMood() async {
    if (selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor selecciona un estado de ánimo')),
      );
      return;
    }

    final moodBox = Hive.box<MoodModel>('moods');
    final mood = MoodModel(
      date: DateTime.now(),
      mood: selectedMood!.emoji,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      intensity: 3, // Valor fijo por ahora
    );

    await moodBox.put(mood.date.toIso8601String(), mood);

    // Verificar que se guardó correctamente
    final savedMood = moodBox.get(mood.date.toIso8601String());
    if (savedMood != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estado de ánimo guardado: ${savedMood.mood}'),
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() {
          selectedMood = MoodSelector.moods.first;
          _noteController.clear();
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar el estado de ánimo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Estado de Ánimo'),
      ),
      body: SingleChildScrollView(
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
    );
  }
}
