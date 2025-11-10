#!/bin/bash

# Sistema de Logging Profissional
# Trabalho Final - Segurança da Informação

LOG_DIR="/var/log/security-audit"
LOG_FILE="$LOG_DIR/security-audit-$(date +%Y%m%d).log"
ERROR_LOG="$LOG_DIR/errors-$(date +%Y%m%d).log"

# Criar diretório de logs se não existir
mkdir -p "$LOG_DIR"

# Função de logging com níveis
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local caller="${BASH_SOURCE[2]##*/}:${BASH_LINENO[1]}"
    
    case "$level" in
        "INFO")  echo "[$timestamp] [INFO]  [$caller] $message" | tee -a "$LOG_FILE" ;;
        "WARN")  echo "[$timestamp] [WARN]  [$caller] $message" | tee -a "$LOG_FILE" ;;
        "ERROR") echo "[$timestamp] [ERROR] [$caller] $message" | tee -a "$LOG_FILE" "$ERROR_LOG" ;;
        "DEBUG") echo "[$timestamp] [DEBUG] [$caller] $message" | tee -a "$LOG_FILE" ;;
        "AUDIT") echo "[$timestamp] [AUDIT] [$caller] $message" | tee -a "$LOG_FILE" ;;
    esac
}

# Função para capturar saída de comandos
execute_and_log() {
    local command="$1"
    local description="$2"
    
    log_message "INFO" "Executando: $description"
    log_message "DEBUG" "Comando: $command"
    
    if output=$(eval "$command" 2>&1); then
        log_message "INFO" "Sucesso: $description"
        echo "$output"
        return 0
    else
        log_message "ERROR" "Falha: $description - $output"
        return 1
    fi
}

# Função para validar pré-requisitos
validate_requirements() {
    local requirements=("$@")
    local missing=()
    
    for req in "${requirements[@]}"; do
        if ! command -v "$req" >/dev/null 2>&1; then
            missing+=("$req")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        log_message "ERROR" "Dependências não encontradas: ${missing[*]}"
        return 1
    fi
    
    log_message "INFO" "Todas as dependências validadas"
    return 0
}

# Função para backup de arquivos
backup_file() {
    local file="$1"
    local backup_dir="/var/backups/security-audit"
    
    mkdir -p "$backup_dir"
    
    if [ -f "$file" ]; then
        local backup_name="$(basename "$file").backup.$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup_dir/$backup_name"
        log_message "AUDIT" "Backup criado: $file -> $backup_dir/$backup_name"
        return 0
    else
        log_message "WARN" "Arquivo não encontrado para backup: $file"
        return 1
    fi
}