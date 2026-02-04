#!/bin/bash
# Instalador de PinkGalaxy para Linux (Wine)
# Basado en la investigación de Kecojones

APP_NAME="PinkGalaxy"
INSTALL_DIR="$HOME/Games/PinkGalaxy"
WINE_PREFIX="$HOME/.local/share/wineprefixes/pinkgalaxy"

echo "=== Iniciando Instalación de $APP_NAME ==="

# 1. Comprobar dependencias
echo "--> Comprobando herramientas necesarias..."
for tool in wine winetricks msiextract 7z; do
    if ! command -v $tool &> /dev/null; then
        echo "ERROR: No tienes '$tool' instalado."
        echo "En Ubuntu/Debian instala: sudo apt install wine winetricks msitools p7zip-full"
        exit 1
    fi
done

# 2. Pedir el instalador del juego
if [ ! -f "game.msi" ]; then
    echo "ERROR: Por favor, descarga el instalador 'game.msi' de la web oficial"
    echo "y colócalo en esta misma carpeta junto a este script."
    exit 1
fi

# 3. Preparar entorno Wine (64 bits limpio)
echo "--> Creando entorno Wine limpio en: $WINE_PREFIX"
export WINEPREFIX="$WINE_PREFIX"
export WINEARCH=win64
# Inicializar Wine sin interfaz
wineboot -u

# 4. Instalar librerías (La parte lenta)
echo "--> Instalando librerías de Windows (Esto tardará, ten paciencia)..."
# Evitamos ventanas de error
winetricks -q dotnet48 corefonts vcrun2022 d3dcompiler_47 gdiplus dxvk

# 5. Configuración del Registro (Parches críticos)
echo "--> Aplicando parches del registro..."
# Activar TLS 1.2 (Conexión a internet)
wine reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\.NETFramework\v4.0.30319" /v SchUseStrongCrypto /t REG_DWORD /d 1 /f
wine reg add "HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" /v SchUseStrongCrypto /t REG_DWORD /d 1 /f
# Forzar Windows 7
winetricks -q win7
# Ocultar unidad Z: (Evita crasheo de lectura de disco)
wine reg delete "HKEY_LOCAL_MACHINE\Software\Wine\Drives" /v "z:" /f 2>/dev/null
# Fake Serial para C: (Evita crasheo de DeviceId)
# Nota: Esto requiere winecfg manual o un script avanzado de edición de drives, 
# pero generalmente ocultar Z: es suficiente.

# 6. Extraer el juego
echo "--> Extrayendo archivos del juego..."
mkdir -p "$INSTALL_DIR"
msiextract game.msi -C "$INSTALL_DIR"
# Mover la carpeta interna al sitio correcto
mv "$INSTALL_DIR/PFiles/PinkGalaxy" "$WINE_PREFIX/drive_c/"
rm -rf "$INSTALL_DIR" # Limpieza temporal

# 7. Configuración de Red (Ping)
echo "--> Configurando permisos de red (Requiere contraseña sudo)..."
echo "net.ipv4.ping_group_range = 0 2147483647" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# 8. Crear el Lanzador
echo "--> Creando acceso directo..."
LAUNCHER_SCRIPT="$HOME/Desktop/Jugar_PinkGalaxy.sh"
cat <<EOF > "$LAUNCHER_SCRIPT"
#!/bin/bash
export WINEPREFIX="$WINE_PREFIX"
# Lanzar juego
wine start /Unix "C:\\PinkGalaxy\\PinkGalaxy Client.exe" --no-sandbox --disable-gpu > /dev/null 2>&1 &
# Esperar arranque
sleep 10
# Bucle vigilante
while pgrep -f "PinkGalaxy Client.exe" > /dev/null; do
    sleep 2
done
# Matar zombies al cerrar
pkill -f "PinkGalaxy Client.exe"
pkill -f "CefSharp.BrowserSubprocess.exe"
EOF

chmod +x "$LAUNCHER_SCRIPT"

echo "=== ¡INSTALACIÓN COMPLETADA! ==="
echo "Tienes un icono 'Jugar_PinkGalaxy.sh' en tu escritorio."
