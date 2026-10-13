## Context

El catálogo vive en `mood_definition.dart` (5 base + 5 premium). La Tienda descubre moods y packs por prefijo de `package.identifier` en la oferta `default` de RevenueCat (`$rc_custom_mood_<id>`, `$rc_custom_pack_<id>`) y lee la composición de cada pack de la metadata `pack_<packId>_moodIds` de la oferta. Hoy: 5 productos de mood + `pack_confianza_unlock` (brave, confident, romantic). Los precios viven en App Store Connect, no en el repo ni en la API de RevenueCat. Reglas del proyecto: `intensity` es solo un identificador (ADR 0001), los Packs se congelan al publicarse (ADR 0002), `MoodDefinition.color` debe ser `MaterialColor`.

## Goals / Non-Goals

**Goals:**
- Añadir 9 moods premium y 3 packs de 3 sin tocar la lógica de compras, el selector ni el calendario.
- Dejar la configuración externa (ASC + RevenueCat) descrita de forma reproducible.

**Non-Goals:**
- Cambiar Pack Confianza, moods existentes, precios existentes o el orden del selector.
- Segunda ola (giggly, nauseous, weary, silly, wacky, thoughtful, nerdy, surprised, annoyed, bored, smug).
- Pack "colección completa" (choca con ADR 0002: cada ola exigiría uno nuevo).
- Hacer gratis algún mood (se decidió crying premium dentro de Intenso).

## Decisions

**1. Moods y emojis.** Cada id usa el emoji que realmente dibuja esa emoción (revisado a tamaño grande; los nombres de archivo del set no son fiables):

| id | emoji del set | Pack |
|---|---|---|
| affectionate | 013 (beso con corazón) | Afecto |
| hugging | 024 (abrazo) | Afecto |
| laughing | 002 (lágrimas de risa) | Afecto |
| sleepy | 021 (ojos cerrados, "Zzz") | Cuerpo |
| sick | 019 (mascarilla) | Cuerpo |
| hurt | 042 (vendaje) | Cuerpo |
| crying | 003 (llanto) | Intenso |
| scared | 036 (grito) | Intenso |
| stressed | 010 (sudor frío) | Intenso |

El id `affectionate` es una decisión de nombre (el emoji es un beso); los ids son permanentes porque se exportan, así que se confirma antes de publicar. Se descartó 034 ("dead") por sensibilidad en una app de bienestar.

**2. Orden e `intensity`.** Catálogo: base, premium existentes, luego Afecto, Cuerpo, Intenso en el orden de la tabla. `intensity` 11–19 en ese orden, solo como identificador interno.

**3. Colores.** Hay 19 `MaterialColor` y 10 en uso; los 9 libres alcanzan casi para los 9 nuevos. Asignación aprobada con el mock, con 2 repetidos entre packs distintos (nunca dentro de un pack):
- Afecto: affectionate `purple`, hugging `deepOrange`, laughing `cyan`
- Cuerpo: sleepy `deepPurple`, sick `lightGreen`, hurt `blueGrey`
- Intenso: crying `lightBlue`, scared `purple`, stressed `cyan`

Alternativa descartada: ampliar el esquema a un color custom; `backgroundGradientForMood` depende de `.shade50/.shade200` de `MaterialColor` y repetir 3 colores es un costo menor. Si `lightBlue`/`yellow` se confunden con `calm`/`confident`, se ajusta tras verlos en la app.

**4. Productos y packs.** Convención idéntica a la actual:
- Mood: producto `mood_<id>_unlock`, entitlement `mood_<id>`, paquete `$rc_custom_mood_<id>`.
- Pack: producto `pack_<pack>_unlock`, paquete `$rc_custom_pack_<pack>`, con `<pack>` ∈ `afecto|cuerpo|intenso`. Cada entitlement `mood_<id>` se asocia también al producto de su pack.
- Metadata de la oferta `default`: `pack_afecto_moodIds`, `pack_cuerpo_moodIds`, `pack_intenso_moodIds` (listas de ids). Se agrega al mapa existente sin tocar `pack_confianza_moodIds`.
- Precios: $0.99 por mood y $1.99 por pack (mismo precio y 33 % de descuento que Pack Confianza, leído de ASC el 2026-10-12), fijados en ASC con territorio base USA. El código sigue mostrando `priceString` de la tienda.
- El nombre del Pack en la UI sale del título localizado del producto en ASC (`storeProduct.title`), así que los nombres de los packs en 5 idiomas se resuelven en ASC y no en `AppStrings`.

**5. Código de compras sin cambios.** `MoodEntitlementsRepositoryImpl` ya descubre por prefijo y metadata. No se toca; solo se verifica con tests y con la tienda real.

**6. Lanzamiento.** Los 3 packs juntos en 1.8.4, un solo ciclo de revisión de IAP. Los productos nuevos deben estar en ASC "Ready to Submit" y asociarse a la versión antes de enviarla.

**7. Packs de 3, no de 4.** Pack Confianza (3 moods a $1.99, 33 % de descuento) ya está publicado y congelado (ADR 0002). Para mantener un solo esquema de precio y no tocarlo, los packs nuevos también llevan 3 moods a $1.99. Se descartó añadir un cuarto mood a Confianza (exigiría un ADR 0003 que sustituya al 0002) y se descartó un precio de $2.99 por 4, que dejaba el mood más caro que en Confianza ($0.75 frente a $0.66). Quedan fuera giggly, nauseous y weary: emoji más sutil o solapado con otro mood de su pack.

**8. Localización de los productos en ASC.** Los 6 IAP actuales solo tienen `en-US` y `es-MX`. Los 12 nuevos se crean en los 5 idiomas de la app (en, es, de, fr, it) y se evalúa completar los 6 existentes aparte, sin condicionar este change. Nombre y descripción siguen la forma actual: "Anxious / Unlock the Anxious mood permanently in Mood Calendar".

**9. Notas de la API de ASC (aprendidas al crear los productos).** Descripción máx. 55 caracteres y nombre máx. 35; el italiano se envía como `it` (no `it-IT`); las subidas de captura van a una URL prefirmada y no admiten la cabecera `Authorization`; el JWT caduca a los 10 minutos. Los 12 productos se crearon el 2026-10-12, quedaron en `READY_TO_SUBMIT` con precio USA, 175 territorios, 5 idiomas y la captura de revisión de los productos existentes (tienda antigua); conviene reemplazarla por una de la tienda nueva antes de enviar (tarea 6.1).

## Risks / Trade-offs

- **Licencia del set (resuelto).** El PDF incluido en la descarga es la licencia gratuita de Flaticon, que exige atribución y prohíbe vender el contenido. El autor compró la licencia comercial (premium) de Flaticon el 2026-10-12, que sustituye esa limitación para el uso en la app, incluidos los 10 íconos ya publicados. → Guardar el comprobante de la compra y el ID del pack (983034) fuera del repo; no se añade atribución en la app. Si el set se descarga de nuevo con la cuenta premium, usar esa versión.
- **Tienda vacía por mala configuración (rechazo 2.1(b) previo).** Un paquete o metadata faltante deja la oferta incompleta. → Verificar con el MCP de RevenueCat y probar en simulador limpio e iPad con la API key real (checklist de `CLAUDE.md`).
- **Parecidos visuales a tamaño de calendario.** Varios emojis comparten la cara base. → Revisar los 19 en el calendario a tamaño real antes de cerrar la lista; si alguno no se distingue, sustituirlo por uno de la segunda ola.
- **SVG pesados.** `brave.svg` es un outlier de 1 MB. → Los 9 nuevos son SVG simples (~3 KB); verificar tamaño al copiarlos.
- **Ids permanentes.** Un id mal elegido no se puede renombrar sin migrar datos y exportaciones. → Confirmar ids en la tarea 1.
- **Crying de pago.** Decisión del autor; puede percibirse mal. Se mide después y se puede volver gratis sin romper nada (desbloquear un mood no reescribe historial).

## Migration Plan

1. Resolver licencia y confirmar ids/colores.
2. Crear productos en ASC y RevenueCat (entitlements, paquetes, metadata) **antes** del build, para poder probar compras sandbox.
3. Implementar catálogo, assets y strings; tests y `flutter analyze` en verde.
4. Probar tienda con API key real en simulador limpio (iPhone) e iPad.
5. Subir versión, generar build con `scripts/build_ios_release.sh`, completar What's New y promo text, enviar a revisión.

Rollback: los productos nuevos pueden quitarse de la oferta `default` sin tocar la app; los moods quedarían bloqueados e invisibles en la Tienda pero sin afectar datos.

## Open Questions

- ¿Se confirma `affectionate` como id del emoji de beso, o prefieres `kiss`?
- ¿Se mantiene `crying` premium tras ver la reacción de usuarios, o pasa a gratis en una versión posterior?
