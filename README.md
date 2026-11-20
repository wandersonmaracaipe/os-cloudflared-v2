# OPNsense Plugin: os-cloudflared-v2 (v2.0.0)

<p align="center">
  <img src="/os-cloudflared.png" alt="Cloudflared" width="400">
</p>

<p align="center">
  <strong>Plugin independente para integração do Cloudflare Zero Trust Tunnel (cloudflared) no OPNsense</strong><br>
  Mantido ativamente por <strong>Wanderson Maracaipe</strong> (<a href="mailto:wanderson@valuor.com.br">wanderson@valuor.com.br</a>) &bull; Distribuído por <strong>Valuor</strong>
</p>

---

## Destaques da Versão 2.0.0

- **Plugin Independente:** Registrado como `os-cloudflared-v2`, com ciclo de desenvolvimento e atualizações próprio, mantido pela Valuor.
- **Daemon Atualizado (`cloudflared 2026.11.1`):** Compilado nativamente com Go para `FreeBSD:15:amd64`.
- **Status do Túnel em Tempo Real:** Verificação ao vivo do status de conectividade com a borda da Cloudflare (`/ready`) com visualização direta na interface web.
- **Exportador de Métricas Configurável:** Opção para definir o endereço/porta das métricas Prometheus (padrão `localhost:2000`, ou desabilitar liberando a porta).
- **Logs Estruturados via Syslog-ng:** Rotação automática e suporte nativo a formato RFC 5424 e Zerolog em **Services → Cloudflare Tunnel → Log File**.
- **Distribuição Nativa no Catálogo OPNsense:** Disponível em **System → Firmware → Plugins** sob o repositório **Valuor**.
- **Substituição Segura:** Configurado com `PLUGIN_CONFLICTS=os-cloudflared` para substituir com segurança versões desatualizadas de terceiros.

---

## Instalação Rápida (1 Comando)

No console ou terminal SSH do seu OPNsense (como `root`), execute:

```sh
fetch -o - https://raw.githubusercontent.com/wandersonmaracaipe/os-cloudflared-v2/master/install.sh | sh
```

O instalador configura o repositório oficial da Valuor, atualiza o catálogo, remove versões antigas se existirem e instala o `os-cloudflared-v2` juntamente com o `cloudflared 2026.11.1`.

---

## Instalação Manual via Repositório Valuor

Se preferir configurar manualmente para que o plugin apareça no catálogo da interface web (**System → Firmware → Plugins**):

### 1. Criar o arquivo de repositório
Crie `/usr/local/etc/pkg/repos/Valuor.conf` no OPNsense:

```text
Valuor: {
  url: "https://raw.githubusercontent.com/wandersonmaracaipe/os-cloudflared-v2/master/packages",
  signature_type: "none",
  priority: 20,
  enabled: yes
}
```

### 2. Atualizar o catálogo de pacotes
```sh
pkg update -r Valuor
```

### 3. Instalar pela Interface Web ou Linha de Comando
- **Pela Interface Web:** Vá em **System → Firmware → Plugins**, procure por `os-cloudflared-v2` e clique no botão **+** para instalar.
- **Pelo Terminal:**
  ```sh
  pkg install os-cloudflared-v2
  service configd restart
  ```

---

## Como Configurar o Túnel

1. No painel [Cloudflare Zero Trust](https://one.dash.cloudflare.com/):
   - Navegue até **Networks → Tunnels**.
   - Crie um novo túnel (tipo Cloudflared) e copie o token gerado.
2. Na interface web do OPNsense:
   - Acesse **Services → Cloudflare Tunnel**.
   - Marque a opção **Enable**.
   - Cole o token no campo **Tunnel Token**.
   - *(Opcional)* Em **Advanced**, configure protocolo (QUIC ou HTTP2), pós-quântico e métricas.
   - Clique em **Apply**.
3. **Verificação:**
   - O painel exibe o status de conexão com as bordas da Cloudflare em tempo real.
   - No terminal:
     ```sh
     configctl cloudflared tunnel_status
     service cloudflared status
     cloudflared --version
     ```

---

## Compilação e Desenvolvimento

### Estrutura do Repositório
- `src/`: Modelos MVC, controladores, templates de serviço, regras de syslog e scripts auxiliares.
- `packages/`: Pacotes binários compilados (`os-cloudflared-v2`, `cloudflared` e índices `packagesite.pkg`).
- `Makefile`: Especificação de build do plugin padrão OPNsense (`plugins.mk`).
- `pkg-descr`: Descrição detalhada exibida na interface web e no catálogo PKG.
- `install.sh`: Script de automação de instalação remota.
- `Valuor.conf`: Arquivo de configuração de repositório FreeBSD PKG.

### Build Local na Árvore de Plugins do OPNsense
```sh
cd /usr/plugins/net
git clone https://github.com/wandersonmaracaipe/os-cloudflared-v2.git cloudflared-v2
cd cloudflared-v2
make package
```

### Compilação do Binário `cloudflared` para FreeBSD 15 (amd64)
Para compilar estaticamente novas versões do daemon da Cloudflare:

```sh
docker run --rm -v $(pwd):/src -w /src golang:alpine sh -c \
  "apk add --no-cache git && \
   git clone --depth 1 --branch 2026.11.1 https://github.com/cloudflare/cloudflared.git /tmp/cf && \
   cd /tmp/cf && \
   CGO_ENABLED=0 GOOS=freebsd GOARCH=amd64 go build -trimpath \
   -ldflags='-s -w -X main.Version=2026.11.1 -X main.BuildTime=$(date -u +%Y-%m-%dT%H:%M:%SZ)' \
   -o /src/cloudflared ./cmd/cloudflared"
```

---

## Licença

Distribuído sob a licença **BSD 2-Clause** (a mesma utilizada pelo ecossistema OPNsense).

## Créditos e Agradecimentos

- **Mantenedor Atual:** [Wanderson Maracaipe](https://github.com/wandersonmaracaipe) (<wanderson@valuor.com.br>) - Valuor.
- **Trabalho Inicial:** Alan Martines (<alancpmartines@hotmail.com>) e Richard Aspden.
