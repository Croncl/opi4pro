#!/bin/bash
# Garante execução como root
if [ "$EUID" -ne 0 ]; then
  echo "Execute como root (sudo ./setup-ssh.sh)"
  exit 1
fi

echo "[+] Atualizando listas de pacotes e instalando o servidor SSH..."
apt update && apt install -y openssh-server

echo "[+] Configurando acesso SSH seguro..."

# Cria o diretório de configuração se não existir e o arquivo customizado
mkdir -p /etc/ssh/sshd_config.d
cat <<EOF > /etc/ssh/sshd_config.d/99-custom-access.conf
PermitRootLogin yes
PasswordAuthentication yes
KbdInteractiveAuthentication yes
UsePAM yes
EOF

# Define a senha padrão do root (recomenda-se alterar depois)
echo "root:orangepi" | chpasswd

# Habilita e reinicia o serviço SSH
systemctl enable ssh
systemctl restart ssh

echo "[✔] SSH configurado com sucesso! Root liberado, serviço instalado e senha definida."
