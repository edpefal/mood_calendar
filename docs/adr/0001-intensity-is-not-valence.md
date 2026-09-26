# Intensity is an identifier, not a valence score — monthly summary uses mode, not mean

Hasta ahora `intensity` (1–5) era a la vez el identificador de un Mood y su posición en una escala de valencia emocional lineal (happy=1 → angry=5), y el resumen mensual promediaba ese número para calcular un "mood representativo del mes".

Al introducir moods premium con IAP, el catálogo de Moods pasó a ser abierto y creciente (nuevos moods se agregan indefinidamente), y varios de los moods nuevos (ej. "confident", "romantic", "shy") no caen de forma natural en una sola recta feliz↔enojado. Forzarlos a un punto de esa escala habría hecho que el promedio mensual produjera resultados engañosos (ej. un mes de puro "confident" podía dar un promedio "peor" que un mes de puro "angry", solo por el orden en que se agregó ese mood al catálogo).

Se decidió que `intensity` sea puramente un identificador interno por Mood, sin ninguna relación de orden o "mejor/peor" entre Moods. Como consecuencia, el promedio mensual (`averageScore`) se eliminó y se reemplazó por **Most Common Mood**: el Mood más registrado en el mes (moda), con desempate por fecha de registro más reciente. La racha (`bestStreak`) no cambió, porque nunca dependió del valor de intensidad.

Se consideró mantener `intensity` como una escala de valencia interna oculta (nunca mostrada al usuario) solo para que el promedio siguiera siendo matemáticamente honesto, pero se descartó: habría requerido asignar manualmente un valor de valencia a cada mood nuevo para siempre, y el objetivo explícito era que ningún mood pudiera leerse como "mejor o peor" que otro, ni siquiera puertas adentro.
