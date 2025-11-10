# Arquitetura de Segurança Empresarial
## Trabalho Final - Segurança da Informação

### 1. VISÃO GERAL DA ARQUITETURA

#### 1.1 Modelo de Segurança em Camadas (Defense in Depth)

```
┌─────────────────────────────────────────────────────────────┐
│                    CAMADA DE GOVERNANÇA                     │
│  Políticas • Procedimentos • Compliance • Auditoria       │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                   CAMADA DE APLICAÇÃO                      │
│  Autenticação • Autorização • Criptografia • Logs         │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                    CAMADA DE SISTEMA                       │
│  Hardening • Patches • Antivírus • Monitoramento          │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                     CAMADA DE REDE                        │
│  Firewall • IDS/IPS • Segmentação • VPN                   │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                    CAMADA FÍSICA                          │
│  Controle de Acesso • CCTV • Biometria • Cofres           │
└─────────────────────────────────────────────────────────────┘
```

#### 1.2 Arquitetura de Rede Segmentada

```
Internet
    │
    ▼
┌─────────────┐
│   Firewall  │ ← Perímetro de Segurança
│   Externo   │
└─────────────┘
    │
    ▼
┌─────────────┐
│     DMZ     │ ← Zona Desmilitarizada
│ Web Servers │   (Serviços Públicos)
└─────────────┘
    │
    ▼
┌─────────────┐
│   Firewall  │ ← Controle de Acesso Interno
│   Interno   │
└─────────────┘
    │
    ├─────────────────┬─────────────────┬─────────────────┐
    ▼                 ▼                 ▼                 ▼
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│  VLAN   │    │  VLAN   │    │  VLAN   │    │  VLAN   │
│ Serv.   │    │ Admin   │    │ Users   │    │ Guest   │
│ Críticos│    │         │    │         │    │         │
└─────────┘    └─────────┘    └─────────┘    └─────────┘
```

### 2. FRAMEWORK DE SEGURANÇA NIST

#### 2.1 Implementação das Funções Principais

**IDENTIFY (Identificar)**
- Inventário de ativos críticos
- Classificação de dados
- Mapeamento de riscos
- Identificação de vulnerabilidades

**PROTECT (Proteger)**
- Controles de acesso (IAM)
- Criptografia de dados
- Hardening de sistemas
- Treinamento de usuários

**DETECT (Detectar)**
- SIEM (Security Information and Event Management)
- IDS/IPS (Intrusion Detection/Prevention)
- Monitoramento contínuo
- Análise comportamental

**RESPOND (Responder)**
- Plano de resposta a incidentes
- Equipe de resposta (CSIRT)
- Comunicação de crises
- Contenção de ameaças

**RECOVER (Recuperar)**
- Planos de continuidade
- Backup e restauração
- Lições aprendidas
- Melhoria contínua

### 3. MATRIZ DE CONTROLES DE SEGURANÇA

| Controle | Categoria | Implementação | Prioridade | Status |
|----------|-----------|---------------|------------|--------|
| **Autenticação Multifator** | IAM | Google Authenticator/Authy | Alta | ✅ |
| **Criptografia em Trânsito** | Crypto | TLS 1.3, SSH Ed25519 | Alta | ✅ |
| **Criptografia em Repouso** | Crypto | AES-256, LUKS | Alta | 🔄 |
| **Segmentação de Rede** | Network | VLANs, Micro-segmentação | Alta | ✅ |
| **Monitoramento SIEM** | Monitor | ELK Stack, Splunk | Média | 🔄 |
| **Backup Automatizado** | Recovery | Veeam, rsync | Alta | ✅ |
| **Teste de Penetração** | Assessment | Quarterly pentest | Média | 📅 |
| **Treinamento Usuários** | Awareness | Phishing simulation | Média | 📅 |

### 4. ARQUITETURA DE MONITORAMENTO

#### 4.1 Stack de Monitoramento (ELK)

```
┌─────────────────────────────────────────────────────────────┐
│                        KIBANA                               │
│              (Dashboards e Visualização)                   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     ELASTICSEARCH                          │
│              (Armazenamento e Busca)                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      LOGSTASH                              │
│              (Processamento de Logs)                       │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Firewall  │    │   Servers   │    │  Network    │
│    Logs     │    │    Logs     │    │   Devices   │
└─────────────┘    └─────────────┘    └─────────────┘
```

#### 4.2 Métricas de Segurança (KPIs)

**Indicadores de Detecção:**
- MTTD (Mean Time to Detection): < 4 horas
- Taxa de falsos positivos: < 5%
- Cobertura de logs: > 95%

**Indicadores de Resposta:**
- MTTR (Mean Time to Response): < 1 hora
- MTTR (Mean Time to Recovery): < 4 horas
- Taxa de contenção: > 90%

**Indicadores de Prevenção:**
- Vulnerabilidades críticas: 0
- Patches aplicados: > 95% em 30 dias
- Treinamentos concluídos: > 90%

### 5. PLANO DE RESPOSTA A INCIDENTES

#### 5.1 Classificação de Incidentes

| Nível | Descrição | Tempo Resposta | Escalação |
|-------|-----------|----------------|-----------|
| **P1 - Crítico** | Comprometimento de dados críticos | 15 minutos | CISO + CEO |
| **P2 - Alto** | Acesso não autorizado a sistemas | 1 hora | CISO + TI |
| **P3 - Médio** | Tentativas de ataque detectadas | 4 horas | Equipe Segurança |
| **P4 - Baixo** | Violações menores de política | 24 horas | Supervisor TI |

#### 5.2 Fluxo de Resposta

```
Detecção → Análise → Classificação → Contenção → Erradicação → Recuperação → Lições
    │         │          │             │            │             │           │
    ▼         ▼          ▼             ▼            ▼             ▼           ▼
  SIEM    Analista   Matriz de    Isolamento   Remoção da   Restauração  Relatório
         Segurança  Severidade      de         Ameaça       de Serviços   Final
                                  Sistemas
```

### 6. ARQUITETURA DE BACKUP E RECUPERAÇÃO

#### 6.1 Estratégia 3-2-1

```
┌─────────────────────────────────────────────────────────────┐
│                    DADOS ORIGINAIS                         │
│                  (Produção Ativa)                          │
└─────────────────────────────────────────────────────────────┘
                              │
                    ┌─────────┼─────────┐
                    ▼         ▼         ▼
            ┌─────────┐ ┌─────────┐ ┌─────────┐
            │ Backup  │ │ Backup  │ │ Backup  │
            │ Local   │ │ Remoto  │ │  Cloud  │
            │ (Disk)  │ │ (Tape)  │ │ (AWS)   │
            └─────────┘ └─────────┘ └─────────┘
```

**Regra 3-2-1:**
- **3** cópias dos dados
- **2** mídias diferentes
- **1** cópia offsite

#### 6.2 RPO/RTO Targets

| Sistema | RPO | RTO | Estratégia |
|---------|-----|-----|------------|
| **Sistemas Críticos** | 1 hora | 2 horas | Replicação síncrona |
| **Sistemas Importantes** | 4 horas | 8 horas | Backup incremental |
| **Sistemas Normais** | 24 horas | 24 horas | Backup diário |

### 7. COMPLIANCE E AUDITORIA

#### 7.1 Frameworks de Compliance

**ISO 27001:**
- Controles de segurança implementados
- Auditoria interna semestral
- Revisão de riscos trimestral

**LGPD (Lei Geral de Proteção de Dados):**
- Mapeamento de dados pessoais
- Consentimento documentado
- Relatório de impacto (RIPD)

**NIST Cybersecurity Framework:**
- Implementação das 5 funções
- Maturidade dos controles
- Métricas de efetividade

#### 7.2 Cronograma de Auditoria

| Atividade | Frequência | Responsável | Próxima Data |
|-----------|------------|-------------|--------------|
| **Auditoria Interna** | Semestral | Equipe Interna | Jun/2025 |
| **Pentest Externo** | Anual | Empresa Terceira | Mar/2025 |
| **Revisão de Acessos** | Trimestral | RH + TI | Fev/2025 |
| **Teste de Backup** | Mensal | Equipe TI | Jan/2025 |

### 8. ROADMAP DE SEGURANÇA

#### 8.1 Curto Prazo (0-6 meses)

- ✅ Implementação de hardening básico
- ✅ Configuração de monitoramento
- 🔄 Deploy de SIEM
- 📅 Treinamento de usuários

#### 8.2 Médio Prazo (6-12 meses)

- 📅 Implementação de Zero Trust
- 📅 Automação de resposta a incidentes
- 📅 Certificação ISO 27001
- 📅 Programa de Bug Bounty

#### 8.3 Longo Prazo (12+ meses)

- 📅 IA para detecção de ameaças
- 📅 Arquitetura cloud-native
- 📅 Compliance SOC 2
- 📅 Centro de operações 24/7

### 9. INVESTIMENTO E ROI

#### 9.1 Orçamento de Segurança

| Categoria | Investimento Anual | % do Orçamento TI |
|-----------|-------------------|-------------------|
| **Ferramentas** | R$ 150.000 | 25% |
| **Pessoal** | R$ 300.000 | 50% |
| **Treinamento** | R$ 50.000 | 8% |
| **Consultoria** | R$ 100.000 | 17% |
| **TOTAL** | R$ 600.000 | 100% |

#### 9.2 Retorno do Investimento

**Custos Evitados:**
- Multas LGPD: R$ 2.000.000
- Downtime: R$ 500.000/dia
- Perda de reputação: R$ 1.000.000
- Recuperação de dados: R$ 200.000

**ROI Estimado:** 400% ao ano

---
**Elaborado por:** Equipe de Arquitetura de Segurança  
**Data:** Novembro 2024  
**Versão:** 2.0  
**Próxima Revisão:** Maio 2025