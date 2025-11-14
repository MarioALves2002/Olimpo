# Makefile - Trabalho Final Segurança da Informação

.PHONY: help setup attack harden test report clean all

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

check: ## Verificar ambiente antes da demonstração
	@chmod +x check-environment.sh
	@./check-environment.sh

fix-ssh: ## Corrigir SSH de emergência (porta 2222 -> 22)
	@chmod +x fix-ssh-emergency.sh
	@./fix-ssh-emergency.sh

diagnostico: ## Diagnóstico completo do problema SSH
	@chmod +x diagnostico.sh
	@./diagnostico.sh

setup: ## Configurar ambiente vulnerável
	@chmod +x pratica/scripts/setup-environment.sh
	@sudo ./pratica/scripts/setup-environment.sh

reset: ## Resetar máquina alvo para estado vulnerável
	@chmod +x pratica/scripts/reset-target.sh
	@./pratica/scripts/reset-target.sh

test: ## Executar testes automatizados
	@chmod +x pratica/scripts/test-framework.sh
	@./pratica/scripts/test-framework.sh all

attack: ## Demonstrar vulnerabilidades
	@chmod +x pratica/vulnerabilidades/demo-vulnerabilities.sh
	@./pratica/vulnerabilidades/demo-vulnerabilities.sh

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

ataques: ## Executar ataques na vítima
	@chmod +x pratica/vulnerabilidades/demo-vulnerabilities.sh
	@./pratica/vulnerabilidades/demo-vulnerabilities.sh
	@echo "$(RED)⚔️  Ataques executados na vítima 192.168.3.216$(NC)"

correcao: ## Aplicar correções de segurança
	@chmod +x pratica/hardening/advanced-hardening.sh
	@sudo ./pratica/hardening/advanced-hardening.sh
	@echo "$(GREEN)🛡️  Correções aplicadas$(NC)"

relatorio: ## Gerar relatório final
	@mkdir -p /tmp/security-reports
	@cp -r /var/log/security-audit /tmp/security-reports/ 2>/dev/null || true
	@echo "$(BLUE)📊 Relatório final gerado em /tmp/security-reports$(NC)"

validate: ## Validar configurações
	@ssh apolo@192.168.3.216 "grep -E '(Port|PermitRootLogin)' /etc/ssh/sshd_config" 2>/dev/null || true
	@ssh apolo@192.168.3.216 "sudo ufw status" 2>/dev/null || true

clean: ## Limpar arquivos temporários
	@rm -rf /tmp/security-* /tmp/vulnerability-* /tmp/evidence_* 2>/dev/null || true

deps: ## Instalar dependências
	@echo "Instalando dependências essenciais..."
	@which nmap >/dev/null 2>&1 || echo "nmap já disponível"
	@which sshpass >/dev/null 2>&1 || echo "sshpass já disponível"
	@which ufw >/dev/null 2>&1 || echo "ufw já disponível"
	@echo "✅ Dependências verificadas"

demo: setup ataques correcao relatorio ## Demo completa para apresentação
	@echo "$(GREEN)🎉 Demonstração completa concluída!$(NC)"

all: setup ataques correcao test relatorio ## Pipeline completo
	@echo "$(GREEN)🎉 Pipeline executado com sucesso!$(NC)"