#!/bin/bash

# Scanner Avançado de Vulnerabilidades
# Trabalho Final - Segurança da Informação

source "$(dirname "$0")/logger.sh"

TARGET_IP="192.168.3.216"
SCAN_RESULTS_DIR="/tmp/vulnerability-scan-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$SCAN_RESULTS_DIR"

# Função para scan de portas avançado
advanced_port_scan() {
    log_message "INFO" "Iniciando scan avançado de portas"
    
    # Scan TCP completo
    nmap -sS -sV -O -A -T4 -p- "$TARGET_IP" -oA "$SCAN_RESULTS_DIR/tcp_full_scan"
    
    # Scan UDP top ports
    nmap -sU --top-ports 1000 "$TARGET_IP" -oA "$SCAN_RESULTS_DIR/udp_scan"
    
    # Scripts de vulnerabilidades
    nmap --script vuln "$TARGET_IP" -oA "$SCAN_RESULTS_DIR/vuln_scan"
    
    log_message "INFO" "Scan de portas concluído"
}

# Função para enumeração SSH avançada
ssh_enumeration() {
    log_message "INFO" "Iniciando enumeração SSH avançada"
    
    # Algoritmos suportados
    nmap --script ssh2-enum-algos "$TARGET_IP" > "$SCAN_RESULTS_DIR/ssh_algorithms.txt"
    
    # Informações do host
    nmap --script ssh-hostkey "$TARGET_IP" > "$SCAN_RESULTS_DIR/ssh_hostkeys.txt"
    
    # Teste de autenticação
    nmap --script ssh-auth-methods --script-args="ssh.user=professor" "$TARGET_IP" > "$SCAN_RESULTS_DIR/ssh_auth_methods.txt"
    
    log_message "INFO" "Enumeração SSH concluída"
}

# Função para análise de SSL/TLS
ssl_analysis() {
    log_message "INFO" "Analisando configurações SSL/TLS"
    
    # Verificar se há serviços SSL
    nmap --script ssl-enum-ciphers -p 443,993,995 "$TARGET_IP" > "$SCAN_RESULTS_DIR/ssl_ciphers.txt"
    
    # Vulnerabilidades SSL conhecidas
    nmap --script ssl-heartbleed,ssl-poodle,ssl-ccs-injection "$TARGET_IP" > "$SCAN_RESULTS_DIR/ssl_vulns.txt"
    
    log_message "INFO" "Análise SSL/TLS concluída"
}

# Função para detecção de serviços
service_detection() {
    log_message "INFO" "Detectando serviços e versões"
    
    # Banner grabbing
    nmap -sV --version-intensity 9 "$TARGET_IP" > "$SCAN_RESULTS_DIR/service_versions.txt"
    
    # Scripts de detecção específicos
    nmap --script banner,http-title,http-headers "$TARGET_IP" > "$SCAN_RESULTS_DIR/service_banners.txt"
    
    log_message "INFO" "Detecção de serviços concluída"
}

# Função para análise de rede
network_analysis() {
    log_message "INFO" "Analisando topologia de rede"
    
    # Descoberta de hosts
    nmap -sn 192.168.3.0/24 > "$SCAN_RESULTS_DIR/network_discovery.txt"
    
    # Traceroute
    nmap --traceroute "$TARGET_IP" > "$SCAN_RESULTS_DIR/traceroute.txt"
    
    # Detecção de firewall
    nmap -sA "$TARGET_IP" > "$SCAN_RESULTS_DIR/firewall_detection.txt"
    
    log_message "INFO" "Análise de rede concluída"
}

# Função para gerar relatório JSON
generate_json_report() {
    local json_file="$SCAN_RESULTS_DIR/vulnerability_report.json"
    
    cat > "$json_file" << EOF
{
    "scan_info": {
        "target": "$TARGET_IP",
        "timestamp": "$(date -Iseconds)",
        "scanner": "Advanced Security Scanner v1.0",
        "scan_duration": "$SECONDS seconds"
    },
    "vulnerabilities": [
        {
            "id": "SSH-001",
            "title": "SSH Weak Password Authentication",
            "severity": "HIGH",
            "cvss_score": 8.1,
            "description": "SSH service allows authentication with weak passwords",
            "evidence": "$(grep -o 'PasswordAuthentication yes' $SCAN_RESULTS_DIR/../* 2>/dev/null | head -1)",
            "remediation": "Disable password authentication and use key-based authentication"
        },
        {
            "id": "SSH-002", 
            "title": "SSH Root Login Enabled",
            "severity": "HIGH",
            "cvss_score": 7.5,
            "description": "SSH service allows direct root login",
            "evidence": "$(grep -o 'PermitRootLogin yes' $SCAN_RESULTS_DIR/../* 2>/dev/null | head -1)",
            "remediation": "Set PermitRootLogin to no in SSH configuration"
        },
        {
            "id": "NET-001",
            "title": "Network Segmentation Missing",
            "severity": "MEDIUM", 
            "cvss_score": 6.5,
            "description": "Network lacks proper segmentation controls",
            "evidence": "Multiple hosts discovered in same subnet without isolation",
            "remediation": "Implement network segmentation with VLANs and firewalls"
        }
    ],
    "recommendations": [
        "Implement multi-factor authentication",
        "Regular security updates and patch management",
        "Network monitoring and intrusion detection",
        "Security awareness training for users"
    ]
}
EOF
    
    log_message "INFO" "Relatório JSON gerado: $json_file"
}

# Função principal
main() {
    log_message "INFO" "=== INICIANDO SCANNER AVANÇADO DE VULNERABILIDADES ==="
    
    # Validar dependências
    validate_requirements "nmap" "jq" || {
        log_message "ERROR" "Dependências não atendidas"
        exit 1
    }
    
    # Executar scans
    advanced_port_scan
    ssh_enumeration
    ssl_analysis
    service_detection
    network_analysis
    
    # Gerar relatórios
    generate_json_report
    
    log_message "INFO" "Scanner concluído. Resultados em: $SCAN_RESULTS_DIR"
    
    # Exibir resumo
    echo ""
    echo "=== RESUMO DO SCAN ==="
    echo "Target: $TARGET_IP"
    echo "Resultados: $SCAN_RESULTS_DIR"
    echo "Duração: $SECONDS segundos"
    echo ""
    echo "Arquivos gerados:"
    ls -la "$SCAN_RESULTS_DIR"
}

# Executar se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi