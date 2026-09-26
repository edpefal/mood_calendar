## 1. Refactorizar AppStrings a clase abstracta

- [x] 1.1 Reescribir `app_strings.dart`: convertir la clase a abstracta, eliminar `isEnglish`, mantener `of(BuildContext)`, `forLocale(Locale)` y `supportedLocales` con los 5 locales (es, en, de, fr, it)
- [x] 1.2 Crear `app_strings_es.dart` con `AppStringsEs extends AppStrings` con todas las traducciones españolas (extraídas del archivo actual)
- [x] 1.3 Crear `app_strings_en.dart` con `AppStringsEn extends AppStrings` con todas las traducciones inglesas (extraídas del archivo actual)

## 2. Añadir nuevos idiomas

- [x] 2.1 Crear `app_strings_de.dart` con `AppStringsDe extends AppStrings` con traducción alemana de todos los strings
- [x] 2.2 Crear `app_strings_fr.dart` con `AppStringsFr extends AppStrings` con traducción francesa de todos los strings
- [x] 2.3 Crear `app_strings_it.dart` con `AppStringsIt extends AppStrings` con traducción italiana de todos los strings

## 3. Actualizar sitios de llamada con locale estático

- [x] 3.1 En `main.dart`: eliminar `locale: const Locale('es')` (línea 147) y cambiar `AppStrings.spanish.appTitle` (línea 145) a `AppStrings.forLocale(const Locale('es')).appTitle`
- [x] 3.2 En `local_notification_service.dart`: reemplazar los 4 usos de `AppStrings.spanish` por `AppStrings.forLocale(const Locale('es'))` (las notificaciones se mantienen en español por ahora al no tener contexto de locale en background)
- [x] 3.3 En `mood_screen.dart:445`: reemplazar `AppStrings.spanish.monthNames` por el acceso correcto con context

## 4. Verificación

- [x] 4.1 `flutter analyze lib/core/localization/` sin errores (valida que todas las subclases implementan todos los getters)
- [ ] 4.2 Verificar visualmente en simulador con locale en alemán, francés e italiano que los textos de UI aparecen en el idioma correcto
- [ ] 4.3 Verificar que con locale no soportado (ej. japonés) la app muestra español
