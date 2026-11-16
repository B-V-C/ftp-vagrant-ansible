#!/usr/bin/env bash
#
# Prueba del servidor web con curl
# Se ejecuta en la máquina ansible: vagrant ssh ansible -c "bash /vagrant/web/test-web.sh"
#

URL="http://192.168.57.7/"
TEXTO="Servidor web de borja.test"
FALLOS=0

# -s: sin barra de progreso
# -w: añade al final el código HTTP de la respuesta
respuesta=$(curl -s -w "\n%{http_code}" "$URL")

codigo=$(echo "$respuesta" | tail -n 1)
contenido=$(echo "$respuesta" | sed '$d')

echo "=== Prueba de $URL ==="

if [ "$codigo" = "200" ]; then
    echo "[OK]    Código HTTP: $codigo"
else
    echo "[FALLO] Código HTTP: esperaba 200 y ha devuelto '$codigo'"
    FALLOS=$((FALLOS + 1))
fi

if echo "$contenido" | grep -q "$TEXTO"; then
    echo "[OK]    La página contiene: $TEXTO"
else
    echo "[FALLO] La página no contiene: $TEXTO"
    FALLOS=$((FALLOS + 1))
fi

echo "=== Resultado ==="
if [ "$FALLOS" -eq 0 ]; then
    echo "Todas las pruebas correctas"
else
    echo "$FALLOS prueba(s) han fallado"
fi

exit "$FALLOS"