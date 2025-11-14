#!/bin/bash

# ATUALIZAR ALVO MANUALMENTE

echo "🎯 ATUALIZAR CONFIGURAÇÃO DO ALVO"
echo "================================="

# Solicitar informações do usuário
read -p "Digite o nome do usuário criado no servidor: " USUARIO
read -p "Digite o IP do servidor (padrão: 192.168.3.216): " IP

# Usar padrão se não informado
if [ -z "$IP" ]; then
    IP="192.168.3.216"
fi

# Atualizar arquivo de configuração
echo "CURRENT_USER=\"$USUARIO\"" > .current-target
echo "TARGET_IP=\"$IP\"" >> .current-target

echo ""
echo "✅ CONFIGURAÇÃO ATUALIZADA!"
echo "👤 Usuário: $USUARIO"
echo "🎯 Servidor: $IP"
echo ""
echo "Agora execute: make ataques"