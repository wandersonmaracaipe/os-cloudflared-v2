#!/bin/sh
set -e

echo "=========================================================="
echo "  Instalador os-cloudflared-v2 (v2.0.0) para OPNsense     "
echo "  Mantido por Wanderson Maracaipe <wanderson@valuor.com.br>"
echo "  Repositório: Valuor PKG Catalog                         "
echo "=========================================================="
echo

# 1. Configurar repositório Valuor PKG
echo "[1/4] Configurando repositório Valuor em /usr/local/etc/pkg/repos/Valuor.conf..."
mkdir -p /usr/local/etc/pkg/repos
cat << 'EOF' > /usr/local/etc/pkg/repos/Valuor.conf
Valuor: {
  url: "https://raw.githubusercontent.com/wandersonmaracaipe/os-cloudflared-v2/master/packages",
  signature_type: "none",
  priority: 20,
  enabled: yes
}
EOF

# 2. Atualizar o índice de pacotes do repositório Valuor
echo "[2/4] Atualizando índice de pacotes do repositório Valuor..."
env ASSUME_ALWAYS_YES=yes pkg update -r Valuor

# 3. Remover versão antiga se existir
if pkg info os-cloudflared >/dev/null 2>&1; then
    echo "[!] Removendo versão antiga (os-cloudflared)..."
    env ASSUME_ALWAYS_YES=yes pkg delete -y os-cloudflared || true
fi

# 4. Instalar o plugin os-cloudflared-v2 e dependências
echo "[3/4] Instalando os-cloudflared-v2..."
env ASSUME_ALWAYS_YES=yes pkg install -y os-cloudflared-v2

# 5. Reiniciar configd para carregar os novos templates e scripts
echo "[4/4] Atualizando serviços e recarregando templates..."
service configd restart

echo
echo "=========================================================="
echo "  Sucesso! os-cloudflared-v2 foi instalado com sucesso."
echo "  - Daemon: $(cloudflared --version 2>/dev/null || echo 'cloudflared')"
echo "  - Plugin: os-cloudflared-v2 (v2.0.0)"
echo "  - Catálogo: Visível em System -> Firmware -> Plugins"
echo "  - Configuração: Services -> Cloudflare Tunnel"
echo "=========================================================="
