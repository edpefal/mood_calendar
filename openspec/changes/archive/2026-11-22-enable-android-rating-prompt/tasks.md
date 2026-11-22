## 1. Servicio

- [x] 1.1 En `RatingPromptService`, cambiar la condición de plataforma `isIOS` por `isSupportedPlatform` (por defecto `Platform.isIOS || Platform.isAndroid`), manteniéndola inyectable
- [x] 1.2 Comprobar que `InAppReviewRequester` y la fila manual de Settings no necesitan cambios en Android (`isAvailable`, `requestReview`, `openStoreListing`)

## 2. Pruebas

- [x] 2.1 Actualizar `rating_prompt_service_test.dart`: el servicio construido como plataforma soportada solicita en el 3.er día y registra el intento, y una plataforma no soportada no solicita ni registra nada
- [x] 2.2 Añadir un caso de Android: con la plataforma inyectada como Android se aplica la misma política (3.er día, 7 días y 30 días, máximo 2 intentos)
- [x] 2.3 Correr `flutter analyze` y `flutter test`

## 3. Documentación

- [x] 3.1 Actualizar `CLAUDE.md` (sección Calificación) y el Purpose del spec `rating-prompt` para que no digan solo App Store
- [x] 3.2 Archivar el change y sincronizar el spec (`/opsx:archive`)

## 4. Publicación (aparte, con permiso expreso)

- [x] 4.1 Subir `pubspec.yaml` a `1.10.1+51` en un PR aparte y construir el `.aab` con `STORE_VERIFIED=1`
- [ ] 4.2 Con permiso, subirlo a la pista interna de Play y promoverlo a producción; verificar el diálogo desde la pista interna con una build firmada (no con una build de depuración por USB)
