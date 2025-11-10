# Relatório de Auditoria de Segurança
## Incidente de Acesso Não Autorizado via SSH

### 1. RESUMO EXECUTIVO

**Data do Incidente:** [Data do incidente]  
**Tipo de Incidente:** Acesso não autorizado via SSH  
**Impacto:** Alto - Comprometimento de dados pessoais e recursos institucionais  
**Status:** Investigação concluída  

### 2. ANÁLISE DE VULNERABILIDADES E VETORES DE ATAQUE

#### 2.1 Vulnerabilidades Identificadas

##### Vulnerabilidade 1: SSH com Senhas Fracas
- **Descrição:** Uso de senhas previsíveis e fracas para acesso SSH
- **CVSS Score:** 8.1 (Alto)
- **Impacto:** Permite ataques de força bruta e engenharia social
- **Evidência:** Logs mostram tentativas de login bem-sucedidas com senhas comuns

##### Vulnerabilidade 2: Ausência de Autenticação de Dois Fatores (2FA)
- **Descrição:** Sistema SSH configurado apenas com autenticação por senha
- **CVSS Score:** 7.5 (Alto)
- **Impacto:** Facilita acesso não autorizado após comprometimento de credenciais
- **Evidência:** Configuração SSH sem módulos de 2FA habilitados

##### Vulnerabilidade 3: Privilégios Excessivos de Usuário
- **Descrição:** Usuários com privilégios administrativos desnecessários
- **CVSS Score:** 6.8 (Médio)
- **Impacto:** Escalação de privilégios e acesso a recursos críticos
- **Evidência:** Análise de grupos de usuários e permissões

##### Vulnerabilidade 4: Logging Insuficiente
- **Descrição:** Logs de sistema incompletos e sem monitoramento
- **CVSS Score:** 5.9 (Médio)
- **Impacto:** Dificuldade na detecção e investigação de incidentes
- **Evidência:** Configuração de rsyslog e auditd inadequada

##### Vulnerabilidade 5: Rede Sem Segmentação
- **Descrição:** Rede plana sem isolamento entre segmentos críticos
- **CVSS Score:** 7.2 (Alto)
- **Impacto:** Movimento lateral facilitado após comprometimento inicial
- **Evidência:** Análise de topologia de rede

##### Vulnerabilidade 6: Sistema Desatualizado
- **Descrição:** Patches de segurança não aplicados regularmente
- **CVSS Score:** 6.5 (Médio)
- **Impacto:** Exploração de vulnerabilidades conhecidas
- **Evidência:** Análise de versões de software e CVEs

#### 2.2 Vetores de Ataque Utilizados

1. **Engenharia Social:** Observação de credenciais durante digitação
2. **Acesso Remoto:** Exploração de SSH mal configurado
3. **Escalação de Privilégios:** Uso de permissões excessivas
4. **Movimento Lateral:** Exploração de rede não segmentada

### 3. ANÁLISE FORENSE DIGITAL

#### 3.1 Cadeia de Custódia

**Procedimentos Implementados:**
- Isolamento imediato do sistema comprometido
- Criação de imagem forense bit-a-bit usando `dd`
- Documentação detalhada de cada etapa
- Hash MD5/SHA256 para integridade das evidências

#### 3.2 Análise de Logs

**Logs Analisados:**
- `/var/log/auth.log` - Tentativas de autenticação
- `/var/log/syslog` - Eventos do sistema
- `/var/log/secure` - Eventos de segurança SSH
- Logs de firewall e proxy

**Comandos Utilizados:**
```bash
# Análise de tentativas SSH
grep "sshd" /var/log/auth.log | grep "Failed\|Accepted"

# Identificação de IPs suspeitos
awk '/Failed password/ {print $11}' /var/log/auth.log | sort | uniq -c | sort -nr

# Timeline de eventos
grep "sshd" /var/log/auth.log | grep "$(date +%b\ %d)"
```

#### 3.3 Evidências Coletadas

1. **Logs de autenticação SSH**
2. **Histórico de comandos (.bash_history)**
3. **Arquivos modificados (timestamps)**
4. **Conexões de rede ativas**
5. **Processos em execução**

### 4. ANÁLISE DE RISCOS E IMPACTOS

#### 4.1 Impacto Institucional

**Impactos Identificados:**
- **Reputacional:** Perda de confiança na segurança institucional
- **Financeiro:** Custos de investigação e remediação
- **Operacional:** Interrupção de serviços e atividades acadêmicas
- **Legal:** Possível violação da LGPD

**Quantificação de Riscos:**
- Probabilidade: Alta (8/10)
- Impacto: Alto (9/10)
- Risco Residual: Crítico (72/100)

#### 4.2 Impacto Humano

**Consequências para o Professor:**
- Violação de privacidade pessoal
- Exposição de dados sensíveis
- Impacto psicológico e profissional
- Necessidade de suporte institucional

### 5. RECOMENDAÇÕES IMEDIATAS

1. **Alteração imediata de todas as senhas**
2. **Implementação de 2FA para SSH**
3. **Auditoria completa de acessos**
4. **Isolamento de sistemas comprometidos**
5. **Notificação às autoridades competentes**

### 6. PLANO DE REMEDIAÇÃO

#### Curto Prazo (1-2 semanas)
- Hardening de sistemas SSH
- Implementação de monitoramento
- Treinamento emergencial de usuários

#### Médio Prazo (1-3 meses)
- Segmentação de rede
- Políticas de segurança atualizadas
- Sistema de gestão de patches

#### Longo Prazo (3-12 meses)
- Programa de conscientização contínua
- Auditoria de segurança regular
- Implementação de SIEM

### 7. CONCLUSÕES

O incidente evidencia falhas críticas na postura de segurança institucional. A implementação das recomendações é essencial para prevenir futuros incidentes e garantir a proteção dos dados institucionais e pessoais.

---
**Elaborado por:** [Nome da Dupla]  
**Data:** [Data do Relatório]  
**Versão:** 1.0