## 1. Añadir getter noteHint a todas las clases de localización

- [x] 1.1 En `app_strings.dart`: añadir `String get noteHint;` a la clase abstracta y mover `Locale('en')` al primer lugar en `supportedLocales`
- [x] 1.2 En `app_strings_en.dart`: añadir `String get noteHint => 'Write a note...';`
- [x] 1.3 En `app_strings_es.dart`: añadir `String get noteHint => 'Escribe una nota...';`
- [x] 1.4 En `app_strings_de.dart`: añadir `String get noteHint => 'Notiz schreiben...';`
- [x] 1.5 En `app_strings_fr.dart`: añadir `String get noteHint => 'Écrire une note...';`
- [x] 1.6 En `app_strings_it.dart`: añadir `String get noteHint => 'Scrivi una nota...';`

## 2. Usar noteHint en la pantalla de mood

- [x] 2.1 En `mood_screen.dart:353`: reemplazar `hintText: 'Write a note...'` por `hintText: AppStrings.of(context).noteHint`

## 3. Verificación

- [x] 3.1 `flutter analyze` sin errores
