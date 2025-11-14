#!/bin/bash

# GERAR ALVO DESCARTÁVEL

TARGET="192.168.3.216"
USUARIO="vitima$(date +%H%M%S)"

echo "🎯 GERANDO NOVO ALVO DESCARTÁVEL"
echo "================================"
echo "Servidor: $TARGET"
echo "Usuário: $USUARIO"
echo ""

# Verificar conectividade
if ! ping -c 1 "$TARGET" >/dev/null 2>&1; then
    echo "❌ ERRO: Servidor $TARGET não responde"
    exit 1
fi

# Conectar como root e criar usuário
echo "[1] Criando usuário descartável..."
if ssh -o ConnectTimeout=5 root@$TARGET "
useradd -m -s /bin/bash $USUARIO 2>/dev/null
echo '$USUARIO:123456789' | chpasswd
usermod -aG sudo $USUARIO
echo 'Usuario $USUARIO criado'
" 2>/dev/null; then
    echo "✅ Usuário criado com sucesso"
else
    echo "⚠️ Tentando com usuário existente..."
    # Tentar com usuário existente que tenha sudo
    for user in apolo professor ubuntu admin; do
        if ssh -o ConnectTimeout=5 $user@$TARGET "
        sudo useradd -m -s /bin/bash $USUARIO 2>/dev/null || true
        echo '$USUARIO:123456789' | sudo chpasswd
        sudo usermod -aG sudo $USUARIO
        echo 'Usuario $USUARIO criado via $user'
        " 2>/dev/null; then
            echo "✅ Usuário criado via $user"
            break
        fi
    done
fi

# Atualizar arquivo de configuração
echo "[2] Atualizando configuração..."
echo "CURRENT_USER=\"$USUARIO\"" > .current-target
echo "TARGET_IP=\"$TARGET\"" >> .current-target

# Atualizar scripts
sed -i "s/USER=\".*\"/USER=\"$USUARIO\"/" pratica/vulnerabilidades/demo-vulnerabilities.sh
sed -i "s/USER=\".*\"/USER=\"$USUARIO\"/" pratica/scripts/reset-target.sh
sed -i "s/TARGET=\".*\"/TARGET=\"$TARGET\"/" pratica/vulnerabilidades/demo-vulnerabilities.sh
sed -i "s/TARGET=\".*\"/TARGET=\"$TARGET\"/" pratica/scripts/reset-target.sh

# Limpar sistema
echo "[3] Limpando sistema..."
ssh $USUARIO@$TARGET "
sudo systemctl stop fail2ban 2>/dev/null || true
sudo ufw --force disable 2>/dev/null || true
sudo iptables -F 2>/dev/null || true
" 2>/dev/null || echo "Sistema já limpo"

echo ""
echo "✅ ALVO GERADO COM SUCESSO!"
echo "👤 Usuário: $USUARIO"
echo "🔑 Senha: 123456789"
echo "🎯 Sistema limpo e pronto!"
echo ""
echo "Execute: make ataques"