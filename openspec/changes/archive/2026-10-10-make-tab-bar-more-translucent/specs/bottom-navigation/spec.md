## MODIFIED Requirements

### Requirement: Apariencia del bar como cápsula translúcida flotante
El bar SHALL mostrarse como una cápsula flotante con bordes totalmente redondeados, separada de los bordes laterales e inferior de la pantalla, con fondo translúcido y un desenfoque suave del contenido que pasa por debajo. El contenido situado detrás del bar SHALL seguir siendo reconocible a través de él (sus formas y colores se distinguen, aunque suavizados), sin comprometer la legibilidad de los iconos de las pestañas. La pestaña activa SHALL distinguirse con una píldora translúcida detrás de su icono. En pantallas anchas el bar SHALL tener un ancho máximo de entre 400 y 440 pt y quedar centrado horizontalmente.

#### Scenario: Contenido reconocible bajo el bar
- **WHEN** una pantalla de pestaña tiene contenido (por ejemplo un botón con borde o una tarjeta) desplazado por debajo del bar
- **THEN** ese contenido se distingue a través de la cápsula, suavizado pero no oculto por un relleno casi opaco

#### Scenario: Iconos legibles
- **WHEN** el bar está sobre contenido de cualquier color o texto
- **THEN** los iconos de las cuatro pestañas y la pestaña activa se siguen distinguiendo con claridad

#### Scenario: Pestaña activa marcada
- **WHEN** una pestaña está activa
- **THEN** su icono aparece sobre una píldora translúcida y las otras pestañas no la tienen

#### Scenario: iPad
- **WHEN** la app corre en una pantalla más ancha que el ancho máximo del bar
- **THEN** el bar mantiene su ancho máximo y se centra en la parte baja de la pantalla

#### Scenario: El contenido no queda tapado
- **WHEN** una pantalla de pestaña tiene contenido en su parte baja (botón de guardar del selector, lista de Tienda o de Ajustes)
- **THEN** ese contenido puede desplazarse o colocarse de modo que ningún control quede cubierto por el bar
