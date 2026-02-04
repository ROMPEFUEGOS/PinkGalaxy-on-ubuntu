# PinkGalaxy en Linux (Ubuntu/Debian)

Script automatizado para instalar y jugar a PinkGalaxy en Linux usando Wine.
Este proyecto soluciona los problemas comunes: error de conexión a internet, crasheos de .NET, y ventanas congeladas.

## Requisitos
- Ubuntu 20.04 o superior (o distros basadas en Debian).
- Conexión a internet.

## Instrucciones de Instalación

1. Descarga el instalador oficial del juego (`game.msi`) desde la web de PinkGalaxy.
2. Clona este repositorio o descarga el ZIP.
3. Coloca el archivo `game.msi` dentro de la carpeta de este repositorio.
4. Abre una terminal en la carpeta y ejecuta:

chmod +x install.sh
./install.sh


5. Espera a que termine (la instalación de .NET 4.8 tarda unos minutos).
6. Al finalizar, tendrás un lanzador en tu escritorio.

## Qué hace este script
- Crea un entorno Wine aislado (para no romper tu configuración actual).
- Instala automáticamente: .NET 4.8, Visual C++ 2022, DXVK, Corefonts.
- Parchea el registro para habilitar TLS 1.2 (soluciona error de conexión).
- Oculta la unidad Z: de Wine (soluciona crasheo al inicio).
- Crea un script de lanzamiento inteligente que limpia los procesos al cerrar el juego.

## Créditos
Investigación y desarrollo por **Kecojones** y **Rompefuegos**.
