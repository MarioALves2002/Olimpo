#!/bin/bash

# Comandos para executar na máquina alvo (já conectado via SSH)

set -e  # Parar em caso de erro

echo "🔄 Resetando para estado vulnerável..."

# 1. SSH vulnerável
sudo bash -c 'cat > /etc/ssh/sshd_config << EOF
Port 22
PermitRootLogin yes
PasswordAuthentication yes
PermitEmptyPasswords no
X11Forwarding yes
UsePAM yes
EOF'
sudo systemctl restart ssh

# 2. Desabilitar firewall
sudo ufw --force disable

# 3. Parar serviços de segurança
sudo systemctl stop fail2ban 2>/dev/null || true
sudo systemctl disable fail2ban 2>/dev/null || true

# 4. Remover auditoria
sudo rm -f /etc/audit/rules.d/security-hardening.rules 2>/dev/null || true

# 5. Restaurar kernel
if [ -f /etc/sysctl.conf.backup ]; then
    sudo cp /etc/sysctl.conf.backup /etc/sysctl.conf
    sudo sysctl -p
fi

# 6. Usuário apolo
sudo useradd -m -s /bin/bash apolo 2>/dev/null || true
echo "apolo:123456789" | sudo chpasswd || { echo "Erro ao definir senha"; exit 1; }
sudo usermod -aG sudo apolo || { echo "Erro ao adicionar ao grupo sudo"; exit 1; }

echo "✅ Reset concluído! Máquina vulnerável novamente."