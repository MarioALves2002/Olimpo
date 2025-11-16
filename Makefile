# Makefile - Trabalho Final Segurança da Informação

.PHONY: help setup ataques harden test report clean all

# Cores
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m

help: ## Exibir comandos disponíveis
	@echo "$(BLUE)🛡️  Trabalho Final - Segurança da Informação$(NC)"
	@echo "================================================"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-12s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: ## Configurar ambiente vulnerável
	@chmod +x pratica/scripts/setup-environment.sh
	@sudo ./pratica/scripts/setup-environment.sh

test: ## Executar testes automatizados
	@chmod +x pratica/scripts/test-framework.sh
	@./pratica/scripts/test-framework.sh all

ataques: ## Executar ataques reais contra apolo@192.168.3.216
	@chmod +x pratica/vulnerabilidades/demo-vulnerabilities.sh
	@./pratica/vulnerabilidades/demo-vulnerabilities.sh
	@echo "$(RED)⚔️  Ataques reais executados!$(NC)"

harden: ## Aplicar hardening de segurança
	@chmod +x pratica/hardening/advanced-hardening.sh
	@sudo ./pratica/hardening/advanced-hardening.sh

scan: ## Scanner de vulnerabilidades
	@chmod +x pratica/scripts/advanced-scanner.sh
	@./pratica/scripts/advanced-scanner.sh

forensic: ## Análise forense
	@chmod +x pratica/scripts/forensic-analysis.sh
	@sudo ./pratica/scripts/forensic-analysis.sh

report: ## Gerar relatórios
	@mkdir -p /tmp/security-reports
	@cp -r /var/log/security-audit /tmp/security-reports/ 2>/dev/null || true
	@echo "$(GREEN)📊 Relatórios em /tmp/security-reports$(NC)"

validate: ## Validar configurações
	@ssh apolo@192.168.3.216 "grep -E '(Port|PermitRootLogin)' /etc/ssh/sshd_config" 2>/dev/null || true
	@ssh apolo@192.168.3.216 "sudo ufw status" 2>/dev/null || true

clean: ## Limpar arquivos temporários
	@rm -rf /tmp/security-* /tmp/vulnerability-* /tmp/evidence_* 2>/dev/null || true

deps: ## Instalar dependências
	@sudo apt update -qq
	@sudo apt install -y nmap hydra sshpass fail2ban ufw rsyslog auditd jq

demo: setup ataques harden validate ## Demo completa
	@echo "$(GREEN)🎉 Demonstração concluída!$(NC)"

all: deps setup ataques harden test report ## Pipeline completo
	@echo "$(GREEN)🎉 Pipeline executado com sucesso!$(NC)"