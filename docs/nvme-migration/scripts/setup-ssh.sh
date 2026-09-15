#!/bin/bash
# Garante execução como root
if [ "$EUID" -ne 0 ]; then
  echo "Execute como root (sudo ./setup-ssh.sh)"
  exit 1
fi

echo "[+] Configurando acesso SSH seguro..."

# Cria o arquivo de configuração customizada do SSH
cat <<EOF > /etc/ssh/sshd_config.d/99-custom-access.conf
PermitRootLogin yes
PasswordAuthentication yes
KbdInteractiveAuthentication yes
UsePAM yes
EOF

# Define a senha padrão do root (recomenda-se alterar depois)
echo "root:orangepi" | chpasswd

# Reinicia o serviço SSH
systemctl enable ssh
systemctl restart ssh

echo "[✔] SSH configurado com sucesso! Root liberado e senha definida."
