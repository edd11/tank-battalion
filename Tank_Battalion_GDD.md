# Technical Design Document: Tank Battalion (Sega SG-1000 Clone)

## 1. Información General y Entorno
- **Objetivo:** Clonar la versión de Sega SG-1000 de "Tank Battalion".
- **Lenguaje/Entorno:** Ensamblador x86 (TASM), diseñado para ejecutarse en entorno DOS (DOSBox / Windows).
- **Entregables:** Código fuente en texto plano y un archivo `makefile` (o instrucciones de compilación/ejecución).
- **Filosofía de Desarrollo:** Código modular y bien indentado. Variables como velocidad, delays y cadencia de disparo deben ser fáciles de modificar para ajustar el *game feel* posteriormente. Priorizar la funcionalidad base antes del pulido.

## 2. Arquitectura de Memoria, Gráficos y Datos
- **Resolución y Modo de Video:** El juego correrá en el **Modo VGA 13h** (Resolución de 320x200 píxeles, 256 colores), un estándar ideal y accesible para programar gráficos en Ensamblador bajo DOSBox.
- **Tamaño de Sprites:** Todas las entidades móviles y bloques del mapa (Tanques, Paredes, Effigy) tendrán un tamaño fijo de **16x16 píxeles**.
- **Dimensiones del Mapa (Grid System):** 
  - El campo de batalla jugable estará compuesto por una matriz/grid lógica de **13x12 casillas** (columnas x filas).
  - En pantalla, este campo ocupará **208x192 píxeles** (13 * 16px de ancho y 12 * 16px de alto).
- **Alineación y HUD en Pantalla (320x200):**
  - **Altura:** Como el mapa ocupa 192px de altura y la pantalla tiene 200px, sobran 8 píxeles. Estos 8 píxeles sobrantes se utilizarán para dibujar un **borde superior de color verde**, delimitando el techo del mapa al estilo del juego original.
  - **Anchura:** El mapa ocupará los primeros 208px de izquierda a derecha. Los **112 píxeles restantes** en la parte derecha de la pantalla se usarán para mostrar el HUD de manera vertical (Nivel, Puntuaciones, Vidas, íconos de tanques enemigos restantes).
- **Valores lógicos para la matriz (Colisiones):**
  - `00`: Vacío
  - `01`: Pared
  - `02`: Tanque
  - `04`: Bala
- **Datos a persistir en memoria RAM/Video:**
  - Sprites y paletas de colores.
  - Tabla de Layouts de Niveles (8 variaciones en total).
  - Variables de estado: Nivel Actual, Score, Hi-Score (no se reinicia al perder), Vidas, Tanques enemigos restantes, Nivel de Dificultad Interno.

## 3. Máquina de Estados (Game Loop)
### Estado A: PANTALLA DE TÍTULO
- **Lógica:** Muestra el título y espera input.
- **Input:** `START` -> Cambia al Estado B (Nivel #XX).

### Estado B: NIVEL #XX (Gameplay)
- **HUD:** Muestra Nivel, Score, Hi-Score, Vidas restantes, Tanques enemigos restantes.
- **Input:** 
  - `Teclas de Movimiento`: Mueven el tanque del jugador.
  - `A / B`: Disparar bala.
  - `START`: Pausar el juego (congela estado hasta presionar START de nuevo).
- **Condición de Victoria:** Eliminar todos los tanques enemigos.
- **Condiciones de Derrota (Game Over):** 
  1. El jugador pierde todas sus vidas.
  2. El "Effigy" es destruido (Derrota instantánea, sin importar las vidas).
  - Al darse el Game Over, guardar Hi-Score si aplica y retornar al Estado A.

## 4. Entidades del Juego
### Tanque Jugador
- Puede moverse, disparar y pausar. Su capacidad de disparo depende de su Nivel de Power-Up.

### Tanques Enemigos (Comportamiento basado en Dificultad)
*A partir del nivel 5, el pool de generación de tanques se congela y permanece igual.*
1. **Normal (Azul):** Velocidad de movimiento y disparo normal. Movimiento errático. **HP: 1**.
2. **Rápido (Rojo):** Doble velocidad de movimiento. Alta probabilidad de apuntar al Effigy. **HP: 2** (Cambia a rosado al recibir 1 tiro).
3. **Fuego Rápido (Arcoíris):** Velocidad de movimiento normal. Balas al triple de velocidad. **HP: 1**. Al morir, 50% de probabilidad de activar un Power-Up.
4. **Pesado (Amarillo):** Velocidad normal. Dispara 2 balas rápidas sucesivas. Alta prioridad hacia el Effigy. **HP: 4** (Colores por impacto: Amarillo -> Amarillo descolorado -> Rojo -> Rosado).

### Effigy (Base Águila)
- Programáticamente tratado como un Tanque Estático ubicado en la parte inferior.
- **HP: 1**. Si recibe daño de cualquier bala, se destruye y lanza Game Over.

### Paredes Destructibles (Destructible Walls)
- Su disposición depende de 1 de los 8 Layouts del Nivel.
- Bloquean 1 tiro. Al ser impactadas, entran en estado de invulnerabilidad por 1 segundo (bloquean todo) antes de desaparecer de la matriz.

## 5. Estructura del Proyecto y Configuración
Para mantener el código organizado, escalable y facilitar la compilación, el proyecto utiliza la siguiente estructura de directorios:

```text
TankBattalion_ASM/
├── assets/      # Reservado para paletas de colores o layouts pre-calculados (opcional).
├── build/       # Destino de los archivos binarios (.obj, .exe, .map) para no ensuciar el código fuente.
├── src/         # Código fuente.
│   └── main.asm # Archivo principal que contiene la lógica y la máquina de estados.
└── Makefile     # Script de compilación (o instrucciones en batch para DOSBox).
```

### Filosofía de Diseño: "Game Feel" Primero
Una de las prioridades de desarrollo es que los valores que afectan el ritmo y la sensación del juego (*Game Feel*) sean fácilmente editables por el usuario, sin necesidad de rebuscar en medio de la lógica algorítmica. 

Para lograr esto, se han tomado las siguientes decisiones arquitectónicas en el archivo `.asm`:
1. **Sección Aislada de Balanceo:** En la parte superior del segmento `.data`, existe un bloque claramente delimitado (comentado como "VARIABLES DE BALANCEO / GAME FEEL").
2. **Uso de Variables de Memoria (Variables en RAM) en lugar de Constantes (EQU):** Valores como `PLAYER_SPEED` (velocidad de movimiento) o `BULLET_SPEED_NORM` (velocidad de los proyectiles) se definen como `dw` (words) inicializados en memoria. Esto permite ajustarlos rápidamente desde un solo lugar e incluso abre la puerta a que mecánicas del juego los modifiquen dinámicamente si se requiriese más adelante (por ejemplo, aplicar un efecto de *ralentización* general).
3. **Control de Tiempo Centralizado:** Un valor `GAME_SPEED_DELAY` y/o un contador de *frames* dictará el paso del game-loop. Al separar la lógica del procesador puro y amarrarla a un control de delay explícito, se asegura que el juego no corra demasiado rápido en emuladores modernos como DOSBox, permitiendo que el desarrollador calibre la velocidad general con una sola variable.
## 6. Sistemas del Juego
### Sistema de Power-Up
Se activa (50% de probabilidad) al matar un Tanque de Fuego Rápido. El jugador pierde el nivel al morir y vuelve a 00.
- **Nivel 00:** Máximo 1 bala en pantalla a la vez. Velocidad de bala normal.
- **Nivel 01:** Máximo 2 balas en pantalla a la vez. Velocidad de bala normal.
- **Nivel 02:** Máximo 2 balas en pantalla a la vez. Velocidad de bala rápida (igual al tanque Arcoíris).

### Sistema de Puntuación (Scoring)
- **Extra Life:** Otorga +1 Vida al alcanzar 20,000 puntos. (Debe llevarse en un contador separado al de score para evitar bugs matemáticos en ASM).
- **Hi-Score:** Se actualiza solo si el Score actual es mayor.

**Puntuación por Eliminación:**
- **Excepciones fijas:**
  - Tanque Fuego Rápido: 500 pts.
  - Tanque Rápido o Pesado: 1000 pts.
- **Tanque Normal mirando de frente al jugador:**
  - Distancia Adyacente: 800 pts.
  - Distancia Media (2 a 14 casillas): 300 pts.
  - Distancia Lejana (15+ casillas): 150 pts.
- **Tanque Normal NO mirando de frente al jugador:**
  - Distancia Adyacente: 300 pts.
  - Distancia Media (2 a 14 casillas): 150 pts.
  - Distancia Lejana (15+ casillas): 60 pts.
