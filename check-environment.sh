#!/bin/bash

# Script para verificar ambiente antes da demonstração

echo "🔍 VERIFICANDO AMBIENTE PARA DEMONSTRAÇÃO"
echo "========================================"

# 1. Verificar conectividade com alvo
TARGET="192.168.3.216"
echo -n "[1] Conectividade com $TARGET ... "
if ping -c 1 "$TARGET" >/dev/null 2>&1; then
    echo "✅ OK"
else
    echo "❌ FALHOU"
    echo "    Configure a máquina alvo no IP $TARGET"
fi

# 2. Verificar dependências
echo "[2] Verificando dependências:"
for cmd in nmap sshpass ssh; do
    echo -n "    $cmd ... "
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "✅ OK"
    else
        echo "❌ FALTANDO"
        echo "    Instale com: sudo apt install $cmd"
    fi
done

# 3. Verificar acesso SSH
echo -n "[3] Acesso SSH ao alvo ... "
if timeout 5 ssh -o ConnectTimeout=3 -o StrictHostKeyChecking=no apolo@$TARGET "echo 'OK'" >/dev/null 2>&1; then
    echo "✅ OK"
else
    echo "❌ FALHOU"
    echo "    Configure usuário 'apolo' com senha '123456789' no alvo"
fi

# 4. Verificar permissões dos scripts
echo "[4] Verificando permissões dos scripts:"
for script in pratica/vulnerabilidades/demo-vulnerabilities.sh pratica/hardening/advanced-hardening.sh pratica/scripts/reset-target.sh; do
    echo -n "    $script ... "
    if [ -x "$script" ]; then
        echo "✅ OK"
    else
        echo "❌ SEM PERMISSÃO"
        chmod +x "$script" 2>/dev/null && echo "    Corrigido automaticamente"
    fi
done

echo ""
echo "🎯 AMBIENTE PRONTO PARA DEMONSTRAÇÃO!"
echo "Execute: make demo"