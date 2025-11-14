#!/bin/bash

# Reset SEGURO - Mantém conectividade de rede

echo "🔄 RESET SEGURO - Mantendo conectividade..."

# 1. SSH vulnerável (sem reiniciar se der erro)
echo "[1] Configurando SSH vulnerável..."
sudo bash -c 'cat > /etc/ssh/sshd_config << EOF
Port 22
PermitRootLogin yes
PasswordAuthentication yes
PermitEmptyPasswords no
X11Forwarding yes
UsePAM yes
EOF' 2>/dev/null || echo "Aviso: Erro na config SSH"

# Tentar reiniciar SSH com fallback
if ! sudo systemctl restart ssh 2>/dev/null; then
    echo "Aviso: SSH não reiniciado, mas config aplicada"
fi

# 2. Firewall OFF (sem forçar se der erro)
echo "[2] Desabilitando firewall..."
sudo ufw --force disable 2>/dev/null || echo "Firewall já desabilitado"

# 3. Parar serviços (sem falhar)
echo "[3] Parando serviços de segurança..."
sudo systemctl stop fail2ban 2>/dev/null || true
sudo systemctl disable fail2ban 2>/dev/null || true
sudo systemctl stop auditd 2>/dev/null || true

# 4. Limpar arquivos de segurança
echo "[4] Removendo configurações de hardening..."
sudo rm -f /etc/audit/rules.d/security-hardening.rules 2>/dev/null || true
sudo rm -f /etc/fail2ban/jail.local 2>/dev/null || true

# 5. Kernel (só se backup existir)
echo "[5] Restaurando kernel..."
if [ -f /etc/sysctl.conf.backup ]; then
    sudo cp /etc/sysctl.conf.backup /etc/sysctl.conf 2>/dev/null || true
    sudo sysctl -p 2>/dev/null || true
else
    echo "Backup do kernel não encontrado, mantendo atual"
fi

# 6. Usuário apolo (garantir que existe)
echo "[6] Configurando usuário apolo..."
sudo useradd -m -s /bin/bash apolo 2>/dev/null || echo "Usuário apolo já existe"

# Definir senha (tentar várias formas)
if echo "apolo:123456789" | sudo chpasswd 2>/dev/null; then
    echo "Senha definida com chpasswd"
elif sudo passwd apolo <<< $'123456789\n123456789' 2>/dev/null; then
    echo "Senha definida com passwd"
else
    echo "Aviso: Defina senha manualmente: sudo passwd apolo"
fi

# Adicionar ao sudo
sudo usermod -aG sudo apolo 2>/dev/null || echo "Usuário já no grupo sudo"

# 7. Verificar conectividade SSH
echo "[7] Testando conectividade SSH..."
if sudo systemctl is-active ssh >/dev/null 2>&1; then
    echo "✅ SSH ativo"
else
    echo "⚠️ SSH pode estar inativo, mas configurado"
fi

# 8. Status final
echo ""
echo "✅ RESET SEGURO CONCLUÍDO!"
echo "📋 Status:"
echo "   - SSH: Configurado para porta 22"
echo "   - Firewall: Desabilitado"
echo "   - Usuário: apolo (senha: 123456789)"
echo "   - Conectividade: Preservada"
echo ""
echo "🎯 Máquina pronta para ataques!"