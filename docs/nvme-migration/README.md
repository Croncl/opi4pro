```markdown
[← voltar ao índice do opi4pro](../../README.md)

# 📘 Migrando o Orange Pi 4 Pro para NVMe

Roteiro definitivo para rodar o sistema operacional do Orange Pi 4 Pro em um SSD NVMe, mantendo `/boot` no cartão SD (exigência do U-Boot da Allwinner).

> Testado no Orange Pi 4 Pro (Allwinner A733) com Debian/Armbian.

---

## 🎯 Onde executar os comandos deste guia?

Para evitar confusões, **absolutamente todos** os comandos abaixo devem ser executados **diretamente no terminal da Orange Pi** (seja via teclado/monitor conectados nela, ou via SSH a partir da sua máquina de desenvolvimento):
```bash
ssh root@192.168.0.5 (ou outro)

```

---

## 🎯 Objetivo

* **Raiz (`/`)**: rodando 100% no SSD NVMe (alta performance, 200GB+)
* **Boot (`/boot`)**: permanece no cartão SD (compatibilidade com o U-Boot)
* **Durabilidade**: SD protegido contra desgaste desnecessário
* **Estabilidade**: atualizações de kernel não quebram o boot

---

## 🧩 Por que é complicado?

| Limitação | Detalhe |
| --- | --- |
| **SPI Flash de 16MB** | `/boot` tem ~80-100MB e não cabe na SPI. O SD é obrigatório para os arquivos de boot. |
| **U-Boot sem NVMe nativo** | O U-Boot da Allwinner para o A733 só procura arquivos de boot no SD/eMMC; não inicializa o PCIe antes do kernel. O SD deve permanecer na placa (lido só nos primeiros ~3s do boot). |
| **Initramfs sem drivers NVMe** | A imagem padrão não inclui `nvme`, `nvme_core`, `nvme_pci`. Sem eles o kernel não enxerga o SSD no boot. |
| **boot.cmd exige Partição 1** | O script de boot procura a Partição 1 (`:1`) do disco. NVMe "cru" (sem tabela de partição) quebra o boot. |

---

## 📋 Pré-requisitos

* Orange Pi 4 Pro rodando pelo SD card ou eMMC (com acesso root via SSH ou terminal local)
* SSD NVMe instalado na placa
* Conexão com internet ativa na Orange Pi

---

## 🔧 Uso rápido (script automatizado)

Para as partes repetitivas (drivers no initramfs + hook de proteção contra futuras atualizações de kernel), execute **na Orange Pi**:

```bash
git clone [https://github.com/SEU-USUARIO/opi4pro.git](https://github.com/SEU-USUARIO/opi4pro.git)
cd opi4pro/docs/nvme-migration
chmod +x scripts/setup-nvme-boot.sh
sudo ./scripts/setup-nvme-boot.sh

```

---

## 🛠️ Passo a passo completo (Executado na Orange Pi)

### Fase 1 — Testar o hardware (opcional, recomendado)

*(Rode direto na Orange Pi)*

```bash
sudo apt update
sudo apt install f3 fio parted

```

Testar velocidade de leitura/escrita do NVMe:

```bash
sudo fio --name=sequencial --filename=teste_velocidade --size=1G --bs=1M --rw=readwrite --direct=1 --runtime=30 --time_based=0

```

### Fase 2 — Particionar o NVMe

*(Rode direto na Orange Pi)*

```bash
cd ~
sudo umount /mnt/nvme        # se estiver montado

sudo parted /dev/nvme0n1 mklabel gpt
sudo parted /dev/nvme0n1 mkpart primary ext4 0% 100%
sudo mkfs.ext4 /dev/nvme0n1p1

```

### Fase 3 — Instalar o sistema no NVMe

*(Rode direto na Orange Pi)*

```bash
sudo nand-sata-install

```

No menu interativo da ferramenta:

1. **SPI flash boot** → Yes
2. **USB/SATA/NVMe root install** → Yes
3. **Filesystem type** → 1 (ext4)
4. **Confirmar formatação** → Yes

Após o término, reinicie:

```bash
sudo reboot

```

> *Nota: É normal o sistema ainda iniciar pelo SD neste ponto até concluirmos a configuração do initramfs.*

### Fase 4 — Drivers NVMe no initramfs

*(Rode direto na Orange Pi ou utilize o script `setup-nvme-boot.sh`)*

```bash
echo "nvme" | sudo tee -a /etc/initramfs-tools/modules
echo "nvme_core" | sudo tee -a /etc/initramfs-tools/modules
echo "nvme_pci" | sudo tee -a /etc/initramfs-tools/modules
sudo update-initramfs -u

```

### Fase 5 — Fstab do NVMe

*(Rode direto na Orange Pi)*
Descubra o UUID da partição do NVMe:

```bash
sudo blkid /dev/nvme0n1p1

```

Monte temporariamente e ajuste o `/etc/fstab` interno do NVMe se necessário.

### Fase 6 — Apontar o boot para o NVMe

*(Rode direto na Orange Pi)*

```bash
sudo nano /boot/orangepiEnv.txt

```

Adicione ao final do arquivo:

```text
rootdev=/dev/nvme0n1p1

```

### Fase 7 — Montar o SD em `/boot`

*(Rode direto na Orange Pi)*

```bash
sudo blkid /dev/mmcblk1p1
sudo mount /dev/mmcblk1p1 /mnt
sudo cp -rf /boot/* /mnt/boot/
sudo umount /mnt

```

Edite `/etc/fstab` para garantir que a partição do SD seja mapeada permanentemente em `/boot`.

### Fase 8 — Hook automático para atualizações

Garante que os drivers NVMe nunca se percam após um `apt upgrade` (automatizado via `setup-nvme-boot.sh`).

### Fase 9 — Teste final

Reinicie a placa e valide se o sistema principal está rodando no NVMe e o `/boot` no SD:

```bash
sudo reboot
df -h / && df -h /boot

```

---

## 🧯 Problemas comuns

Veja o arquivo [troubleshooting.md](https://www.google.com/search?q=troubleshooting.md) para soluções detalhadas sobre tela preta, falhas de boot após atualização e outras ocorrências.

---

## Licença

MIT — veja [LICENSE](https://www.google.com/search?q=LICENSE).

```

```
