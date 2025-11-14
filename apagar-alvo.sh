#!/bin/bash

# APAGAR ALVO ATUAL

# Ler configuração atual
if [ -f .current-target ]; then
    source .current-target
    USUARIO_ATUAL="$CURRENT_USER"
    TARGET="$TARGET_IP"
else
    # Fallback - pegar dos scripts
    USUARIO_ATUAL=$(grep 'USER=' pratica/vulnerabilidades/demo-vulnerabilities.sh | cut -d'"' -f2)
    TARGET="192.168.3.216"
fi

echo "🗑️ APAGANDO ALVO ATUAL"
echo "====================="
echo "Servidor: $TARGET"
echo "Usuário: $USUARIO_ATUAL"
echo ""

if [ -z "$USUARIO_ATUAL" ] || [ "$USUARIO_ATUAL" = "apolo" ]; then
    echo "⚠️ Usuário padrão ou não encontrado"
    echo "Apenas limpando sistema..."
else
    echo "[1] Removendo usuário $USUARIO_ATUAL..."
    
    # Tentar remover com diferentes usuários
    for user in root apolo professor ubuntu admin; do
        if ssh -o ConnectTimeout=5 $user@$TARGET "
        sudo pkill -u $USUARIO_ATUAL 2>/dev/null || true
        sudo userdel -r $USUARIO_ATUAL 2>/dev/null || true
        echo 'Usuario removido'
        " 2>/dev/null; then
            echo "✅ Usuário removido via $user"
            break
        fi
    done
fi

# Limpar sistema completamente
echo "[2] Limpeza completa do sistema..."
for user in root apolo professor ubuntu admin; do
    if ssh -o ConnectTimeout=5 $user@$TARGET "
    sudo systemctl stop fail2ban 2>/dev/null || true
    sudo fail2ban-client unban --all 2>/dev/null || true
    sudo ufw --force disable 2>/dev/null || true
    sudo iptables -F 2>/dev/null || true
    sudo > /var/log/auth.log 2>/dev/null || true
    sudo systemctl restart ssh 2>/dev/null || true
    echo 'Sistema limpo'
    " 2>/dev/null; then
        echo "✅ Sistema limpo via $user"
        break
    fi
done

# Resetar configuração
echo "[3] Resetando configuração..."
echo "CURRENT_USER=\"apolo\"" > .current-target
echo "TARGET_IP=\"192.168.3.216\"" >> .current-target

# Resetar scripts para padrão
sed -i 's/USER=".*"/USER="apolo"/' pratica/vulnerabilidades/demo-vulnerabilities.sh
sed -i 's/USER=".*"/USER="apolo"/' pratica/scripts/reset-target.sh
sed -i 's/TARGET=".*"/TARGET="192.168.3.216"/' pratica/vulnerabilidades/demo-vulnerabilities.sh
sed -i 's/TARGET=".*"/TARGET="192.168.3.216"/' pratica/scripts/reset-target.sh

echo ""
echo "✅ ALVO APAGADO COM SUCESSO!"
echo "🧹 Sistema completamente limpo"
echo "🔄 Configuração resetada"
echo ""
echo "Para nova demo: make gerar-alvo"