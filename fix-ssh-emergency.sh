#!/bin/bash

# SCRIPT DE EMERGÊNCIA - Corrigir SSH

echo "🚨 CORREÇÃO DE EMERGÊNCIA DO SSH"
echo "================================"

TARGET="192.168.3.216"
USER="apolo"

# 1. Tentar conectar na porta 2222 primeiro
echo "[1] Tentando conectar na porta 2222..."
if ssh -p 2222 $USER@$TARGET "echo 'Conectado na 2222'" 2>/dev/null; then
    echo "✅ Conectado na porta 2222"
    
    # Corrigir SSH para porta 22
    echo "[2] Corrigindo SSH para porta 22..."
    ssh -p 2222 $USER@$TARGET "
    sudo bash -c 'cat > /etc/ssh/sshd_config << EOF
Port 22
PermitRootLogin yes
PasswordAuthentication yes
PermitEmptyPasswords no
X11Forwarding yes
UsePAM yes
EOF'
    sudo systemctl restart ssh
    echo 'SSH corrigido para porta 22'
    "
    
    echo "✅ SSH corrigido! Agora use porta 22"
    
elif ssh -p 22 $USER@$TARGET "echo 'Conectado na 22'" 2>/dev/null; then
    echo "✅ SSH já está na porta 22"
    
else
    echo "❌ Não conseguiu conectar em nenhuma porta"
    echo ""
    echo "🔧 SOLUÇÕES MANUAIS:"
    echo "1. Acesse fisicamente o servidor"
    echo "2. Execute os comandos:"
    echo "   sudo systemctl start ssh"
    echo "   sudo systemctl enable ssh"
    echo "   sudo ufw allow 22/tcp"
    echo "   sudo ufw disable"
    echo ""
    echo "3. Ou reinicie o servidor"
    exit 1
fi

# 2. Testar conexão na porta 22
echo "[3] Testando conexão final na porta 22..."
if ssh -p 22 $USER@$TARGET "echo 'SSH funcionando na porta 22'" 2>/dev/null; then
    echo "✅ SSH funcionando perfeitamente na porta 22!"
else
    echo "⚠️ SSH pode estar reiniciando, aguarde 10 segundos..."
    sleep 10
    if ssh -p 22 $USER@$TARGET "echo 'SSH OK'" 2>/dev/null; then
        echo "✅ SSH funcionando na porta 22!"
    else
        echo "❌ Ainda com problemas no SSH"
    fi
fi

echo ""
echo "🎯 Agora execute: make ataques"