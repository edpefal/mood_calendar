## Context

`AppStrings` es actualmente una clase concreta con ~180 líneas que usa `isEnglish` como único discriminador. Cada getter tiene la forma `isEnglish ? 'English text' : 'Texto español'`. Añadir un tercer idioma requeriría convertir cada ternario en un switch y repetir ese patrón en ~50 getters. El locale está forzado a español en `main.dart` con `locale: const Locale('es')`, ignorando el idioma del dispositivo.

## Goals / Non-Goals

**Goals:**
- Convertir `AppStrings` en clase abstracta con un getter abstracto por string localizable
- Crear una subclase concreta por idioma (`AppStringsEs`, `AppStringsEn`, `AppStringsDe`, `AppStringsFr`, `AppStringsIt`)
- El factory `forLocale` retorna la subclase correcta vía `switch` sobre `languageCode`
- Añadir `de`, `fr`, `it` a `supportedLocales`
- Eliminar `locale: const Locale('es')` de `main.dart`; el sistema de Flutter resuelve el locale del dispositivo con fallback al primero de `supportedLocales` (español)

**Non-Goals:**
- Migrar a ARB + gen-l10n (overhead de tooling innecesario para esta etapa)
- Añadir portugués u otros idiomas (fuera de scope de este cambio)
- Cambiar el contenido de ninguna traducción existente (español e inglés se preservan tal cual)
- Añadir un selector de idioma manual en la UI

## Decisions

**Subclases por idioma vs. switch en un solo archivo**
Elegimos subclases porque el compilador Dart valida que cada subclase implementa todos los getters abstractos. Si se añade un nuevo getter a la clase base y se olvida implementarlo en algún idioma, el compilador falla en tiempo de build — no en runtime. Un switch en un solo archivo no da esa garantía.

**Fallback a español**
El primer elemento de `supportedLocales` es `Locale('es')`. Flutter usa el primero como fallback cuando el locale del dispositivo no está en la lista. No se necesita lógica adicional.

**Estructura de archivos**
```
lib/core/localization/
├── app_strings.dart          ← clase abstracta + factory forLocale + supportedLocales
├── app_strings_es.dart
├── app_strings_en.dart
├── app_strings_de.dart
├── app_strings_fr.dart
└── app_strings_it.dart
```

`app_strings.dart` mantiene `of(BuildContext)` y `forLocale(Locale)` para que ningún sitio de llamada cambie.

**Traducciones**
Las traducciones para alemán, francés e italiano se generan con conocimiento del dominio. Los strings son cortos y de UI — no requieren traducción profesional para el MVP.

## Risks / Trade-offs

- [Las traducciones automáticas pueden tener errores culturales/gramaticales menores] → Aceptable para MVP; se pueden refinar con feedback de usuarios nativos
- [El refactor es breaking: elimina `isEnglish`, `spanish`, `english` statics] → Verificar con grep que ningún otro archivo los usa antes de eliminar
- [Dispositivos con locale `pt` (portugués) caerán a español] → Comportamiento correcto y esperado; portugués no está en scope
