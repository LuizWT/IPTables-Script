# Dynamic Iptables Firewall Script

Script Bash para configuração de um firewall *iptables* dinâmico e seguro, com autodetecção de interface de rede e controles de tráfego.

## Visão Geral

O script aplica as seguintes práticas e regras de segurança:

- **Autodetecção de Interface e Rede:** identifica automaticamente a interface padrão e o bloco de rede local.
- **Políticas Seguras:** políticas padrão `DROP` em INPUT, OUTPUT e FORWARD.
- **Flush Inicial:** remove todas as regras e chains pré-existentes (`iptables -F`, `iptables -X`).
- **Chain personalizada `LOGDROP`:** com rate‑limit para logs e descarte controlado de pacotes.
- **Descarta Pacotes Inválidos:** usa conntrack para rejeitar estados `INVALID`.
- **Loopback Liberado:** permite tráfego interno (`lo`).
- **ICMP (Ping) da LAN:** apenas echo-request da rede local.
- **HTTP (porta 80):** libera conexões de entrada na porta 80.
- **SSH (porta 22):** logs rate‑limit de tentativas e acesso somente da LAN.
- **DNS (porta 53):** saída para UDP e TCP.
- **DHCP e NTP:** saída para UDP nas portas 68 e 123.
- **Conexões Estabelecidas:** permite tráfego de retorno (`ESTABLISHED,RELATED`).

## Requisitos

- Bash (versão 4+)
- iptables
- Módulo `conntrack` (wireguard/netfilter)
- Privilegios de superusuário (root)

## Instalação

1. Clone este repositório:
   ```bash
   git clone https://github.com/seu-usuario/IPTables-Script.git
   cd IPTables-Script
   ```
2. Torne o script executável:
   ```bash
   chmod +x firewall.sh
   ```

## Uso

Execute o script como root:

```bash
sudo ./firewall.sh
```

Você verá o terminal sendo limpo e as regras aplicadas em sequência.

### Persistência no Boot

> [!IMPORTANT]  
> Para manter as regras após reinicialização, escolha uma das opções:

1. **iptables-persistent (Debian/Ubuntu):**
   ```bash
   sudo apt install iptables-persistent
   sudo netfilter-persistent save
   ```
2. **Serviço systemd personalizado:**
   - Crie um arquivo `/etc/systemd/system/iptables-restore.service`:
     ```ini
     [Unit]
     Description=Restore iptables rules
     Before=network-pre.target

     [Service]
     Type=oneshot
     ExecStart=/sbin/iptables-restore < /etc/iptables/rules.v4

     [Install]
     WantedBy=multi-user.target
     ```
   - Salve regras atuais:
     ```bash
     iptables-save | sudo tee /etc/iptables/rules.v4
     ```
   - Ative o serviço:
     ```bash
     sudo systemctl enable iptables-restore
     ```
<hr>

## Suporte IPv6

O script cobre apenas IPv4. Ainda será implementado o suporte para as regras usando `ip6tables`.

## Apoio ao Projeto

Se você quiser contribuir com o projeto, sinta-se à vontade para abrir Issues ou fazer Pull Requests.

<hr>

## Licença

Este projeto está licenciado sob a GNU Affero General Public License v3.0 (Modificada)

---

