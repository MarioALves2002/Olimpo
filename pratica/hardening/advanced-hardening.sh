#!/bin/bash

# Sistema Avançado de Hardening
# Trabalho Final - Segurança da Informação

source "$(dirname "$0")/../scripts/logger.sh"

HARDENING_CONFIG="/etc/security-hardening"
COMPLIANCE_REPORT="/var/log/compliance-report-$(date +%Y%m%d).json"

# Verificar privilégios
check_privileges() {
    if [[ $EUID -ne 0 ]]; then
        log_message "ERROR" "Este script deve ser executado como root"
        exit 1
    fi
    log_message "INFO" "Privilégios administrativos verificados"
}

# Hardening do kernel
kernel_hardening() {
    log_message "INFO" "Aplicando hardening do kernel"
    
    backup_file "/etc/sysctl.conf"
    
    cat >> /etc/sysctl.conf << EOF

# Security Hardening - Kernel Parameters
# Network Security
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1

# Memory Protection
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.yama.ptrace_scope = 1
kernel.kexec_load_disabled = 1

# File System Security
fs.suid_dumpable = 0
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
EOF
    
    sysctl -p
    log_message "AUDIT" "Parâmetros de kernel aplicados"
}

# Configuração avançada do SSH
advanced_ssh_hardening() {
    log_message "INFO" "Aplicando hardening avançado do SSH"
    
    backup_file "/etc/ssh/sshd_config"
    
    cat > /etc/ssh/sshd_config << EOF
# Advanced SSH Security Configuration
Port 2222
Protocol 2
AddressFamily inet

# Host Keys
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key

# Ciphers and Algorithms (Strong only)
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-512
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512

# Authentication
LoginGraceTime 30
PermitRootLogin no
StrictModes yes
MaxAuthTries 3
MaxSessions 2
MaxStartups 10:30:60

PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes

# Network
X11Forwarding no
AllowTcpForwarding no
AllowStreamLocalForwarding no
GatewayPorts no
PermitTunnel no
AllowAgentForwarding no

# Logging
SyslogFacility AUTHPRIV
LogLevel VERBOSE

# Connection
ClientAliveInterval 300
ClientAliveCountMax 2
TCPKeepAlive no
Compression no

# Users and Groups
AllowUsers professor
DenyUsers root
AllowGroups ssh-users

# Banner
Banner /etc/issue.net
EOF
    
    # Criar grupo SSH
    groupadd -f ssh-users
    usermod -a -G ssh-users professor
    
    systemctl restart ssh
    log_message "AUDIT" "SSH hardening avançado aplicado"
}

# Configuração de auditoria avançada
advanced_audit_config() {
    log_message "INFO" "Configurando auditoria avançada"
    
    cat > /etc/audit/rules.d/security-hardening.rules << EOF
# Security Hardening Audit Rules

# Monitor authentication events
-w /var/log/auth.log -p wa -k authentication
-w /var/log/faillog -p wa -k logins
-w /var/log/lastlog -p wa -k logins

# Monitor system configuration changes
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/sudoers -p wa -k privilege_escalation
-w /etc/ssh/sshd_config -p wa -k ssh_config

# Monitor network configuration
-w /etc/hosts -p wa -k network_config
-w /etc/network/ -p wa -k network_config
-w /etc/netplan/ -p wa -k network_config

# Monitor critical system files
-w /boot -p wa -k boot_files
-w /etc/crontab -p wa -k scheduled_tasks
-w /etc/cron.allow -p wa -k scheduled_tasks
-w /etc/cron.deny -p wa -k scheduled_tasks

# Monitor file permissions
-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod

# Monitor process execution
-a always,exit -F arch=b64 -S execve -k process_execution
-a always,exit -F arch=b32 -S execve -k process_execution

# Monitor privilege escalation
-a always,exit -F arch=b64 -S setuid -S setgid -S setreuid -S setregid -k privilege_escalation
-a always,exit -F arch=b32 -S setuid -S setgid -S setreuid -S setregid -k privilege_escalation
EOF
    
    systemctl restart auditd
    log_message "AUDIT" "Regras de auditoria avançada configuradas"
}

# Sistema de monitoramento em tempo real
setup_monitoring() {
    log_message "INFO" "Configurando monitoramento em tempo real"
    
    # Script de monitoramento
    cat > /usr/local/bin/security-monitor.sh << 'EOF'
#!/bin/bash

ALERT_LOG="/var/log/security-alerts.log"
THRESHOLD_FAILED_LOGINS=5

monitor_failed_logins() {
    local count=$(grep "Failed password" /var/log/auth.log | grep "$(date +%b\ %d)" | wc -l)
    
    if [ $count -gt $THRESHOLD_FAILED_LOGINS ]; then
        echo "$(date): ALERT - $count failed login attempts detected" >> $ALERT_LOG
        # Aqui poderia enviar email ou notificação
    fi
}

monitor_privilege_escalation() {
    local sudo_count=$(grep "sudo:" /var/log/auth.log | grep "$(date +%b\ %d)" | wc -l)
    
    if [ $sudo_count -gt 10 ]; then
        echo "$(date): ALERT - Excessive sudo usage detected ($sudo_count times)" >> $ALERT_LOG
    fi
}

# Executar monitoramento
monitor_failed_logins
monitor_privilege_escalation
EOF
    
    chmod +x /usr/local/bin/security-monitor.sh
    
    # Cron job para monitoramento
    echo "*/5 * * * * root /usr/local/bin/security-monitor.sh" >> /etc/crontab
    
    log_message "AUDIT" "Sistema de monitoramento configurado"
}

# Configuração de Fail2Ban avançada
advanced_fail2ban() {
    log_message "INFO" "Configurando Fail2Ban avançado"
    
    cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
backend = systemd
banaction = ufw
chain = INPUT

[sshd]
enabled = true
port = 2222
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 7200

[sshd-ddos]
enabled = true
port = 2222
filter = sshd-ddos
logpath = /var/log/auth.log
maxretry = 2
bantime = 86400

[apache-auth]
enabled = false
port = http,https
filter = apache-auth
logpath = /var/log/apache*/*error.log
maxretry = 6

[apache-badbots]
enabled = false
port = http,https
filter = apache-badbots
logpath = /var/log/apache*/*access.log
maxretry = 2
EOF
    
    systemctl restart fail2ban
    log_message "AUDIT" "Fail2Ban avançado configurado"
}

# Configuração de firewall avançada
advanced_firewall() {
    log_message "INFO" "Configurando firewall avançado"
    
    # Reset UFW
    ufw --force reset
    
    # Políticas padrão
    ufw default deny incoming
    ufw default deny outgoing
    ufw default deny forward
    
    # Permitir saída essencial
    ufw allow out 53/udp comment 'DNS'
    ufw allow out 80/tcp comment 'HTTP'
    ufw allow out 443/tcp comment 'HTTPS'
    ufw allow out 123/udp comment 'NTP'
    
    # SSH seguro
    ufw allow from 192.168.3.0/24 to any port 2222 comment 'SSH from local network'
    
    # Logging
    ufw logging on
    
    # Rate limiting
    ufw limit 2222/tcp
    
    # Ativar firewall
    ufw --force enable
    
    log_message "AUDIT" "Firewall avançado configurado"
}

# Gerar relatório de compliance
generate_compliance_report() {
    log_message "INFO" "Gerando relatório de compliance"
    
    cat > "$COMPLIANCE_REPORT" << EOF
{
    "compliance_report": {
        "timestamp": "$(date -Iseconds)",
        "system": "$(uname -a)",
        "hardening_version": "2.0",
        "checks": [
            {
                "control": "SSH-001",
                "description": "SSH root login disabled",
                "status": "$(grep -q 'PermitRootLogin no' /etc/ssh/sshd_config && echo 'COMPLIANT' || echo 'NON_COMPLIANT')",
                "evidence": "$(grep 'PermitRootLogin' /etc/ssh/sshd_config)"
            },
            {
                "control": "SSH-002", 
                "description": "SSH password authentication disabled",
                "status": "$(grep -q 'PasswordAuthentication no' /etc/ssh/sshd_config && echo 'COMPLIANT' || echo 'NON_COMPLIANT')",
                "evidence": "$(grep 'PasswordAuthentication' /etc/ssh/sshd_config)"
            },
            {
                "control": "FW-001",
                "description": "Firewall enabled and configured",
                "status": "$(ufw status | grep -q 'Status: active' && echo 'COMPLIANT' || echo 'NON_COMPLIANT')",
                "evidence": "$(ufw status numbered)"
            },
            {
                "control": "AUDIT-001",
                "description": "System auditing enabled",
                "status": "$(systemctl is-active auditd | grep -q 'active' && echo 'COMPLIANT' || echo 'NON_COMPLIANT')",
                "evidence": "$(systemctl status auditd --no-pager -l)"
            }
        ],
        "recommendations": [
            "Regular security updates",
            "Periodic access review", 
            "Security awareness training",
            "Incident response testing"
        ]
    }
}
EOF
    
    log_message "AUDIT" "Relatório de compliance gerado: $COMPLIANCE_REPORT"
}

# Função principal
main() {
    log_message "INFO" "=== INICIANDO HARDENING AVANÇADO ==="
    
    check_privileges
    
    # Criar diretório de configuração
    mkdir -p "$HARDENING_CONFIG"
    
    # Executar hardening
    kernel_hardening
    advanced_ssh_hardening
    advanced_audit_config
    setup_monitoring
    advanced_fail2ban
    advanced_firewall
    
    # Gerar relatório
    generate_compliance_report
    
    log_message "INFO" "=== HARDENING AVANÇADO CONCLUÍDO ==="
    
    echo ""
    echo "🛡️  HARDENING AVANÇADO CONCLUÍDO"
    echo "================================"
    echo "✅ Kernel hardening aplicado"
    echo "✅ SSH configuração avançada"
    echo "✅ Auditoria em tempo real"
    echo "✅ Monitoramento ativo"
    echo "✅ Fail2Ban avançado"
    echo "✅ Firewall restritivo"
    echo ""
    echo "📊 Relatório de compliance: $COMPLIANCE_REPORT"
    echo "📝 Logs de auditoria: /var/log/security-audit/"
    echo ""
    echo "⚠️  IMPORTANTE: Teste a conectividade SSH antes de desconectar!"
    echo "   Comando: ssh -p 2222 -i ~/.ssh/id_rsa professor@localhost"
}

# Executar se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi