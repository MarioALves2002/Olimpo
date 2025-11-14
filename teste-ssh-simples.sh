#!/bin/bash

# TESTE SSH SIMPLES

TARGET="192.168.3.216"
USER="apolo"

echo "🔍 TESTE SSH SIMPLES"
echo "==================="

# 1. Ping
echo -n "[1] Ping: "
if ping -c 1 "$TARGET" >/dev/null 2>&1; then
    echo "✅ OK"
else
    echo "❌ FALHOU"
    exit 1
fi

# 2. Portas SSH
echo "[2] Testando portas SSH:"
for porta in 22 2222; do
    echo -n "   Porta $porta: "
    if timeout 3 nc -z "$TARGET" "$porta" 2>/dev/null; then
        echo "✅ ABERTA"
        PORTA_ATIVA=$porta
    else
        echo "❌ FECHADA"
    fi
done

if [ -z "$PORTA_ATIVA" ]; then
    echo "❌ NENHUMA PORTA SSH ABERTA!"
    exit 1
fi

# 3. Teste de autenticação
echo "[3] Teste de autenticação na porta $PORTA_ATIVA:"
for senha in "123456789" "apolo" "password" "123456"; do
    echo -n "   Senha '$senha': "
    if timeout 5 sshpass -p "$senha" ssh -p "$PORTA_ATIVA" -o ConnectTimeout=3 -o StrictHostKeyChecking=no "$USER@$TARGET" "echo 'OK'" 2>/dev/null | grep -q "OK"; then
        echo "✅ FUNCIONA"
        SENHA_CORRETA="$senha"
        break
    else
        echo "❌ Falhou"
    fi
done

# 4. Resultado
echo ""
echo "📊 RESULTADO:"
if [ -n "$SENHA_CORRETA" ]; then
    echo "✅ SSH funcionando na porta $PORTA_ATIVA"
    echo "✅ Senha correta: $SENHA_CORRETA"
    
    # Teste adicional - verificar se SSH continua funcionando
    echo ""
    echo "[4] Teste de estabilidade (5 conexões):"
    for i in {1..5}; do
        echo -n "   Conexão $i: "
        if timeout 5 sshpass -p "$SENHA_CORRETA" ssh -p "$PORTA_ATIVA" -o ConnectTimeout=3 -o StrictHostKeyChecking=no "$USER@$TARGET" "echo 'Teste $i'" 2>/dev/null | grep -q "Teste $i"; then
            echo "✅ OK"
        else
            echo "❌ FALHOU"
            echo "⚠️ SSH pode estar instável ou sendo bloqueado"
            break
        fi
        sleep 1
    done
    
else
    echo "❌ SSH não está funcionando corretamente"
fi

echo ""
echo "🎯 Use esta configuração para os ataques:"
echo "   Porta: $PORTA_ATIVA"
echo "   Senha: $SENHA_CORRETA"