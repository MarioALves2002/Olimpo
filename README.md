# 🛡️ Trabalho Final - Segurança da Informação

[![Security CI](https://github.com/[usuario]/trabalho-seguranca/workflows/Security%20CI/badge.svg)](https://github.com/[usuario]/trabalho-seguranca/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Disciplina:** Segurança da Informação  
**Curso:** Bacharelado em Sistemas de Informação  
**Período:** 6º período  
**Data de Entrega:** 03/11/2025

## 📋 Visão Geral

Análise completa de segurança cibernética com:
- **Demonstração prática** de 6 vulnerabilidades críticas
- **Implementação de hardening** avançado
- **Framework de testes** automatizados
- **Documentação técnica** profissional

## 🎯 Objetivos

| Componente | Peso | Status |
|------------|------|--------|
| **Parte Teórica** | 1 ponto | ✅ |
| **Parte Prática** | 3 pontos | ✅ |
| **Desenvolvimento em Sala** | 2 pontos | 📅 |

## 🚀 Execução Rápida

### Ambiente Nativo (Recomendado)
```bash
# Pipeline completo
make all

# Ou etapas individuais
make setup    # Ambiente vulnerável
make attack   # Demonstrar ataques
make harden   # Aplicar segurança
make test     # Validar correções
```

### Ambiente Docker
```bash
docker-compose up -d
docker exec -it security-attacker bash
cd /opt/tools && ./vulnerabilidades/demo-vulnerabilities.sh
```

## 🔍 Vulnerabilidades Demonstradas

| ID | Vulnerabilidade | CVSS | Status |
|----|-----------------|------|--------|
| **SSH-001** | Senhas fracas | 8.1 | ✅ |
| **SSH-002** | Ausência de 2FA | 7.5 | ✅ |
| **PRIV-001** | Privilégios excessivos | 6.8 | ✅ |
| **LOG-001** | Logging insuficiente | 5.9 | ✅ |
| **NET-001** | Rede sem segmentação | 7.2 | ✅ |
| **SYS-001** | Sistema desatualizado | 6.5 | ✅ |

## 🛡️ Contramedidas Implementadas

- ✅ SSH configuração segura (porta 2222, chaves Ed25519)
- ✅ Fail2Ban com proteção avançada
- ✅ Firewall UFW restritivo
- ✅ Kernel hardening (sysctl)
- ✅ Monitoramento em tempo real
- ✅ Auditoria completa

## 📊 Métricas de Segurança

### Antes → Após Hardening
```
🔴 Vulnerabilidades: 6 → 🟢 0
🔴 Portas Abertas: 5 → 🟢 1 (SSH seguro)
🔴 Senhas Fracas: 100% → 🟢 Chaves + 2FA
🔴 Monitoramento: 0% → 🟢 100%
```

## 📈 Demonstração ao Vivo

**Antes (Vulnerável):**
```bash
ssh professor@192.168.3.216  # Senha: 123456 ✅
```

**Depois (Seguro):**
```bash
ssh -p 2222 professor@192.168.3.216  # ❌ BLOQUEADO
```

## 📚 Documentação

- [Relatório de Auditoria](docs/relatorio-auditoria.md)
- [Políticas de Segurança](docs/politicas-seguranca.md)
- [Arquitetura de Segurança](docs/arquitetura-seguranca.md)
- [Roteiro de Apresentação](apresentacao/roteiro-apresentacao.md)

## 🔧 Requisitos

### Dependências
```bash
make deps  # Instalação automática
```

### Ambiente Mínimo
- Ubuntu 20.04+ ou Parrot OS
- 4GB RAM, 20GB disco
- Conectividade entre VMs

## 📊 Métricas

- **Scripts:** 7 otimizados
- **Documentação:** 6,200 palavras
- **Testes:** 18 casos automatizados
- **Cobertura:** 6 vulnerabilidades críticas

## 🏆 Diferenciais

- 🚀 **Automação completa** com Makefile
- 🐳 **Ambiente Docker** reproduzível
- 📊 **Métricas quantificadas**
- 🔬 **Análise forense** profissional
- 🎯 **Compliance** NIST/ISO 27001

## 👥 Equipe

| Membro | Responsabilidade |
|--------|------------------|
| **Mario Alves Fernandes Neto** | Vulnerabilidades 1-3, Análise |
| **Emiliano Ferreira de Souza Junior** | Vulnerabilidades 4-6, Hardening |

---

<div align="center">

**🎓 Trabalho Final - Segurança da Informação**  
*Bacharelado em Sistemas de Informação - 6º Período*

</div>
