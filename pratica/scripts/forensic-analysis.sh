#!/bin/bash

# Script de Análise Forense
# Trabalho Final - Segurança da Informação

EVIDENCE_DIR="/tmp/evidence_$(date +%Y%m%d_%H%M%S)"
REPORT_FILE="$EVIDENCE_DIR/forensic_report.txt"

echo "=== ANÁLISE FORENSE DO INCIDENTE SSH ==="
echo "Iniciando coleta de evidências..."

# Criar diretório de evidências
mkdir -p "$EVIDENCE_DIR"

# Função para log com timestamp
log_evidence() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$REPORT_FILE"
}

log_evidence "=== INÍCIO DA ANÁLISE FORENSE ==="
log_evidence "Diretório de evidências: $EVIDENCE_DIR"

# 1. Informações do sistema
log_evidence ""
log_evidence "[1] INFORMAÇÕES DO SISTEMA"
log_evidence "=========================="
uname -a | tee -a "$REPORT_FILE"
cat /etc/os-release | tee -a "$REPORT_FILE"
uptime | tee -a "$REPORT_FILE"

# 2. Análise de logs SSH
log_evidence ""
log_evidence "[2] ANÁLISE DE LOGS SSH"
log_evidence "======================"

# Tentativas de login falharam
log_evidence "Tentativas de login falharam:"
grep "Failed password" /var/log/auth.log | tail -20 | tee -a "$REPORT_FILE"

# Logins bem-sucedidos
log_evidence ""
log_evidence "Logins bem-sucedidos:"
grep "Accepted password" /var/log/auth.log | tail -10 | tee -a "$REPORT_FILE"

# IPs mais frequentes em tentativas de login
log_evidence ""
log_evidence "IPs com mais tentativas de login:"
awk '/Failed password/ {print $11}' /var/log/auth.log | sort | uniq -c | sort -nr | head -10 | tee -a "$REPORT_FILE"

# 3. Análise de usuários
log_evidence ""
log_evidence "[3] ANÁLISE DE USUÁRIOS"
log_evidence "======================"

# Usuários com login recente
log_evidence "Últimos logins:"
last | head -10 | tee -a "$REPORT_FILE"

# Usuários com privilégios sudo
log_evidence ""
log_evidence "Usuários com privilégios sudo:"
grep -E '^sudo:' /etc/group | tee -a "$REPORT_FILE"

# 4. Análise de processos
log_evidence ""
log_evidence "[4] PROCESSOS ATIVOS"
log_evidence "==================="
ps aux --sort=-%cpu | head -15 | tee -a "$REPORT_FILE"

# 5. Conexões de rede
log_evidence ""
log_evidence "[5] CONEXÕES DE REDE"
log_evidence "==================="
netstat -tuln | tee -a "$REPORT_FILE"

log_evidence ""
log_evidence "Conexões estabelecidas:"
netstat -tun | grep ESTABLISHED | tee -a "$REPORT_FILE"

# 6. Análise de arquivos modificados recentemente
log_evidence ""
log_evidence "[6] ARQUIVOS MODIFICADOS (ÚLTIMAS 24H)"
log_evidence "====================================="
find /home -type f -mtime -1 -ls 2>/dev/null | tee -a "$REPORT_FILE"

# 7. Histórico de comandos
log_evidence ""
log_evidence "[7] HISTÓRICO DE COMANDOS"
log_evidence "========================"
for user_home in /home/*; do
    if [ -f "$user_home/.bash_history" ]; then
        username=$(basename "$user_home")
        log_evidence "Histórico do usuário $username:"
        tail -20 "$user_home/.bash_history" | tee -a "$REPORT_FILE"
        log_evidence ""
    fi
done

# 8. Configuração SSH atual
log_evidence ""
log_evidence "[8] CONFIGURAÇÃO SSH"
log_evidence "==================="
log_evidence "Configurações críticas do SSH:"
grep -E "(PermitRootLogin|PasswordAuthentication|Port|PermitEmptyPasswords)" /etc/ssh/sshd_config | tee -a "$REPORT_FILE"

# 9. Análise de integridade
log_evidence ""
log_evidence "[9] VERIFICAÇÃO DE INTEGRIDADE"
log_evidence "============================="

# Verificar se AIDE está instalado
if command -v aide >/dev/null 2>&1; then
    log_evidence "Executando verificação AIDE..."
    aide --check | tee -a "$REPORT_FILE"
else
    log_evidence "AIDE não instalado - verificação manual de arquivos críticos"
    
    # Verificar arquivos críticos manualmente
    critical_files=("/etc/passwd" "/etc/shadow" "/etc/ssh/sshd_config" "/etc/sudoers")
    for file in "${critical_files[@]}"; do
        if [ -f "$file" ]; then
            log_evidence "Hash de $file: $(md5sum $file)"
        fi
    done
fi

# 10. Coleta de evidências adicionais
log_evidence ""
log_evidence "[10] EVIDÊNCIAS ADICIONAIS"
log_evidence "========================="

# Copiar logs importantes
cp /var/log/auth.log "$EVIDENCE_DIR/" 2>/dev/null
cp /var/log/syslog "$EVIDENCE_DIR/" 2>/dev/null
cp /var/log/secure "$EVIDENCE_DIR/" 2>/dev/null

# Copiar configurações importantes
cp /etc/ssh/sshd_config "$EVIDENCE_DIR/" 2>/dev/null
cp /etc/passwd "$EVIDENCE_DIR/" 2>/dev/null

# Gerar hash das evidências
log_evidence ""
log_evidence "Hashes das evidências coletadas:"
find "$EVIDENCE_DIR" -type f -exec md5sum {} \; | tee -a "$REPORT_FILE"

# Timeline dos eventos
log_evidence ""
log_evidence "[11] TIMELINE DOS EVENTOS"
log_evidence "========================"

# Criar timeline baseado nos logs
grep -h "$(date +%b\ %d)" /var/log/auth.log | grep -E "(ssh|sudo)" | sort | tee -a "$REPORT_FILE"

log_evidence ""
log_evidence "=== FIM DA ANÁLISE FORENSE ==="
log_evidence "Evidências coletadas em: $EVIDENCE_DIR"
log_evidence "Relatório salvo em: $REPORT_FILE"

# Criar arquivo de resumo
cat > "$EVIDENCE_DIR/summary.txt" << EOF
RESUMO DA ANÁLISE FORENSE
========================

Data/Hora: $(date)
Sistema: $(uname -a)
Analista: $(whoami)

EVIDÊNCIAS COLETADAS:
- Logs de autenticação SSH
- Histórico de comandos dos usuários
- Lista de processos ativos
- Conexões de rede
- Configurações do sistema
- Arquivos modificados recentemente

PRINCIPAIS ACHADOS:
- Tentativas de força bruta detectadas
- Logins bem-sucedidos com credenciais fracas
- Configuração SSH insegura
- Ausência de monitoramento adequado

RECOMENDAÇÕES:
- Implementar hardening SSH
- Configurar monitoramento em tempo real
- Aplicar políticas de senha robustas
- Implementar autenticação de dois fatores

EOF

echo ""
echo "Análise forense concluída!"
echo "Verifique os arquivos em: $EVIDENCE_DIR"
echo ""
echo "Arquivos gerados:"
ls -la "$EVIDENCE_DIR"