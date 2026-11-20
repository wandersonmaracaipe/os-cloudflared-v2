# OPNsense Plugin: os-cloudflared-v2 (v2.0.0)

<p align="center">
  <img src="/os-cloudflared.png" alt="Cloudflared" width="400">
</p>

Plugin independente e modernizado que integra o **Cloudflare Zero Trust Tunnel (cloudflared)** ao OPNsense, permitindo expor serviços internos com máxima segurança, sem abrir portas no firewall nem depender de IP público.

> Mantido ativamente por **Wanderson Maracaipe** (<wanderson@valuor.com.br>) e distribuído pela **Valuor**. Este projeto aprimora o ecossistema com suporte à versão mais recente do daemon (**cloudflared 2026.11.1+**), status em tempo real do túnel, exportação de métricas Prometheus, rotação de logs estruturados e distribuição nativa via catálogo de plugins do OPNsense.

---

## Novidades da Versão 2.0.0
- **Novo Pacote Independente:** Registrado como `os-cloudflared-v2` com controle e ciclo de atualizações próprio.
- **Compatibilidade com `cloudflared` 2026.11.1:** Compilado nativamente com Go 1.27.4 para `FreeBSD:15:amd64`.
- **Status do Túnel em Tempo Real:** Verificação ao vivo das conexões com o edge da Cloudflare através do endpoint `/ready` e widget de status no Web GUI.
- **Endereço de Métricas Configurável:** Opção no Web GUI para definir a porta/IP do exportador de métricas Prometheus (padrão `localhost:2000`, ou vazio para liberar a porta).
- **Logs Estruturados via Syslog-ng:** Rotação automática e parsing de logs em formato RFC 5424 e Zerolog em **Services → Cloudflare Tunnel → Log File**.
- **Distribuição via Catálogo PKG do OPNsense:** Disponibilização direta em **System → Firmware → Plugins** sob o repositório **Valuor**.
- **Conflito Seguro:** Configurado com `PLUGIN_CONFLICTS=os-cloudflared` para substituir versões antigas com segurança.

---

## Como Exibir no Catálogo do OPNsense (System → Firmware → Plugins)

Para que o plugin e as atualizações do daemon apareçam diretamente no catálogo da interface gráfica do OPNsense, utilizamos um repositório `pkg` de alta prioridade.

### 1. No OPNsense (via SSH / Console):
Crie o arquivo de repositório em `/usr/local/etc/pkg/repos/Valuor.conf`:

```text
Valuor: {
  url: "file:///usr/local/share/valuor-repo/${ABI}",
  signature_type: "none",
  priority: 20,
  enabled: yes
}
```

> **Nota sobre o nome do repositório:** O identificador `Valuor` é o que aparecerá na coluna **Repository** dentro da tela de Plugins do OPNsense. A `priority: 20` garante precedência sobre o repositório padrão `OPNsense` (`priority: 11`).

### 2. Estrutura do Diretório do Repositório:
No diretório `/usr/local/share/valuor-repo/FreeBSD:15:amd64/` ficam os pacotes e o índice gerado pelo `pkg repo`:
- `os-cloudflared-1.2.pkg`
- `cloudflared-2026.11.1.pkg`
- `meta.conf`, `packagesite.pkg`, `data.pkg`

### 3. Atualizar o Catálogo:
Execute:
```sh
pkg update
```

Pronto! Ao acessar **System → Firmware → Plugins** no Web GUI do OPNsense, o plugin **`os-cloudflared` 1.2** estará listado com status de instalação e pronto para atualizações diretas pela interface.

---

## Desenvolvimento e Instalação Manual

### Pré-requisitos
```sh
opnsense-code plugins
pkg install cloudflared
```

### Instalação via Código-Fonte (Árvore de Plugins)
```sh
cd /usr/plugins/net/
git clone https://github.com/wandersonmaracaipe/os-cloudflared-v2.git cloudflared-dev
cd cloudflared-dev
make upgrade
service configd restart
```

### Gerar o Pacote do Plugin
```sh
cd /usr/plugins/net/cloudflared-dev
make package
```
O pacote `.pkg` será gerado em `work/pkg/os-cloudflared-1.2.pkg`.

---

## Compilação do `cloudflared` 2026.11.1 para FreeBSD 15 (Cross-Compilation)

Como o port oficial do FreeBSD (`net/cloudflared`) frequentemente fica defasado em relação aos lançamentos da Cloudflare, o binário pode ser compilado estaticamente para FreeBSD (`GOOS=freebsd GOARCH=amd64`) utilizando Docker:

```sh
# Obter imagem Go mais recente (Go >= 1.27.4)
docker pull golang:alpine

# Clonar cloudflared na versão desejada
git clone --depth 1 --branch 2026.11.1 https://github.com/cloudflare/cloudflared.git /tmp/build_cf
cd /tmp/build_cf

# Adicionar tags de compilação FreeBSD onde necessário:
# 1. //go:build freebsd em diagnostic/system_collector_freebsd.go
# 2. Tag freebsd em diagnostic/network/collector_unix.go
# 3. createTokenFile = createTokenFileUnix em cmd/cloudflared/tunnel/subcommand.go

# Compilar estaticamente:
docker run --rm -v /tmp/build_cf:/src -w /src golang:alpine sh -c \
  "apk add --no-cache git && \
   CGO_ENABLED=0 GOOS=freebsd GOARCH=amd64 go build -trimpath \
   -ldflags='-s -w -X main.Version=2026.11.1 -X main.BuildTime=$(date -u +%Y-%m-%dT%H:%M:%SZ)' \
   -o /src/cloudflared ./cmd/cloudflared"
```

Copie o binário gerado para o OPNsense em `/usr/local/bin/cloudflared` (`chmod 755 /usr/local/bin/cloudflared`).

---

## Como Usar o Plugin

1. No [Cloudflare Zero Trust](https://one.dash.cloudflare.com/), vá em **Networks → Tunnels**, crie um túnel e copie o token gerado.
2. No OPNsense, acesse **Services → Cloudflare Tunnel**.
3. Marque **Enable**, cole o token no campo **Tunnel Token** e clique em **Apply**.
4. Em opções avançadas, configure protocolo (QUIC/HTTP2), pós-quântico, versão de IP do edge e porta de métricas.

### Verificação do Status:
```sh
service cloudflared status
cloudflared --version
configctl cloudflared tunnel_status
tail -f /var/log/cloudflared/cloudflared_$(date +%Y%m%d).log
```

No Web GUI do OPNsense, o painel indicará **Status: Connected** com a quantidade de conexões ativas com o edge da Cloudflare.

---

## Contribuindo com o Upstream Oficial (`opnsense/plugins`)

Para submeter melhorias ao repositório oficial mundial do OPNsense:
1. Faça um Fork de [opnsense/plugins](https://github.com/opnsense/plugins) no GitHub.
2. Copie os arquivos de `src/`, `Makefile` e `pkg-descr` deste repositório para `net/cloudflared/` no fork.
3. Crie uma branch (ex: `net/cloudflared-1.2`) e abra um Pull Request apontando para a branch `master` do [opnsense/plugins](https://github.com/opnsense/plugins).

---

## Licença

BSD 2-Clause — mesma licença do OPNsense.

## Créditos

- Plugin oficial: Richard Aspden e equipe OPNsense ([opnsense/plugins](https://github.com/opnsense/plugins/tree/master/net/cloudflared))
- Adaptações, cross-compilação e catálogo Valuor: Wanderson Maracaipe
- Trabalho original: Alan Martines
