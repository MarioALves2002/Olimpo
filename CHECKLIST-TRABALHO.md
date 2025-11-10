# ✅ Checklist - Trabalho Final Segurança

## 📋 PARTE TEÓRICA (1 ponto)

### Relatório de Auditoria
- [ ] **6 vulnerabilidades** identificadas com CVSS
- [ ] **Análise forense** com cadeia de custódia
- [ ] **Impactos** institucionais e humanos
- [ ] **Timeline** dos eventos

## ⚔️ PARTE PRÁTICA (3 pontos)

### Ambiente de Demonstração
- [ ] **VMs configuradas** (Ubuntu + Parrot/Kali)
- [ ] **Rede isolada** funcional
- [ ] **Scripts executáveis** com permissões

### Demonstração de Vulnerabilidades
- [ ] **SSH Brute Force** (senha fraca)
- [ ] **Configuração insegura** (PermitRootLogin yes)
- [ ] **Privilégios excessivos** (sudo sem restrição)
- [ ] **Logs insuficientes** (sem monitoramento)
- [ ] **Rede sem segmentação** (descoberta de hosts)
- [ ] **Sistema desatualizado** (patches pendentes)

### Hardening Implementado
- [ ] **SSH seguro** (porta 2222, chaves, sem root)
- [ ] **Fail2Ban** configurado e ativo
- [ ] **Firewall UFW** restritivo
- [ ] **Auditoria** em tempo real
- [ ] **Monitoramento** de logs

## 🎤 DESENVOLVIMENTO EM SALA (2 pontos)

### Preparação
- [ ] **Slides** preparados (8-10 slides)
- [ ] **Demos testadas** e funcionais
- [ ] **Roteiro** cronometrado (20 min)
- [ ] **Arguição** preparada para ambos

### Material de Apoio
- [ ] **VMs funcionais** no ambiente de apresentação
- [ ] **Backup** de evidências/logs
- [ ] **Documentação** impressa
- [ ] **Comandos** testados previamente

## 📚 DOCUMENTAÇÃO (GitHub)

### Estrutura Essencial
- [ ] **README.md** com instruções claras
- [ ] **Relatório de auditoria** completo
- [ ] **Políticas de segurança** detalhadas
- [ ] **Scripts comentados** adequadamente

### Qualidade
- [ ] **Markdown** bem formatado
- [ ] **Links** funcionais
- [ ] **Código** limpo e organizado
- [ ] **Referências** adequadas

## 🔧 VALIDAÇÃO TÉCNICA

### Funcionalidade
- [ ] **make setup** configura ambiente vulnerável
- [ ] **make attack** demonstra vulnerabilidades
- [ ] **make harden** aplica correções
- [ ] **make test** valida segurança

### Robustez
- [ ] **Demos** funcionam consistentemente
- [ ] **Hardening** mitiga ataques
- [ ] **Scripts** tratam erros
- [ ] **Logs** são gerados corretamente

## ⚠️ CRITÉRIOS CRÍTICOS

### Anti-Plágio
- [ ] **Código original** com estilo próprio
- [ ] **Comentários** personalizados
- [ ] **Implementação** própria das funcionalidades

### Conhecimento
- [ ] **Ambos** conhecem todo o projeto
- [ ] **Explicações técnicas** preparadas
- [ ] **Exemplos adicionais** prontos

## 🎯 COMANDOS ESSENCIAIS

```bash
# Configuração inicial
make deps && make setup

# Demonstração completa
make demo

# Pipeline completo
make all

# Validação final
make validate
```

## 📅 CRONOGRAMA FINAL

### 1 Semana Antes
- [ ] Todos os scripts funcionais
- [ ] Documentação completa
- [ ] Ambiente testado

### 3 Dias Antes
- [ ] Ensaio da apresentação
- [ ] Backup de segurança
- [ ] Validação final

### Dia da Apresentação
- [ ] Material testado no local
- [ ] Backup em pendrive
- [ ] Dupla preparada

---

**Status:** [ ] Em Desenvolvimento [ ] Pronto  
**Última Verificação:** [Data]  
**Responsáveis:** [Nomes da Dupla]