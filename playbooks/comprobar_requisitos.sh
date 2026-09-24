#!/usr/bin/env bash
# comprobar_requisitos.sh — ¿tenés todo para hacer el reto de Ansible?
#
# Detecta tu distribución (Debian/Ubuntu, Arch, Fedora/RHEL) y, si algo falta,
# te dice el comando EXACTO para instalarlo. No instala nada por vos: solo
# comprueba y te guía (vos leés y corrés el comando con criterio).
#
# Uso:   bash comprobar_requisitos.sh
set -u

echo "=== Comprobando requisitos para el reto de Ansible + IaC ==="

# --- 1) Detectar el gestor de paquetes de tu distro ----------------------
if command -v apt-get >/dev/null 2>&1; then
  GESTOR="apt"
  INSTALAR="sudo apt update && sudo apt install -y"
  PKG_ANSIBLE="ansible"
  PKG_YAML="python3-yaml"
elif command -v pacman >/dev/null 2>&1; then
  GESTOR="pacman"
  INSTALAR="sudo pacman -Sy --needed"
  PKG_ANSIBLE="ansible"
  PKG_YAML="python-yaml"
elif command -v dnf >/dev/null 2>&1; then
  GESTOR="dnf"
  INSTALAR="sudo dnf install -y"
  PKG_ANSIBLE="ansible"
  PKG_YAML="python3-pyyaml"
else
  GESTOR="desconocido"
  INSTALAR=""
  PKG_ANSIBLE="ansible"
  PKG_YAML="pyyaml"
fi
echo "Distro / gestor de paquetes detectado: ${GESTOR}"
echo

# --- 2) Comprobar cada herramienta requerida -----------------------------
faltan=0

# $1 = comando a buscar, $2 = paquete a instalar si falta
comprobar() {
  local cmd="$1" pkg="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "  [OK]    ${cmd}  ->  $("$cmd" --version 2>&1 | head -n1)"
  else
    echo "  [FALTA] ${cmd}"
    if [ "$GESTOR" != "desconocido" ]; then
      echo "          instalalo con:  ${INSTALAR} ${pkg}"
    else
      echo "          gestor no reconocido; instalá '${pkg}' con el gestor de tu distro."
    fi
    faltan=$((faltan + 1))
  fi
}

comprobar ansible-playbook "$PKG_ANSIBLE"
comprobar python3 python3
comprobar gawk gawk

# La librería YAML de Python la usa Ansible por debajo. Si falta, avisamos.
if command -v python3 >/dev/null 2>&1; then
  if python3 -c "import yaml" >/dev/null 2>&1; then
    echo "  [OK]    python3 -c 'import yaml'  ->  la librería YAML está"
  else
    echo "  [FALTA] librería YAML de Python"
    echo "          instalala con:  ${INSTALAR} ${PKG_YAML}"
    faltan=$((faltan + 1))
  fi
fi

# --- 3) Resumen ----------------------------------------------------------
echo
if [ "$faltan" -eq 0 ]; then
  echo "=== Todo listo. Armá el reto: ==="
  echo "    ansible-playbook armar_reto.yml -l local --check --diff   # simular"
  echo "    ansible-playbook armar_reto.yml -l local                  # aplicar"
  exit 0
else
  echo "=== Faltan ${faltan} requisito(s). Instalalos (arriba te digo cómo) y volvé a correr este script. ==="
  exit 1
fi
