# Relatório de Auditoria de Segurança
## Incidente de Acesso Não Autorizado via SSH

### 1. RESUMO EXECUTIVO

**Data do Incidente:** 06/11/2025  
**Tipo de Incidente:** Acesso não autorizado via SSH  
**Impacto:** Alto - Comprometimento de dados pessoais e recursos institucionais  
**Status:** Investigação concluída

---

### 2. ANÁLISE DE VULNERABILIDADES E VETORES DE ATAQUE

#### 2.1 Vulnerabilidades Identificadas

##### Vulnerabilidade 1: SSH com Senhas Fracas
- **Descrição:** Uso de senhas previsíveis e fracas para acesso SSH.
- **CVSS Score:** 8.1 (Alto)
- **Impacto:** Permite ataques de força bruta e engenharia social.
- **Evidência:** O atacante obteve acesso com a senha "123456789". O script registrou "ACESSO OBTIDO".

##### Vulnerabilidade 2: Ausência de Autenticação de Dois Fatores (2FA)
- **Descrição:** Sistema SSH configurado apenas com autenticação por senha.
- **CVSS Score:** 7.5 (Alto)
- **Impacto:** Facilita acesso após comprometimento de credenciais.
- **Evidência:** Configuração SSH apresentou "PermitRootLogin yes" e "PasswordAuthentication yes".

##### Vulnerabilidade 3: Privilégios Excessivos de Usuário
- **Descrição:** Usuários com privilégios administrativos desnecessários.
- **CVSS Score:** 6.8 (Médio)
- **Impacto:** Possibilidade de escalonamento de privilégios.
- **Evidência:** O usuário "apolo" pertence aos grupos sudo, adm e lxd. O comando "sudo -l" indicou permissões administrativas.

##### Vulnerabilidade 4: Logging Insuficiente
- **Descrição:** Logs de sistema não monitorados adequadamente.
- **CVSS Score:** 5.9 (Médio)
- **Impacto:** Dificulta detecção e investigação de incidentes.
- **Evidência:** Arquivo "/var/log/auth.log" acessível para usuários do grupo adm.

##### Vulnerabilidade 5: Rede Sem Segmentação
- **Descrição:** Rede plana sem isolamento entre segmentos críticos.
- **CVSS Score:** 7.2 (Alto)
- **Impacto:** Facilita movimento lateral após o comprometimento.
- **Evidência:** Varredura detectou hosts ativos como "192.168.3.216" e "192.168.3.217".

##### Vulnerabilidade 6: Sistema Desatualizado
- **Descrição:** Sistema operacional sem patches recentes.
- **CVSS Score:** 6.5 (Médio)
- **Impacto:** Risco de exploração de CVEs conhecidas.
- **Evidência:** Kernel identificado: "Linux apolo 6.8.0-87-generic".

---

#### 2.2 Vetores de Ataque Utilizados

1. Observação de credenciais (engenharia social).  
2. Exploração de SSH mal configurado.  
3. Escalada de privilégios devido a permissões excessivas.  
4. Movimento lateral em rede não segmentada.
