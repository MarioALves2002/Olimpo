#!/bin/bash

# Framework de Testes Automatizados
# Trabalho Final - Segurança da Informação

source "$(dirname "$0")/logger.sh"

TEST_RESULTS_DIR="/tmp/security-tests-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$TEST_RESULTS_DIR"

# Contadores de testes
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# Função para executar teste
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    log_message "INFO" "Executando teste: $test_name"
    
    if result=$(eval "$test_command" 2>&1); then
        if [[ "$result" == *"$expected_result"* ]] || [[ "$expected_result" == "SUCCESS" ]]; then
            TESTS_PASSED=$((TESTS_PASSED + 1))
            log_message "INFO" "✅ PASSOU: $test_name"
            echo "PASS: $test_name" >> "$TEST_RESULTS_DIR/results.txt"
        else
            TESTS_FAILED=$((TESTS_FAILED + 1))
            log_message "ERROR" "❌ FALHOU: $test_name - Resultado: $result"
            echo "FAIL: $test_name - $result" >> "$TEST_RESULTS_DIR/results.txt"
        fi
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        log_message "ERROR" "❌ ERRO: $test_name - $result"
        echo "ERROR: $test_name - $result" >> "$TEST_RESULTS_DIR/results.txt"
    fi
}

# Testes de vulnerabilidades
test_vulnerabilities() {
    log_message "INFO" "=== INICIANDO TESTES DE VULNERABILIDADES ==="
    
    # Teste 1: SSH com senha fraca
    run_test "SSH Brute Force" \
        "timeout 10 sshpass -p '123456' ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no professor@192.168.3.216 'echo SUCCESS'" \
        "SUCCESS"
    
    # Teste 2: Root login habilitado
    run_test "Root Login Check" \
        "ssh professor@192.168.3.216 'grep PermitRootLogin /etc/ssh/sshd_config'" \
        "yes"
    
    # Teste 3: Autenticação por senha habilitada
    run_test "Password Auth Check" \
        "ssh professor@192.168.3.216 'grep PasswordAuthentication /etc/ssh/sshd_config'" \
        "yes"
    
    # Teste 4: Firewall desabilitado
    run_test "Firewall Status" \
        "ssh professor@192.168.3.216 'sudo ufw status'" \
        "inactive"
}

# Testes pós-hardening
test_hardening() {
    log_message "INFO" "=== INICIANDO TESTES PÓS-HARDENING ==="
    
    # Teste 1: SSH na nova porta
    run_test "SSH Port Change" \
        "nmap -p 2222 192.168.3.216 | grep open" \
        "open"
    
    # Teste 2: Fail2Ban ativo
    run_test "Fail2Ban Status" \
        "ssh -p 2222 professor@192.168.3.216 'sudo systemctl is-active fail2ban'" \
        "active"
    
    # Teste 3: Firewall ativo
    run_test "UFW Status" \
        "ssh -p 2222 professor@192.168.3.216 'sudo ufw status'" \
        "active"
    
    # Teste 4: Autenticação por chave
    run_test "Key Auth Test" \
        "ssh -p 2222 -i /home/professor/.ssh/id_rsa -o PasswordAuthentication=no professor@192.168.3.216 'echo SUCCESS'" \
        "SUCCESS"
}

# Relatório final
generate_report() {
    local report_file="$TEST_RESULTS_DIR/security-test-report.html"
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Relatório de Testes de Segurança</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #2c3e50; color: white; padding: 20px; }
        .summary { background: #ecf0f1; padding: 15px; margin: 20px 0; }
        .pass { color: #27ae60; }
        .fail { color: #e74c3c; }
        .test-result { margin: 10px 0; padding: 10px; border-left: 4px solid #3498db; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Relatório de Testes de Segurança</h1>
        <p>Data: $(date)</p>
    </div>
    
    <div class="summary">
        <h2>Resumo dos Testes</h2>
        <p><strong>Total de Testes:</strong> $TESTS_TOTAL</p>
        <p><strong class="pass">Testes Aprovados:</strong> $TESTS_PASSED</p>
        <p><strong class="fail">Testes Falharam:</strong> $TESTS_FAILED</p>
        <p><strong>Taxa de Sucesso:</strong> $(( TESTS_PASSED * 100 / TESTS_TOTAL ))%</p>
    </div>
    
    <div class="results">
        <h2>Resultados Detalhados</h2>
        <pre>$(cat "$TEST_RESULTS_DIR/results.txt")</pre>
    </div>
</body>
</html>
EOF
    
    log_message "INFO" "Relatório gerado: $report_file"
    echo "Relatório HTML: $report_file"
}

# Função principal
main() {
    log_message "INFO" "Iniciando framework de testes de segurança"
    
    case "${1:-all}" in
        "vuln")
            test_vulnerabilities
            ;;
        "hardening")
            test_hardening
            ;;
        "all")
            test_vulnerabilities
            test_hardening
            ;;
        *)
            echo "Uso: $0 [vuln|hardening|all]"
            exit 1
            ;;
    esac
    
    generate_report
    
    log_message "INFO" "Testes concluídos: $TESTS_PASSED/$TESTS_TOTAL aprovados"
    
    if [ $TESTS_FAILED -gt 0 ]; then
        exit 1
    fi
}

# Executar se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi