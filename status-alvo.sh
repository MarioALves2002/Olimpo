#!/bin/bash

# STATUS DO ALVO ATUAL

# Ler configuração
if [ -f .current-target ]; then
    source .current-target
    USUARIO="$CURRENT_USER"
    TARGET="$TARGET_IP"
else
    USUARIO="apolo"
    TARGET="192.168.3.216"
fi

echo "📊 STATUS DO ALVO ATUAL"
echo "======================="
echo "Servidor: $TARGET"
echo "Usuário: $USUARIO"
echo ""

# 1. Conectividade
echo -n "[1] Conectividade: "
if ping -c 1 "$TARGET" >/dev/null 2>&1; then
    echo "✅ OK"
else
    echo "❌ FALHOU"
    exit 1
fi

# 2. SSH
echo "[2] SSH:"
for porta in 22 2222; do
    echo -n "   Porta $porta: "
    if timeout 3 nc -z "$TARGET" "$porta" 2>/dev/null; then
        echo "✅ ABERTA"
        PORTA_SSH=$porta
    else
        echo "❌ FECHADA"
    fi
done

# 3. Autenticação
if [ -n "$PORTA_SSH" ]; then
    echo -n "[3] Autenticação: "
    if timeout 5 sshpass -p "123456789" ssh -p "$PORTA_SSH" -o ConnectTimeout=3 -o StrictHostKeyChecking=no "$USUARIO@$TARGET" "echo 'OK'" 2>/dev/null | grep -q "OK"; then
        echo "✅ OK (senha: 123456789)"
    else
        echo "❌ FALHOU"
    fi
else
    echo "[3] Autenticação: ❌ SSH não disponível"
fi

# 4. Privilégios
echo -n "[4] Privilégios sudo: "
if timeout 5 sshpass -p "123456789" ssh -p "${PORTA_SSH:-22}" -o ConnectTimeout=3 -o StrictHostKeyChecking=no "$USUARIO@$TARGET" "sudo -n true" 2>/dev/null; then
    echo "✅ OK"
else
    echo "⚠️ Pode precisar de senha"
fi

echo ""
echo "🎯 RESUMO:"
if [ -n "$PORTA_SSH" ]; then
    echo "✅ Alvo pronto para ataques"
    echo "   Comando: make ataques"
else
    echo "❌ Alvo não está acessível"
    echo "   Solução: make gerar-alvo"
fi