#!/bin/bash

# RESET COMPLETO DO SERVIDOR - Funciona após hardening

TARGET="192.168.3.216"
USER="apolo"

echo "🔄 RESET COMPLETO DO SERVIDOR"
echo "============================="
echo "Servidor: $TARGET"
echo ""

# Tentar conectar na porta 2222 primeiro (após hardening)
echo "[1] Tentando conectar na porta 2222..."
if sshpass -p "123456789" ssh -p 2222 -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$USER@$TARGET" "echo 'Conectado'" 2>/dev/null; then
    echo "✅ Conectado na porta 2222"
    PORTA_SSH=2222
elif sshpass -p "123456789" ssh -p 22 -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$USER@$TARGET" "echo 'Conectado'" 2>/dev/null; then
    echo "✅ Conectado na porta 22"
    PORTA_SSH=22
else
    echo "❌ Não conseguiu conectar em nenhuma porta"
    echo "Acesse fisicamente o servidor e execute:"
    echo "sudo systemctl restart ssh"
    echo "sudo ufw --force disable"
    exit 1
fi

echo "[2] Resetando configurações..."
sshpass -p "123456789" ssh -p "$PORTA_SSH" -o StrictHostKeyChecking=no "$USER@$TARGET" "
# Parar todos os serviços de segurança
sudo systemctl stop fail2ban 2>/dev/null || true
sudo systemctl disable fail2ban 2>/dev/null || true
sudo systemctl stop auditd 2>/dev/null || true

# Desabilitar firewall completamente
sudo ufw --force reset 2>/dev/null || true
sudo ufw --force disable 2>/dev/null || true
sudo iptables -F 2>/dev/null || true
sudo iptables -X 2>/dev/null || true
sudo iptables -t nat -F 2>/dev/null || true
sudo iptables -t nat -X 2>/dev/null || true

# Restaurar SSH para configuração vulnerável
sudo bash -c 'cat > /etc/ssh/sshd_config << EOF
Port 22
Protocol 2
PermitRootLogin yes
PasswordAuthentication yes
PermitEmptyPasswords no
X11Forwarding yes
UsePAM yes
PubkeyAuthentication yes
ChallengeResponseAuthentication no
UseDNS no
EOF'

# Remover todas as configurações de hardening
sudo rm -rf /etc/audit/rules.d/security-hardening.rules 2>/dev/null || true
sudo rm -rf /etc/fail2ban/jail.local 2>/dev/null || true
sudo rm -rf /etc/security-hardening 2>/dev/null || true
sudo rm -rf /usr/local/bin/security-monitor.sh 2>/dev/null || true
sudo rm -rf /var/log/security-alerts.log 2>/dev/null || true
sudo rm -rf /var/log/compliance-report-*.json 2>/dev/null || true

# Remover grupo ssh-users e cron jobs de segurança
sudo groupdel ssh-users 2>/dev/null || true
sudo sed -i '/security-monitor.sh/d' /etc/crontab 2>/dev/null || true

# Restaurar kernel para configuração padrão
if [ -f /etc/sysctl.conf.backup ]; then
    sudo cp /etc/sysctl.conf.backup /etc/sysctl.conf
else
    # Remover configurações de hardening do kernel
    sudo sed -i '/# Security Hardening - Kernel Parameters/,/^$/d' /etc/sysctl.conf 2>/dev/null || true
fi
sudo sysctl -p 2>/dev/null || true

# Garantir usuário apolo com configuração vulnerável
sudo useradd -m -s /bin/bash apolo 2>/dev/null || true
echo 'apolo:123456789' | sudo chpasswd
sudo usermod -aG sudo apolo

# Reiniciar serviços
sudo systemctl restart ssh
sudo systemctl restart rsyslog 2>/dev/null || true

echo 'Reset completo executado - servidor vulnerável novamente'
"

# Aguardar SSH reiniciar
echo "[3] Aguardando SSH reiniciar na porta 22..."
sleep 5

# Testar conexão na porta 22
echo "[4] Testando conexão na porta 22..."
if sshpass -p "123456789" ssh -p 22 -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$USER@$TARGET" "echo 'SSH OK na porta 22'" 2>/dev/null; then
    echo "✅ SSH funcionando na porta 22!"
else
    echo "⚠️ SSH pode ainda estar reiniciando..."
fi

echo ""
✅ RESET COMPLETO CONCLUÍDO!"
echo "🔄 Todas as configurações de hardening removidas"
echo "🎯 SSH: porta 22 | Autenticação por senha habilitada"
echo "🎯 Firewall: completamente desabilitado"
echo "🎯 Fail2Ban: parado e desabilitado"
echo "🎯 Auditoria: regras de hardening removidas"
echo "🎯 Usuário: apolo com senha 123456789"
echo ""
echo "⚠️  Servidor agora está VULNERÁVEL novamente"
echo "Execute: make ataques"