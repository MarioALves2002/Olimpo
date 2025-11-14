#!/bin/bash

# DIAGNÓSTICO COMPLETO

TARGET="192.168.3.216"
USER="apolo"

echo "🔍 DIAGNÓSTICO COMPLETO DO PROBLEMA"
echo "=================================="

# 1. Teste de conectividade básica
echo "[1] Teste de conectividade:"
if ping -c 1 "$TARGET" >/dev/null 2>&1; then
    echo "✅ Ping OK - máquina responde"
else
    echo "❌ Ping FALHOU - máquina não responde"
    exit 1
fi

# 2. Teste de portas SSH
echo "[2] Testando portas SSH:"
for porta in 22 2222; do
    echo -n "   Porta $porta: "
    if timeout 5 nc -z "$TARGET" "$porta" 2>/dev/null; then
        echo "✅ ABERTA"
        PORTA_SSH=$porta
    else
        echo "❌ FECHADA"
    fi
done

if [ -z "$PORTA_SSH" ]; then
    echo "❌ NENHUMA PORTA SSH ENCONTRADA!"
    echo ""
    echo "🔧 SOLUÇÕES:"
    echo "1. Acesse fisicamente o servidor $TARGET"
    echo "2. Execute: sudo systemctl start ssh"
    echo "3. Execute: sudo systemctl enable ssh"
    echo "4. Execute: sudo ufw allow 22/tcp"
    exit 1
fi

# 3. Teste de autenticação
echo "[3] Testando autenticação na porta $PORTA_SSH:"
if timeout 10 sshpass -p "123456789" ssh -p "$PORTA_SSH" -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$USER@$TARGET" "echo 'AUTH_OK'" 2>/dev/null | grep -q "AUTH_OK"; then
    echo "✅ Autenticação OK com senha 123456789"
    SENHA_OK="123456789"
else
    echo "❌ Senha 123456789 não funciona"
    
    # Testar outras senhas
    for senha in "apolo" "password" "123456" "admin"; do
        echo -n "   Testando senha '$senha': "
        if timeout 10 sshpass -p "$senha" ssh -p "$PORTA_SSH" -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$USER@$TARGET" "echo 'OK'" 2>/dev/null | grep -q "OK"; then
            echo "✅ FUNCIONA"
            SENHA_OK="$senha"
            break
        else
            echo "❌ Falhou"
        fi
    done
fi

# 4. Resultado final
echo ""
echo "📊 DIAGNÓSTICO FINAL:"
echo "===================="
if [ -n "$PORTA_SSH" ] && [ -n "$SENHA_OK" ]; then
    echo "✅ SSH funcionando na porta $PORTA_SSH"
    echo "✅ Senha funcionando: $SENHA_OK"
    echo ""
    echo "🔧 CORREÇÃO AUTOMÁTICA:"
    
    # Corrigir configuração
    ssh -p "$PORTA_SSH" "$USER@$TARGET" "
    sudo bash -c 'cat > /etc/ssh/sshd_config << EOF
Port 22
PermitRootLogin yes
PasswordAuthentication yes
PermitEmptyPasswords no
X11Forwarding yes
UsePAM yes
EOF'
    sudo systemctl restart ssh
    sudo ufw --force disable
    echo 'apolo:123456789' | sudo chpasswd
    "
    
    echo "✅ Configuração corrigida!"
    echo "🎯 Agora execute: make ataques"
    
else
    echo "❌ SSH não está funcionando corretamente"
    echo ""
    echo "🚨 ACESSE FISICAMENTE O SERVIDOR E EXECUTE:"
    echo "sudo systemctl start ssh"
    echo "sudo systemctl enable ssh"
    echo "sudo ufw --force disable"
    echo "echo 'apolo:123456789' | sudo chpasswd"
fi