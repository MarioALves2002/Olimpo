# Roteiro de Apresentação
## Trabalho Final - Segurança da Informação

### ESTRUTURA DA APRESENTAÇÃO (20 minutos)

#### 1. INTRODUÇÃO (2 minutos)
- **Apresentação da dupla**
- **Contexto do incidente**
- **Objetivos do trabalho**
- **Metodologia utilizada**

#### 2. ANÁLISE TEÓRICA (6 minutos)

##### 2.1 Vulnerabilidades Identificadas (3 minutos)
**Slide 1: Mapa de Vulnerabilidades**
- SSH com senhas fracas (CVSS 8.1)
- Ausência de 2FA (CVSS 7.5)
- Privilégios excessivos (CVSS 6.8)
- Logging insuficiente (CVSS 5.9)
- Rede sem segmentação (CVSS 7.2)
- Sistema desatualizado (CVSS 6.5)

**Slide 2: Vetores de Ataque**
- Engenharia social → Observação de credenciais
- Acesso remoto → SSH mal configurado
- Escalação → Privilégios excessivos
- Movimento lateral → Rede plana

##### 2.2 Análise Forense (3 minutos)
**Slide 3: Evidências Coletadas**
- Logs de autenticação SSH
- Histórico de comandos
- Arquivos modificados
- Conexões de rede
- Timeline do incidente

**Slide 4: Impactos Identificados**
- Institucional: Reputação, custos, operacional
- Humano: Privacidade, exposição, psicológico
- Legal: LGPD, responsabilidades

#### 3. DEMONSTRAÇÃO PRÁTICA (10 minutos)

##### 3.1 Ambiente de Teste (1 minuto)
- **Apresentar topologia**
  - VM Atacante (Kali Linux)
  - VM Vítima (Ubuntu Server)
  - Rede isolada

##### 3.2 Exploração de Vulnerabilidades (4 minutos)
**Demo 1: Ataque de Força Bruta SSH**
```bash
# Mostrar tentativas com senhas comuns
hydra -l professor -P passwords.txt ssh://192.168.1.100
```

**Demo 2: Acesso Não Autorizado**
```bash
# Demonstrar acesso com credenciais fracas
ssh professor@192.168.1.100
# Mostrar privilégios obtidos
sudo -l
```

**Demo 3: Coleta de Informações**
```bash
# Enumerar sistema
uname -a
cat /etc/passwd
ps aux
```

##### 3.3 Aplicação de Hardening (5 minutos)
**Demo 4: Configuração Segura SSH**
```bash
# Executar script de hardening
./apply-hardening.sh
# Mostrar configuração segura
cat /etc/ssh/sshd_config
```

**Demo 5: Teste de Segurança**
```bash
# Tentar ataque após hardening
ssh -p 2222 professor@192.168.1.100
# Mostrar fail2ban em ação
fail2ban-client status sshd
```

#### 4. SOLUÇÕES PROPOSTAS (2 minutos)

##### 4.1 Contramedidas Técnicas
- Configuração segura SSH (porta, 2FA, chaves)
- Fail2Ban para proteção contra força bruta
- Firewall com regras restritivas
- Monitoramento e auditoria
- Segmentação de rede
- Gestão de patches

##### 4.2 Políticas e Procedimentos
- Política de senhas robusta
- Treinamento de conscientização
- Procedimentos de resposta a incidentes
- Auditoria regular de segurança

### PREPARAÇÃO PARA ARGUIÇÃO

#### Perguntas Esperadas - Membro 1:
1. **"Explique como funciona o ataque de força bruta SSH"**
   - Resposta: Tentativas automatizadas de login com listas de senhas comuns
   - Demonstrar com hydra ou medusa
   - Explicar logs gerados

2. **"Por que a autenticação por chave é mais segura?"**
   - Resposta: Criptografia assimétrica, sem transmissão de senha
   - Mostrar geração de chaves
   - Explicar processo de autenticação

3. **"Como o Fail2Ban protege contra ataques?"**
   - Resposta: Monitoramento de logs, detecção de padrões, bloqueio automático
   - Mostrar configuração
   - Demonstrar funcionamento

#### Perguntas Esperadas - Membro 2:
1. **"Quais evidências forenses foram coletadas?"**
   - Resposta: Logs de auth, bash_history, timestamps, conexões
   - Explicar cadeia de custódia
   - Mostrar comandos de análise

2. **"Como implementar segmentação de rede?"**
   - Resposta: VLANs, firewalls, DMZ, princípio do menor privilégio
   - Desenhar topologia segura
   - Explicar benefícios

3. **"Qual o impacto da LGPD neste incidente?"**
   - Resposta: Violação de dados pessoais, obrigação de notificação
   - Explicar penalidades
   - Procedimentos de conformidade

### MATERIAL DE APOIO

#### Slides Essenciais:
1. Título e apresentação da dupla
2. Contexto do incidente
3. Mapa de vulnerabilidades
4. Topologia do ambiente de teste
5. Demonstração de ataques
6. Soluções implementadas
7. Políticas propostas
8. Conclusões e recomendações

#### Equipamentos Necessários:
- Laptop com VMs configuradas
- Projetor/TV para apresentação
- Cabo HDMI/adaptador
- Backup em pendrive
- Documentação impressa

#### Cronometragem:
- **0-2 min:** Introdução
- **2-8 min:** Análise teórica
- **8-18 min:** Demonstração prática
- **18-20 min:** Conclusões
- **20-30 min:** Arguição

### DICAS PARA APRESENTAÇÃO

1. **Preparação:**
   - Testar todas as demos previamente
   - Ter backup de evidências/logs
   - Conhecer profundamente cada vulnerabilidade
   - Praticar transições entre tópicos

2. **Durante a apresentação:**
   - Manter contato visual com a audiência
   - Explicar cada comando executado
   - Mostrar resultados claramente
   - Gerenciar o tempo rigorosamente

3. **Na arguição:**
   - Responder com confiança
   - Usar exemplos práticos
   - Admitir quando não souber algo
   - Complementar resposta do colega

### CRITÉRIOS DE AVALIAÇÃO

- **Conhecimento técnico:** Domínio das vulnerabilidades e soluções
- **Demonstração prática:** Funcionamento correto das demos
- **Documentação:** Qualidade do material produzido
- **Apresentação:** Clareza e organização
- **Arguição:** Capacidade de responder questões técnicas