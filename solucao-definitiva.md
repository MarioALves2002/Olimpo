# 🚨 SOLUÇÃO DEFINITIVA PARA PROBLEMAS SSH

## 🔍 DIAGNÓSTICO DO PROBLEMA

### Execute primeiro:
```bash
make teste-ssh
```

## 🛠️ POSSÍVEIS CAUSAS E SOLUÇÕES:

### 1. **SSH está na porta errada**
```bash
make reset  # Força SSH para porta 22
```

### 2. **Senha incorreta**
- Senha deve ser: `123456789`
- Se não funcionar, acesse o servidor e execute:
```bash
echo 'apolo:123456789' | sudo chpasswd
```

### 3. **SSH instável/bloqueado**
- Fail2Ban pode estar bloqueando após tentativas
- Solução no servidor:
```bash
sudo systemctl stop fail2ban
sudo fail2ban-client unban --all
```

### 4. **Firewall bloqueando**
- Solução no servidor:
```bash
sudo ufw --force disable
sudo iptables -F
```

### 5. **SSH não está rodando**
- Solução no servidor:
```bash
sudo systemctl start ssh
sudo systemctl enable ssh
sudo systemctl status ssh
```

## 🎯 FLUXO DE CORREÇÃO COMPLETA:

### No servidor alvo (192.168.3.216):
```bash
# 1. Parar tudo que pode bloquear
sudo systemctl stop fail2ban
sudo ufw --force disable
sudo iptables -F

# 2. Reiniciar SSH
sudo systemctl restart ssh
sudo systemctl enable ssh

# 3. Configurar usuário
echo 'apolo:123456789' | sudo chpasswd
sudo usermod -aG sudo apolo

# 4. Testar localmente
ssh apolo@localhost
```

### Na máquina atacante:
```bash
make teste-ssh    # Verificar se funciona
make ataques      # Executar ataques
```

## 🚨 SE NADA FUNCIONAR:

### Última solução - Reiniciar servidor:
```bash
sudo reboot
```

### Depois do reboot, configurar novamente:
```bash
make reset
make teste-ssh
make ataques
```