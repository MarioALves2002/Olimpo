#!/bin/bash

# RESET AGRESSIVO LOCAL - Para executar DENTRO do servidor

echo "💥 RESET AGRESSIVO LOCAL - DESTRUINDO SEGURANÇA"
echo "==============================================="

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

# REMOVER GRUPOS E RESTRIÇÕES
sudo groupdel ssh-users 2>/dev/null || true
sudo sed -i '/security-monitor/d' /etc/crontab 2>/dev/null || true

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
sudo rm -f /etc/ssh/ssh_host_*key* 2>/dev/null || true
sudo ssh-keygen -t rsa -b 1024 -f /etc/ssh/ssh_host_rsa_key -N '' 2>/dev/null || true
sudo ssh-keygen -t dsa -b 1024 -f /etc/ssh/ssh_host_dsa_key -N '' 2>/dev/null || true

# REINICIAR SERVIÇOS
sudo systemctl restart ssh
sudo systemctl restart rsyslog 2>/dev/null || true

echo ""
echo "🔥 RESET AGRESSIVO CONCLUÍDO!"
echo "💀 Servidor MAXIMAMENTE vulnerável"
echo "🎯 SSH: porta 22, senhas vazias OK"
echo "🎯 Firewall: DESTRUÍDO"
echo "🎯 Usuário apolo: privilégios ROOT"
echo "🎯 Pronto para ATAQUES!"