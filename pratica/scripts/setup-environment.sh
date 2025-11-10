#!/bin/bash

# Setup Ambiente Vulnerável - Trabalho Final Segurança
# ATENÇÃO: Apenas para demonstração acadêmica

set -e

[[ $EUID -ne 0 ]] && { echo "Execute como root: sudo $0"; exit 1; }

echo "🔧 Configurando ambiente vulnerável..."

# Instalar dependências essenciais
apt update -qq && apt install -y openssh-server fail2ban ufw rsyslog auditd

# Backup configuração SSH
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup 2>/dev/null || true

# SSH vulnerável para demonstração
cat > /etc/ssh/sshd_config << 'EOF'
Port 22
PermitRootLogin yes
PasswordAuthentication yes
PermitEmptyPasswords no
X11Forwarding yes
UsePAM yes
EOF

# Usuário de teste
useradd -m -s /bin/bash professor 2>/dev/null || true
echo "professor:123456" | chpasswd
usermod -aG sudo professor

# Desabilitar segurança para demonstração
ufw --force disable
systemctl restart ssh

echo "✅ Ambiente vulnerável configurado!"
echo "   Usuário: professor | Senha: 123456"
echo "   SSH: porta 22 | Firewall: desabilitado"