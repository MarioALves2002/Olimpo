#!/bin/bash

# Reset da Máquina Alvo - Voltar ao Estado Vulnerável

TARGET="192.168.3.216"
USER="apolo"

# Verificar conectividade
if ! ping -c 1 "$TARGET" >/dev/null 2>&1; then
    echo "❌ ERRO: Não foi possível conectar com $TARGET"
    exit 1
fi

echo "🔄 RESETANDO MÁQUINA ALVO PARA ESTADO VULNERÁVEL"
echo "================================================"
echo "Alvo: $TARGET"
echo ""

# 1. Restaurar SSH vulnerável
echo "[1] Restaurando SSH vulnerável..."
ssh $USER@$TARGET "sudo bash -c '
cat > /etc/ssh/sshd_config << EOF
Port 22
PermitRootLogin yes
PasswordAuthentication yes
PermitEmptyPasswords no
X11Forwarding yes
UsePAM yes
EOF
systemctl restart ssh
'"

# 2. Desabilitar firewall
echo "[2] Desabilitando firewall..."
ssh $USER@$TARGET "sudo ufw --force disable"

# 3. Parar serviços de segurança
echo "[3] Parando serviços de segurança..."
ssh $USER@$TARGET "sudo systemctl stop fail2ban 2>/dev/null || true"
ssh $USER@$TARGET "sudo systemctl disable fail2ban 2>/dev/null || true"

# 4. Remover regras de auditoria
echo "[4] Removendo auditoria..."
ssh $USER@$TARGET "sudo rm -f /etc/audit/rules.d/security-hardening.rules 2>/dev/null || true"

# 5. Restaurar configurações de kernel
echo "[5] Restaurando kernel..."
ssh $USER@$TARGET "sudo bash -c '
if [ -f /etc/sysctl.conf.backup ]; then
    cp /etc/sysctl.conf.backup /etc/sysctl.conf
    sysctl -p
fi
'"

# 6. Garantir usuário vulnerável
echo "[6] Configurando usuário vulnerável..."
ssh $USER@$TARGET "sudo bash -c '
useradd -m -s /bin/bash apolo 2>/dev/null || true
echo \"apolo:123456789\" | chpasswd
usermod -aG sudo apolo
'"

echo ""
echo "✅ RESET CONCLUÍDO!"
echo "🔴 Máquina alvo está VULNERÁVEL novamente"
echo "🎯 Pronta para demonstração de ataques"
echo ""
echo "Execute: make ataques"