#!/bin/bash

# RESET COMPLETO DO SERVIDOR - Funciona após hardening

TARGET="192.168.3.216"
USER="apolo"

echo "🔄 RESET COMPLETO DO SERVIDOR"
echo "============================="
echo "Servidor: $TARGET"
echo ""

# Tentar conectar na porta 2222 primeiro (após hardening)
echo "[1] Tentando conectar na porta 2222..."
if sshpass -p "123456789" ssh -p 2222 -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$USER@$TARGET" "echo 'Conectado'" 2>/dev/null; then
    echo "✅ Conectado na porta 2222"
    PORTA_SSH=2222
elif sshpass -p "123456789" ssh -p 22 -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$USER@$TARGET" "echo 'Conectado'" 2>/dev/null; then
    echo "✅ Conectado na porta 22"
    PORTA_SSH=22
else
    echo "❌ Não conseguiu conectar em nenhuma porta"
    echo "Acesse fisicamente o servidor e execute:"
    echo "sudo systemctl restart ssh"
    echo "sudo ufw --force disable"
    exit 1
fi

echo "[2] RESET AGRESSIVO - Removendo TUDO..."
sshpass -p "123456789" ssh -p "$PORTA_SSH" -o StrictHostKeyChecking=no "$USER@$TARGET" "
# MATAR TODOS OS PROCESSOS DE SEGURANÇA
sudo pkill -f fail2ban 2>/dev/null || true
sudo pkill -f auditd 2>/dev/null || true
sudo systemctl stop fail2ban 2>/dev/null || true
sudo systemctl disable fail2ban 2>/dev/null || true
sudo systemctl stop auditd 2>/dev/null || true
sudo systemctl mask auditd 2>/dev/null || true

# DESTRUIR FIREWALL COMPLETAMENTE
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t nat -X
sudo iptables -t mangle -F
sudo iptables -t mangle -X
sudo ufw --force reset
sudo ufw --force disable
sudo systemctl stop ufw
sudo systemctl disable ufw

# SSH TOTALMENTE VULNERÁVEL
sudo bash -c 'cat > /etc/ssh/sshd_config << EOF
Port 22
PermitRootLogin yes
PasswordAuthentication yes
PermitEmptyPasswords yes
X11Forwarding yes
UsePAM yes
PubkeyAuthentication yes
ChallengeResponseAuthentication no
UseDNS no
MaxAuthTries 100
LoginGraceTime 600
ClientAliveInterval 0
EOF'

# APAGAR TUDO DE SEGURANÇA
sudo rm -rf /etc/audit/rules.d/* 2>/dev/null || true
sudo rm -rf /etc/fail2ban/jail.local 2>/dev/null || true
sudo rm -rf /etc/security-hardening 2>/dev/null || true
sudo rm -rf /usr/local/bin/security-monitor.sh 2>/dev/null || true
sudo rm -rf /var/log/security-* 2>/dev/null || true
sudo rm -rf /var/log/compliance-* 2>/dev/null || true
sudo rm -rf /etc/ssh/ssh_host_*key* 2>/dev/null || true

# REMOVER GRUPOS E RESTRIÇÕES
sudo groupdel ssh-users 2>/dev/null || true
sudo sed -i '/security-monitor/d' /etc/crontab 2>/dev/null || true
sudo crontab -r 2>/dev/null || true

# KERNEL TOTALMENTE INSEGURO
sudo bash -c 'cat > /etc/sysctl.conf << EOF
# Sistema TOTALMENTE vulnerável
net.ipv4.ip_forward = 1
net.ipv4.conf.all.send_redirects = 1
net.ipv4.conf.all.accept_redirects = 1
net.ipv4.conf.all.accept_source_route = 1
net.ipv4.conf.all.log_martians = 0
net.ipv4.icmp_echo_ignore_broadcasts = 0
net.ipv4.tcp_syncookies = 0
kernel.dmesg_restrict = 0
kernel.kptr_restrict = 0
kernel.yama.ptrace_scope = 0
fs.suid_dumpable = 2
EOF'
sudo sysctl -p

# USUÁRIO APOLO COM ACESSO TOTAL
sudo useradd -m -s /bin/bash apolo 2>/dev/null || true
echo 'apolo:123456789' | sudo chpasswd
sudo usermod -aG sudo,root,adm,sys apolo
sudo bash -c 'echo "apolo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers'

# GERAR CHAVES SSH FRACAS
sudo ssh-keygen -t rsa -b 1024 -f /etc/ssh/ssh_host_rsa_key -N '' 2>/dev/null || true
sudo ssh-keygen -t dsa -b 1024 -f /etc/ssh/ssh_host_dsa_key -N '' 2>/dev/null || true

# REINICIAR TUDO
sudo systemctl restart ssh
sudo systemctl restart networking 2>/dev/null || true
sudo systemctl restart systemd-networkd 2>/dev/null || true

echo 'SERVIDOR COMPLETAMENTE VULNERÁVEL - RESET AGRESSIVO CONCLUÍDO'
"

# Aguardar SSH reiniciar
echo "[3] Aguardando SSH reiniciar na porta 22..."
sleep 5

# Testar conexão na porta 22
echo "[4] Testando conexão na porta 22..."
if sshpass -p "123456789" ssh -p 22 -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$USER@$TARGET" "echo 'SSH OK na porta 22'" 2>/dev/null; then
    echo "✅ SSH funcionando na porta 22!"
else
    echo "⚠️ SSH pode ainda estar reiniciando..."
fi

echo ""
echo "💥 RESET AGRESSIVO CONCLUÍDO!"
echo "🔥 SERVIDOR MAXIMAMENTE VULNERÁVEL"
echo "🎯 SSH: porta 22 | Senhas vazias permitidas"
echo "🎯 Firewall: DESTRUÍDO completamente"
echo "🎯 Fail2Ban: MORTO e desabilitado"
echo "🎯 Auditoria: REMOVIDA completamente"
echo "🎯 Kernel: Parâmetros inseguros aplicados"
echo "🎯 Usuário: apolo com privilégios ROOT"
echo "🎯 Chaves SSH: Fracas (1024 bits)"
echo ""
echo "⚠️  ATENÇÃO: Servidor EXTREMAMENTE vulnerável!"
echo "🎯 Pronto para QUALQUER tipo de ataque"
echo "Execute: make ataques"