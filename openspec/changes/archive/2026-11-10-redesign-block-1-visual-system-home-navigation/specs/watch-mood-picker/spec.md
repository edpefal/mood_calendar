## ADDED Requirements

### Requirement: El reloj usa la marca vigente
La app del reloj SHALL usar como acento la tinta de marca vigente de la app del iPhone, y su ícono SHALL ser el de la marca vigente. El cambio SHALL NOT alterar la interfaz ni el comportamiento del reloj.

#### Scenario: Acento del reloj
- **WHEN** el usuario abre la app del reloj
- **THEN** sus controles de acento usan la tinta de marca y no el cian de la marca anterior

## MODIFIED Requirements

### Requirement: Moods ofrecidos en el reloj
El reloj SHALL ofrecer únicamente los moods que el usuario tiene desbloqueados en ese momento (los 11 moods base y los premium suscritos o comprados), en el orden fijo por categoría del Log del iPhone. El reloj NO SHALL ofrecer compras, mostrar moods bloqueados ni precios. Cuando el catálogo de moods desbloqueados cambia en el iPhone (por una suscripción o una restauración), el reloj SHALL actualizar su lista sin intervención del usuario.

#### Scenario: Solo moods desbloqueados
- **WHEN** el usuario tiene desbloqueados los 11 moods base y el mood premium `brave`
- **THEN** el reloj ofrece esos 12 moods y ningún otro

#### Scenario: Orden fijo por categoría
- **WHEN** el Log del iPhone lista los moods en el orden fijo por categoría
- **THEN** el reloj muestra los desbloqueados en ese mismo orden, sin depender de la frecuencia de uso

#### Scenario: Suscripción en el iPhone
- **WHEN** el usuario se suscribe en el iPhone
- **THEN** el reloj incluye los moods premium la próxima vez que reciba el estado, sin que el usuario haga nada en el reloj

#### Scenario: Sin compras en el reloj
- **WHEN** el usuario usa cualquier pantalla del reloj
- **THEN** no existe ninguna acción de compra, restauración ni enlace a la tienda
