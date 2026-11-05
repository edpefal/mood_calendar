## 1. ADR y glosario

- [x] 1.1 Escribir `docs/adr/0003-*.md` que reemplaza al ADR 0001: categorías con puntaje de 3 niveles (Positive y Peaceful alto, Neutral medio, Hard bajo), `intensity` solo identificador, ninguna categoría se presenta como mejor que otra; marcar el 0001 como reemplazado
- [x] 1.2 Actualizar `CONTEXT.md` (Categoría, Nivel, Log, estado Saved, Hoja de suscripción) respetando los "_Avoid_" existentes

## 2. Tokens, tema y widgets base

- [x] 2.1 Reemplazar `core/theme/brand_colors.dart` por una paleta con variante clara y oscura expuesta como `ThemeExtension` (tinta, superficies, vidrio, malla, texto secundario, tintes por categoría y rojo de Angry)
- [x] 2.2 Construir `ThemeData` claro y oscuro con Poppins y conectar `theme`, `darkTheme` y `themeMode` en `main.dart` y en `tool/screenshots/main.dart`
- [x] 2.3 Añadir la preferencia de tema (Sistema por defecto) a `AppSettings`, su datasource y repositorio, con un cubit raíz que la expone
- [x] 2.4 Crear el fondo de malla y la tarjeta de vidrio en `core/widgets/` con alternativa opaca ante reducir transparencia o alto contraste
- [x] 2.5 Convertir `GradientPillButton` en la píldora de tinta y revisar sus usos
- [x] 2.6 Reemplazar `test/core/theme/brand_colors_test.dart` por un test que recorra cada par texto/fondo en ambos brillos y falle bajo 4.5:1, incluidos los tintes de categoría
- [x] 2.7 Tests de la preferencia de tema (valor por defecto, persistencia, reversión si falla el guardado) y de la alternativa opaca

## 3. Categorías y catálogo

- [x] 3.1 Añadir `MoodCategory` (orden, nivel, tinte) y el campo `category` a `MoodDefinition`; quitar `color`
- [x] 3.2 Unificar el catálogo en una lista en el orden de pantalla con 11 `base` y 8 `premium` y los ids sin cambios
- [x] 3.3 Reescribir `MoodDefinitionResolver.backgroundGradientForMood` y todos los consumidores de `MoodDefinition.color` (calendario, resumen mensual, nota, reloj) sobre el tinte de categoría
- [x] 3.4 Confirmar que `MoodEntitlementsRepositoryImpl` y el repositorio de prueba siguen reconociendo los entitlements heredados con los nuevos tiers
- [x] 3.5 Tests del catálogo: 19 moods, 11/8, una categoría por mood, orden fijo, niveles, que `intensity` no interviene y que un mood sin categoría falla
- [x] 3.6 Añadir a `AppStrings` los nombres de las 4 categorías y de los textos de la píldora de nota y del saludo, en `en`, `es`, `de`, `fr` e `it`

## 4. Log: cuadrícula, nota y estado Saved

- [x] 4.1 Crear el widget de cuadrícula por categorías (4 columnas, 2 con texto grande, selección con anillo, bloqueados atenuados con candado y `Semantics`)
- [x] 4.2 Reescribir la pantalla del Log con los modos elegir y Saved dirigidos por `MoodCubit`: sin mood preseleccionado, Guardar deshabilitado, excepción de editar la nota con el mismo mood caducado, mensaje de error sin pasar a Saved
- [x] 4.3 Implementar el estado Saved: racha actual, tarjeta con mood, categoría y nota, botón Edit y el atajo "Forgot yesterday? Log it" solo si ayer no tiene entrada
- [x] 4.4 Encabezado con fecha, saludo por hora sin nombre y campana que activa Ajustes
- [x] 4.5 Píldora de nota con la pregunta por categoría y el indicador de nota; adaptar el editor de nota (mood y "Done" arriba, tinte de categoría)
- [x] 4.6 Calcular la racha actual (días consecutivos con entrada que terminan en la fecha guardada) con tests, incluido el cruce de mes y de año
- [x] 4.7 Eliminar `mood_picker_order.dart`, `mood_grid_sheet.dart` y sus tests; reescribir los tests de `MoodScreen`, `MoodCubit` y nota (incluye `dragPage` y los grupos de navegación)
- [x] 4.8 Mover el pedido de calificación de `CalendarScreen` al Log (tras el primer frame del estado Saved, sin registrar el intento si el usuario cambió de pestaña) y adaptar sus tests

## 5. Navegación, Calendar e Insights provisional

- [x] 5.1 Rediseñar `FloatingTabBar` (cápsula de tinta, nombres visibles, Log central con degradado) con ancho máximo en iPad y alternativa opaca
- [x] 5.2 Reorganizar `MainShell` en Calendar, Insights, Log y Settings con Log inicial, conservando el estado de las pestañas, y adaptar el recordatorio y el toque de un día del calendario para activar Log con su fecha
- [x] 5.3 Mostrar en el Log la tarjeta de la entrada (con Edit) al abrir una fecha con entrada, y bloquear las fechas futuras en el calendario
- [x] 5.4 Pantalla provisional de Insights con título y estado vacío localizado
- [x] 5.5 Reestilizar `CalendarScreen` y `MonthlySummaryCard` con vidrio y colores por categoría, sin cambiar su contenido
- [x] 5.6 Reescribir los tests de la barra y la navegación (pestañas, estado conservado, recordatorio, fechas futuras)

## 6. Ajustes

- [x] 6.1 Reorganizar `SettingsScreen` en las secciones Premium, Reminders, Privacy and data, Appearance y Help con filas de ícono, título, detalle y control; quitar las filas descartadas
- [x] 6.2 Fila Tema con selector Sistema/Claro/Oscuro, aplicación inmediata y reversión con mensaje si falla
- [x] 6.3 Fila Premium: "Get Premium" abre la hoja y, con suscripción, "Premium · Active" con plan y fecha abre la gestión de la tienda; fila "Restaurar compras"
- [x] 6.4 Filas "Enviar comentarios" (correo a `support@moodcalendar.app`) y "Términos" (versión en español si aplica), con mensaje si no se pueden abrir
- [x] 6.5 Textos de Ajustes en los 5 idiomas y etiquetas de `Semantics`; reescribir los tests de `SettingsCubit` y `SettingsScreen`

## 7. Hoja de suscripción

- [x] 7.1 Eliminar `PremiumScreen` y su pestaña; adaptar `PremiumSheet` y `PremiumPlansView`: título, tres beneficios, cápsula del mood opcional, tarjetas con anual preseleccionado y "Mejor valor" calculado, botón cerrar
- [x] 7.2 Prueba gratis solo con el anual seleccionado y elegible, línea de tiempo con "Hoy" y fecha del primer cobro, sin promesa de recordatorio
- [x] 7.3 Texto legal, enlaces y "Restaurar compras" en la hoja; recuperación de planes al abrirla; la hoja cubre la barra
- [x] 7.4 Cerrar la hoja al completar una compra y conservar fecha, selección y nota del Log; no ofrecer la hoja a suscriptores
- [x] 7.5 Analíticas: `source` = `locked_mood` o `settings` y fin del valor `tab`; adaptar `usage-analytics` y sus tests
- [x] 7.6 Textos de la hoja en los 5 idiomas; reescribir los tests de `PurchasesCubit` y de la hoja

## 8. Reloj y pantallas de captura

- [x] 8.1 Cambiar el acento de `ios/WatchApp/MoodGridView.swift` a la tinta de marca y verificar que el reloj lista los desbloqueados en el orden fijo por categoría (`PublishWatchStateUseCase`)
- [x] 8.2 Adaptar `tool/screenshots/main.dart` y los scripts de captura a las 4 pestañas y a la cuadrícula (sin recapturar ni subir nada)
- [x] 8.3 Adaptar los tests del reloj (`test/features/watch`) al nuevo catálogo y orden

## 9. Verificación y documentación

- [x] 9.1 `flutter analyze` y `flutter test` en verde
- [x] 9.2 Revisar en un simulador de iPhone y de iPad, en claro y oscuro, en inglés y alemán, con texto al 200 % y con reducir transparencia
- [ ] 9.3 Medir la fluidez del vidrio en un iPhone real o en el simulador más lento disponible
- [x] 9.4 Actualizar `CLAUDE.md` (estado actual, sistema de diseño, moods 11/8, flujo de Premium, pestañas), `README.md` y `backlog.md` (quitar la prueba del mensual y el semanal en las tiendas, requisito previo a publicar; el bloque no se publica solo)
- [x] 9.5 Un build de TestFlight del Bloque 1 solo si el usuario lo pide; no publicar versión ni recapturar capturas
