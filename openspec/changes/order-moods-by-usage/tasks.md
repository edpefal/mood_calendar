## 1. Lógica de ordenamiento

- [x] 1.1 Crear `MoodPickerOrder.sort(entries, isUnlocked)` en `lib/features/mood/domain/services/mood_picker_order.dart` (desbloqueados por frecuencia desc con desempate por orden del catálogo, luego bloqueados en orden del catálogo)
- [x] 1.2 Tests unitarios en `test/features/mood/domain/services/mood_picker_order_test.dart`: sin historial = orden del catálogo, orden por frecuencia, empate, premium comprado entra al grupo ordenado, bloqueados al final aunque tengan historial, no usa `intensity`

## 2. Integración en MoodScreen

- [x] 2.1 Confirmar cuándo queda lista la información de compras en `PurchasesCubit` y asegurar que el orden se calcula con ella (usa `isMoodUnlockedNow`, lectura síncrona del repositorio)
- [x] 2.2 Añadir `_orderedMoods` en `mood_screen.dart`, calculado una sola vez en la primera hidratación de `MoodState.loaded`
- [x] 2.3 Reemplazar `allMoodDefinitions` por `_orderedMoods` en página inicial, `_applyMoodEntry`, `_onPageChanged`, Semantics, `itemCount`/`itemBuilder` e indicadores
- [x] 2.4 `selectedMood` inicial = primer Mood ordenado cuando la fecha no tiene entrada

## 3. Tests de widget

- [x] 3.1 `MoodScreen` sin historial muestra el orden del catálogo
- [x] 3.2 `MoodScreen` con historial muestra primero el Mood más usado y lo preselecciona en una fecha sin entrada
- [x] 3.3 Editar una entrada existente posiciona el carrusel en su Mood aunque no esté en su posición de catálogo
- [x] 3.4 El orden no cambia tras desbloquear un Mood con la pantalla abierta (guardar cierra la pantalla, así que no aplica)

## 4. Cierre

- [x] 4.1 `flutter analyze` y `flutter test` en verde
- [x] 4.2 Verificación manual en simulador: primer uso y uso con historial
