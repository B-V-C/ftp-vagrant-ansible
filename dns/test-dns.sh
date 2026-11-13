#!/usr/bin/env bash
#
# Pruebas del servidor DNS de borja.test
# Se ejecuta en la máquina dns: vagrant ssh dns -c "bash /vagrant/dns/test-dns.sh"
#

SERVIDOR=192.168.57.5
FALLOS=0

# Compara el resultado de una consulta con el valor esperado
comprobar() {
    local descripcion="$1"
    local esperado="$2"
    local obtenido="$3"

    if [ "$obtenido" = "$esperado" ]; then
        echo "[OK]    $descripcion -> $obtenido"
    else
        echo "[FALLO] $descripcion -> esperaba '$esperado' y ha devuelto '$obtenido'"
        FALLOS=$((FALLOS + 1))
    fi
}

echo "=== Zona directa: registros A ==="
comprobar "dns.borja.test"     "192.168.57.5" "$(dig @$SERVIDOR dns.borja.test A +short)"
comprobar "negocio.borja.test" "192.168.57.7" "$(dig @$SERVIDOR negocio.borja.test A +short)"

echo "=== Zona directa: alias CNAME ==="
comprobar "www.borja.test" "negocio.borja.test." "$(dig @$SERVIDOR www.borja.test CNAME +short)"
comprobar "ftp.borja.test" "negocio.borja.test." "$(dig @$SERVIDOR ftp.borja.test CNAME +short)"

echo "=== Zona inversa: registros PTR ==="
comprobar "192.168.57.5" "dns.borja.test."     "$(dig @$SERVIDOR -x 192.168.57.5 +short)"
comprobar "192.168.57.7" "negocio.borja.test." "$(dig @$SERVIDOR -x 192.168.57.7 +short)"

echo "=== Resultado ==="
if [ "$FALLOS" -eq 0 ]; then
    echo "Todas las pruebas correctas"
else
    echo "$FALLOS prueba(s) han fallado"
fi

exit "$FALLOS"