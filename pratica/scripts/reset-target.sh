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

# Detectar porta SSH ativa
echo "[0] Detectando porta SSH..."
PORTA_SSH=""
for porta in 2222 22; do
    echo -n "   Testando porta $porta: "
    if timeout 5 nc -z "$TARGET" "$porta" 2>/dev/null; then
        echo "✅ ENCONTRADA"
        PORTA_SSH=$porta
        break
    else
        echo "❌ Fechada"
    fi
done

if [ -z "$PORTA_SSH" ]; then
    echo "❌ ERRO: Nenhuma porta SSH encontrada!"
    echo "Acesse fisicamente o servidor e execute:"
    echo "sudo systemctl start ssh"
    exit 1
fi

echo "🎯 Usando porta SSH: $PORTA_SSH"
echo ""

# 1. Restaurar SSH vulnerável para porta 22
echo "[1] Restaurando SSH para porta 22..."
ssh -p $PORTA_SSH $USER@$TARGET "sudo bash -c '
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

# Aguardar SSH reiniciar
echo "   Aguardando SSH reiniciar..."
sleep 5

# 2. Desabilitar firewall (agora na porta 22)
echo "[2] Desabilitando firewall..."
ssh -p 22 $USER@$TARGET "sudo ufw --force disable" 2>/dev/null || \
ssh -p $PORTA_SSH $USER@$TARGET "sudo ufw --force disable"

# 3. Parar serviços de segurança
echo "[3] Parando serviços de segurança..."
ssh -p 22 $USER@$TARGET "sudo systemctl stop fail2ban 2>/dev/null || true" 2>/dev/null || \
ssh -p $PORTA_SSH $USER@$TARGET "sudo systemctl stop fail2ban 2>/dev/null || true"

ssh -p 22 $USER@$TARGET "sudo systemctl disable fail2ban 2>/dev/null || true" 2>/dev/null || \
ssh -p $PORTA_SSH $USER@$TARGET "sudo systemctl disable fail2ban 2>/dev/null || true"

# 4. Remover regras de auditoria
echo "[4] Removendo auditoria..."
ssh -p 22 $USER@$TARGET "sudo rm -f /etc/audit/rules.d/security-hardening.rules 2>/dev/null || true" 2>/dev/null || \
ssh -p $PORTA_SSH $USER@$TARGET "sudo rm -f /etc/audit/rules.d/security-hardening.rules 2>/dev/null || true"

# 5. Restaurar configurações de kernel
echo "[5] Restaurando kernel..."
ssh -p 22 $USER@$TARGET "sudo bash -c '
if [ -f /etc/sysctl.conf.backup ]; then
    cp /etc/sysctl.conf.backup /etc/sysctl.conf
    sysctl -p
fi
'" 2>/dev/null || ssh -p $PORTA_SSH $USER@$TARGET "sudo bash -c '
if [ -f /etc/sysctl.conf.backup ]; then
    cp /etc/sysctl.conf.backup /etc/sysctl.conf
    sysctl -p
fi
'"

# 6. Garantir usuário vulnerável
echo "[6] Configurando usuário vulnerável..."
ssh -p 22 $USER@$TARGET "sudo bash -c '
useradd -m -s /bin/bash apolo 2>/dev/null || true
echo \"apolo:123456789\" | chpasswd
usermod -aG sudo apolo
'" 2>/dev/null || ssh -p $PORTA_SSH $USER@$TARGET "sudo bash -c '
useradd -m -s /bin/bash apolo 2>/dev/null || true
echo \"apolo:123456789\" | chpasswd
usermod -aG sudo apolo
'"

# 7. Verificar se SSH está funcionando na porta 22
echo "[7] Verificando SSH na porta 22..."
if timeout 10 ssh -p 22 $USER@$TARGET "echo 'SSH OK na porta 22'" 2>/dev/null; then
    echo "✅ SSH funcionando na porta 22!"
else
    echo "⚠️ SSH pode ainda estar reiniciando..."
fi

echo ""
echo "✅ RESET CONCLUÍDO!"
echo "🔴 Máquina alvo está VULNERÁVEL novamente"
echo "🎯 SSH agora está na PORTA 22"
echo "🎯 Pronta para demonstração de ataques"
echo ""
echo "Execute: make ataques"