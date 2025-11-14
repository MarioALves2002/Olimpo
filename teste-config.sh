#!/bin/bash

# TESTE DE CONFIGURAÇÃO

echo "🔍 TESTANDO CONFIGURAÇÃO ATUAL"
echo "=============================="

# Verificar arquivo de configuração
if [ -f .current-target ]; then
    echo "✅ Arquivo .current-target encontrado"
    echo "Conteúdo:"
    cat .current-target
    echo ""
    
    # Carregar configuração
    source .current-target
    echo "📋 Configuração carregada:"
    echo "   TARGET_IP: $TARGET_IP"
    echo "   CURRENT_USER: $CURRENT_USER"
else
    echo "❌ Arquivo .current-target não encontrado"
fi

echo ""
echo "🎯 Teste do script de ataques:"

# Simular o que o script de ataques faz
if [ -f "$(dirname "$0")/../../.current-target" ]; then
    echo "✅ Caminho relativo funciona"
    source "$(dirname "$0")/../../.current-target"
elif [ -f ".current-target" ]; then
    echo "✅ Caminho direto funciona"
    source .current-target
else
    echo "❌ Nenhum caminho funciona"
fi

TARGET="$TARGET_IP"
USER="$CURRENT_USER"

echo "📊 Resultado final:"
echo "   TARGET: $TARGET"
echo "   USER: $USER"