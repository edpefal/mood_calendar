## ADDED Requirements

### Requirement: Interruptor de datos de uso anónimos
Settings SHALL incluir un interruptor "Compartir datos de uso anónimos", activado por defecto, con una breve explicación de que solo se mide el uso general de la app y nunca las entradas. Al cambiarlo SHALL guardarse y aplicarse al instante, sin botón de guardar, y si el guardado falla SHALL revertirse con un mensaje, igual que el recordatorio diario. El interruptor SHALL tener label de `Semantics` y su texto SHALL estar localizado en todos los idiomas soportados.

#### Scenario: Estado inicial
- **WHEN** el usuario abre Settings por primera vez
- **THEN** el interruptor aparece activado

#### Scenario: Desactivar los datos de uso
- **WHEN** el usuario desactiva el interruptor
- **THEN** la preferencia se guarda y deja de enviarse la medición de uso

#### Scenario: Fallo al guardar
- **WHEN** el guardado de la preferencia falla
- **THEN** el interruptor vuelve a su valor anterior y se muestra un mensaje de error

#### Scenario: Texto en el idioma del dispositivo
- **WHEN** el dispositivo está en alemán, francés, italiano, español o inglés
- **THEN** la fila del interruptor y su explicación se muestran en ese idioma
