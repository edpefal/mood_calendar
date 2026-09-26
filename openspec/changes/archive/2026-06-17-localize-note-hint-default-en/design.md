## Context

`mood_screen.dart:353` usa `hintText: 'Write a note...'` hardcodeado. El sistema de localización ya tiene la arquitectura de subclases implementada (change `add-multilanguage-support`). Solo falta añadir el getter y reordenar el fallback.

El fallback de Flutter usa el primer elemento de `supportedLocales`. Actualmente es `Locale('es')`; cambiarlo a `Locale('en')` hace que dispositivos en idiomas no soportados vean inglés en lugar de español.

## Goals / Non-Goals

**Goals:**
- Añadir `noteHint` a la clase abstracta y a las 5 subclases
- Reemplazar el hardcode en `mood_screen.dart`
- Hacer inglés el fallback moviendo `Locale('en')` al primer lugar en `supportedLocales`

**Non-Goals:**
- Cambiar ningún otro string ni comportamiento de localización

## Decisions

El getter se llama `noteHint` (no `writeNote` ni `notePlaceholder`) por consistencia con los demás getters de la clase que usan nombres descriptivos cortos.

## Risks / Trade-offs

- [Cambiar el fallback de es → en afecta usuarios existentes en locales no soportados] → Intencional; el fallback en inglés es más universal para la App Store global
