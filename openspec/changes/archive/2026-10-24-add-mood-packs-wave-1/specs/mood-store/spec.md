## ADDED Requirements

### Requirement: Packs de la primera ola
La Tienda SHALL ofrecer, además de Pack Confianza, tres Packs de 3 Moods cada uno: **Afecto** (`affectionate`, `hugging`, `laughing`), **Cuerpo** (`sleepy`, `sick`, `hurt`) e **Intenso** (`crying`, `scared`, `stressed`). La composición de cada Pack SHALL quedar congelada al publicarse y SHALL NOT modificarse después. La Tienda SHALL ofrecer también cada uno de los 9 Moods nuevos como compra individual. El precio objetivo es $0.99 por Mood y $1.99 por Pack (el mismo de Pack Confianza); el precio mostrado SHALL ser el que devuelve la tienda del sistema, nunca un valor fijo en el código. Pack Confianza y los Moods existentes SHALL conservar su composición y su precio.

#### Scenario: La Tienda lista los packs nuevos
- **WHEN** el usuario abre la Tienda con el catálogo cargado
- **THEN** ve Pack Confianza y los Packs Afecto, Cuerpo e Intenso, cada uno con los Moods que incluye y su precio de la tienda del sistema

#### Scenario: Comprar un pack nuevo desbloquea sus tres moods
- **WHEN** el usuario completa la compra del Pack Cuerpo
- **THEN** `sleepy`, `sick` y `hurt` quedan `unlocked` y el resto de los moods nuevos no

#### Scenario: Comprar un mood nuevo suelto
- **WHEN** el usuario completa la compra individual de `crying`
- **THEN** `crying` queda `unlocked` y ningún otro Mood cambia de estado

#### Scenario: Solape entre un mood suelto y un pack nuevo
- **WHEN** el usuario ya tiene `hugging` y abre la compra del Pack Afecto
- **THEN** la Tienda advierte que `hugging` ya está desbloqueado, no bloquea la compra y no ajusta el precio

#### Scenario: Pack Confianza no cambia
- **WHEN** se publican los Packs nuevos
- **THEN** Pack Confianza sigue incluyendo exactamente `brave`, `confident` y `romantic`

