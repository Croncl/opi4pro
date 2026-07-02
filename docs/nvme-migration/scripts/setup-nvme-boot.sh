#!/bin/bash
#
# setup-nvme-boot.sh
# Automatiza a Fase 4 (drivers NVMe no initramfs) e a Fase 8 (hook para
# futuras atualizações de kernel) do guia de migração do Orange Pi 4 Pro
# para NVMe.
#
# Uso:
#   sudo ./setup-nvme-boot.sh
#
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Este script precisa ser executado como root (use sudo)." >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_FILE="/etc/initramfs-tools/modules"
HOOK_DEST="/etc/initramfs-tools/hooks/nvme-drivers"
HOOK_SRC="${SCRIPT_DIR}/nvme-drivers-hook"

echo "==> Verificando módulos NVMe em ${MODULES_FILE}"
for mod in nvme nvme_core nvme_pci; do
    if grep -qx "$mod" "$MODULES_FILE" 2>/dev/null; then
        echo "    - $mod já presente, ok."
    else
        echo "    - adicionando $mod"
        echo "$mod" >> "$MODULES_FILE"
    fi
done

echo "==> Instalando hook de proteção em ${HOOK_DEST}"
if [ ! -f "$HOOK_SRC" ]; then
    echo "Erro: não encontrei ${HOOK_SRC}" >&2
    exit 1
fi
cp "$HOOK_SRC" "$HOOK_DEST"
chmod +x "$HOOK_DEST"

echo "==> Regenerando o initramfs"
update-initramfs -u

echo ""
echo "✅ Concluído."
echo "   - Drivers NVMe garantidos em ${MODULES_FILE}"
echo "   - Hook instalado em ${HOOK_DEST}"
echo ""
echo "Lembre-se: as demais fases (particionamento, nand-sata-install,"
echo "fstab, orangepiEnv.txt e montagem do SD em /boot) ainda precisam"
echo "ser feitas manualmente — veja o README.md."
