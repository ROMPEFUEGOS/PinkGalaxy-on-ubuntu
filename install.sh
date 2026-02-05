#!/bin/bash
# Instalador de PinkGalaxy para Linux (Wine) - Versión Definitiva
# Solución por Kecojones & Rompefuegos

APP_NAME="PinkGalaxy"
INSTALL_DIR="$HOME/Games/PinkGalaxy"
WINE_PREFIX="$HOME/.local/share/wineprefixes/pinkgalaxy"

echo "=== Iniciando Instalación de $APP_NAME (Edición Definitiva) ==="

# 1. Comprobar dependencias
echo "--> Comprobando herramientas necesarias..."
for tool in wine winetricks msiextract 7z; do
    if ! command -v $tool &> /dev/null; then
        echo "ERROR: No tienes '$tool' instalado."
        echo "En Ubuntu/Debian instala: sudo apt install wine winetricks msitools p7zip-full"
        exit 1
    fi
done

# 2. Pedir el instalador
if [ ! -f "game.msi" ]; then
    echo "ERROR: Por favor, coloca el archivo 'game.msi' en esta carpeta."
    exit 1
fi

# 3. Crear entorno Wine (64 bits)
echo "--> Creando entorno Wine en: $WINE_PREFIX"
export WINEPREFIX="$WINE_PREFIX"
export WINEARCH=win64
wineboot -u

# 4. Instalar Librerías Esenciales
echo "--> Instalando librerías (Visual C++ y Fuentes)..."
# vcrun2022 es crítico para el navegador CefSharp
winetricks -q corefonts vcrun2022

# 5. CONFIGURACIÓN CRÍTICA (La magia que arregla el juego)
echo "--> Aplicando parches de estabilidad..."

# A) Forzar Windows 10 (Necesario para CefSharp/Chromium)
winetricks -q win10

# B) Desactivar wbemprox (Soluciona el crasheo de 'AccessViolation' al leer discos)
echo "   -> Desactivando sensor de hardware (wbemprox)..."
wine reg add "HKEY_CURRENT_USER\Software\Wine\DllOverrides" /v "wbemprox" /t REG_SZ /d "" /f

# C) Camuflar unidad Z: como 'Unidad de Red' (Evita conflictos de serial)
echo "   -> Configurando unidad Z como red..."
wine reg add "HKEY_LOCAL_MACHINE\Software\Wine\Drives\z:" /v "Type" /t REG_SZ /d "network" /f

# D) Activar TLS 1.2 (Para que conecte al servidor)
wine reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\.NETFramework\v4.0.30319" /v SchUseStrongCrypto /t REG_DWORD /d 1 /f
wine reg add "HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" /v SchUseStrongCrypto /t REG_DWORD /d 1 /f

# 6. Instalar el juego
echo "--> Extrayendo archivos del juego..."
mkdir -p "$INSTALL_DIR"
msiextract game.msi -C "$INSTALL_DIR"
# Mover archivos a la unidad C: virtual
mkdir -p "$WINE_PREFIX/drive_c/PinkGalaxy"
cp -r "$INSTALL_DIR/PFiles/PinkGalaxy/"* "$WINE_PREFIX/drive_c/PinkGalaxy/"
rm -rf "$INSTALL_DIR"

# 7. Configurar Ping (Para que no te eche el servidor)
echo "--> Ajustando permisos de red (Ping)..."
# Nota: Esto puede pedir contraseña sudo
echo "net.ipv4.ping_group_range = 0 2147483647" | sudo tee -a /etc/sysctl.conf > /dev/null
sudo sysctl -p > /dev/null

# 8. Crear Lanzador Inteligente
echo "--> Generando lanzador en el escritorio..."
LAUNCHER="$HOME/Desktop/Jugar_PinkGalaxy.sh"

cat <<EOF > "$LAUNCHER"
#!/bin/bash
export WINEPREFIX="$WINE_PREFIX"
# WINEDEBUG=-all silencia los errores inofensivos de wbemprox
# --no-sandbox y --disable-gpu estabilizan el navegador interno
echo "Iniciando PinkGalaxy..."
WINEDEBUG=-all wine "$WINE_PREFIX/drive_c/PinkGalaxy/PinkGalaxy Client.exe" --no-sandbox --disable-gpu > /dev/null 2>&1 &

# Monitor de cierre limpio
sleep 10
while pgrep -f "PinkGalaxy Client.exe" > /dev/null; do
    sleep 2
done
# Limpieza de procesos zombies al salir
pkill -f "PinkGalaxy Client.exe"
pkill -f "CefSharp.BrowserSubprocess.exe"
EOF

chmod +x "$LAUNCHER"

echo "=== ¡INSTALACIÓN COMPLETADA CON ÉXITO! ==="
echo "Ejecuta el acceso directo 'Jugar_PinkGalaxy.sh' en tu escritorio."
