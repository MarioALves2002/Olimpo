# 🛡️ ANÁLISE FORENSE EM INFRAESTRUTURA SIMULADA

**Instituição:** Instituto Federal Goiano - Campus Ceres  
**Curso:** Bacharelado em Sistemas de Informação  
**Disciplina:** Segurança da Informação  
**Orientador:** Roitier Campos  
**Autores:** Emiliano Ferreira de Souza Junior; Mário Alves Fernandes  
**Ano:** 2025

## 📋 Visão Geral

Laboratório completo de segurança simulando cenários reais de ataque e defesa cibernéticas. Penetration test educacional seguido de hardening profissional, automatizado e documentado.

## 🎯 Como Usar

### 1. Preparar Ambiente Vulnerável
```bash
make setup    # Configura sistema vulnerável
```

### 2. Executar Ataques Reais
```bash
make ataques  # Ataca apolo@192.168.3.216
```

### 3. Aplicar Hardening
```bash
make harden   # Implementa todas as correções
```

### 4. Gerar Relatórios
```bash
make report   # Relatórios em /tmp/security-reports
```

## 🔍 Vulnerabilidades Demonstradas (6 Críticas)

| ID | Vulnerabilidade | CVSS | Impacto |
|----|-----------------|------|---------|
| **SSH-001** | Autenticação com senhas fracas | 8.1 | Acesso não autorizado |
| **SSH-002** | Ausência de 2FA | 7.5 | Bypass de autenticação |
| **PRIV-001** | Privilégios excessivos | 6.8 | Escalação de privilégios |
| **LOG-001** | Logging insuficiente | 5.9 | Detecção comprometida |
| **NET-001** | Rede sem segmentação | 7.2 | Movimento lateral |
| **SYS-001** | Sistema desatualizado | 6.5 | Exploração de CVEs |

## 🛡️ Contramedidas Implementadas

- ✅ SSH configuração segura (porta 2222, chaves Ed25519)
- ✅ Google Authenticator PAM (2FA)
- ✅ Firewall UFW com regras restritivas
- ✅ Auditd + Rsyslog estruturado
- ✅ Fail2Ban proteção avançada
- ✅ Gestão automática de patches

## 📊 Métricas de Efetividade

### Antes → Depois do Hardening

| Métrica | Antes | Depois | Melhoria |
|---------|-------|--------|----------|
| Vulnerabilidades Críticas | 6 | 0 | 100% |
| Portas de Rede Abertas | 5 | 1 | 80% |
| Métodos de Autenticação | 1 (senha) | 2 (chave+2FA) | 100% |
| Tempo de Detecção | Infinito | < 1 minuto | Crítica |
| Compliance NIST Framework | 15% | 85% | 467% |

## 🎯 Arquitetura da Solução

### Scripts de Exploração (pratica/vulnerabilidades/)
- **demo-vulnerabilities.sh**: Orquestra todos os ataques
- Coleta automática de evidências
- Logging estruturado para análise forense

### Scripts de Hardening (pratica/hardening/)
- **advanced-hardening.sh**: Implementa todas as contramedidas
- Backup automático de configurações
- Rollback automático em caso de erro

### Framework de Testes (pratica/scripts/)
- **test-framework.sh**: Valida efetividade das correções
- Relatórios em HTML e JSON
- Métricas quantificáveis

### Automação Completa (Makefile)
- Pipeline executável com "make all"
- Execução modular (setup → ataques → harden → test)
- Tempo total: menos de 10 minutos

## 🏆 Diferenciais Técnicos

- ✅ **Compliance**: NIST Cybersecurity Framework 1.1, CIS Controls v8
- ✅ **Automação**: Pipeline CI/CD para segurança
- ✅ **Forense**: Coleta automática de evidências
- ✅ **Profissional**: Ferramentas padrão da indústria (nmap, hydra, fail2ban, ufw, auditd)
- ✅ **Educacional**: Metodologia hands-on

## 🔧 Requisitos do Sistema

- Ubuntu 20.04+ ou Parrot OS
- 4GB RAM, 20GB disco
- Conectividade de rede entre VMs

## 👥 Equipe

- **Emiliano Ferreira de Souza Junior** - Vulnerabilidades 4-6, Hardening
- **Mário Alves Fernandes** - Vulnerabilidades 1-3, Análise Forense

## 🔗 Repositório

- **GitHub**: [github.com/MarioALves2002/Olimpo](https://github.com/MarioALves2002/Olimpo)
- **Alternativo**: [github.com/Emiliano-Souza/Olimpo](https://github.com/Emiliano-Souza/Olimpo)

---

**Instituto Federal Goiano - Campus Ceres**  
*Bacharelado em Sistemas de Informação - 2025*