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
# Parar serviços de segurança
sudo systemctl stop fail2ban 2>/dev/null || true
sudo systemctl stop auditd 2>/dev/null || true

# Desabilitar firewall completamente
sudo ufw --force reset 2>/dev/null || true
sudo ufw --force disable 2>/dev/null || true
sudo iptables -F 2>/dev/null || true

# Restaurar SSH para porta 22
sudo bash -c 'cat > /etc/ssh/sshd_config << EOF
Port 22
PermitRootLogin yes
PasswordAuthentication yes
PermitEmptyPasswords no
X11Forwarding yes
UsePAM yes
EOF'

# Reiniciar SSH
sudo systemctl restart ssh

# Limpar configurações de hardening
sudo rm -rf /etc/audit/rules.d/security-hardening.rules 2>/dev/null || true
sudo rm -rf /etc/fail2ban/jail.local 2>/dev/null || true

# Restaurar kernel se backup existir
if [ -f /etc/sysctl.conf.backup ]; then
    sudo cp /etc/sysctl.conf.backup /etc/sysctl.conf
    sudo sysctl -p 2>/dev/null || true
fi

# Garantir usuário apolo
sudo useradd -m -s /bin/bash apolo 2>/dev/null || true
echo 'apolo:123456789' | sudo chpasswd
sudo usermod -aG sudo apolo

echo 'Reset completo executado'
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
echo "✅ RESET COMPLETO CONCLUÍDO!"
echo "🔄 Servidor voltou ao estado original"
echo "🎯 SSH na porta 22, firewall desabilitado"
echo "🎯 Usuário apolo com senha 123456789"
echo ""
echo "Execute: make ataques"