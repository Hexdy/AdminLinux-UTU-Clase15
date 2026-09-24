#!/usr/bin/env bash
# correr.sh — atajo: comprueba requisitos y ARMA el reto (deja datos/reto/ listo).
#
# 🤔 ¿Te suena este script? Lo venís corriendo desde la Clase 1 sin saber qué hacía.
#    Hoy lo vas a entender línea por línea: llama a ansible-playbook, que lee
#    armar_reto.yml y aplica el ESTADO DESEADO en tu máquina. Eso es IaC.
#
# Provisionar archivos locales es seguro, así que este atajo aplica de una.
# Si querés ver antes qué haría sin tocar nada:
#     ansible-playbook armar_reto.yml -l local --check --diff
#
# Uso:   bash correr.sh
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

# 1) ¿Tenés todo lo necesario? Si falta algo, corta acá y te dice cómo instalarlo.
bash "${DIR}/comprobar_requisitos.sh"

echo
echo "=== Armando el banco de trabajo del reto (datos/reto/) ==="
# Si al instalar los paquetes te pide contraseña de sudo, corré a mano con -K:
#   ansible-playbook armar_reto.yml -l local -K
ansible-playbook "${DIR}/armar_reto.yml" -l local

echo
echo "Listo. Abrí la misión:"
echo "    cat ../datos/reto/MISION.txt"
echo
echo "Parte A — arreglá el playbook heredado hasta que la 2ª corrida dé changed=0:"
echo "    cd ../datos/reto && cp provisionar_reto.yml mi_provisionar.yml"
echo "    ansible-playbook mi_provisionar.yml -l local"
echo
echo "Auditá tu trabajo (desde playbooks/):"
echo "    ansible-playbook auditar_idempotencia.yml -l local"
echo
echo "Cuando tengas la bandera, verificala:"
echo "    ansible-playbook comprobar_bandera.yml -e \"bandera=BANDERA{...}\""
