[← voltar ao índice do opi4pro](../../README.md)

# 📘 Migrando o Orange Pi 4 Pro para NVMe

Roteiro definitivo para rodar o sistema operacional do Orange Pi 4 Pro em um SSD NVMe, mantendo `/boot` no cartão SD (exigência do U-Boot da Allwinner).

> Testado no Orange Pi 4 Pro (Allwinner A733) com Debian/Armbian.

---

## 🎯 Objetivo

- **Raiz (`/`)**: rodando 100% no SSD NVMe (alta performance, 200GB+)
- **Boot (`/boot`)**: permanece no cartão SD (compatibilidade com o U-Boot)
- **Durabilidade**: SD protegido contra desgaste desnecessário
- **Estabilidade**: atualizações de kernel não quebram o boot

---

## 🧩 Por que é complicado?

| Limitação | Detalhe |
|---|---|
| **SPI Flash de 16MB** | `/boot` tem ~80-100MB e não cabe na SPI. O SD é obrigatório para os arquivos de boot. |
| **U-Boot sem NVMe nativo** | O U-Boot da Allwinner para o A733 só procura arquivos de boot no SD/eMMC; não inicializa o PCIe antes do kernel. O SD deve permanecer na placa (lido só nos primeiros ~3s do boot). |
| **Initramfs sem drivers NVMe** | A imagem padrão não inclui `nvme`, `nvme_core`, `nvme_pci`. Sem eles o kernel não enxerga o SSD no boot. |
| **boot.cmd exige Partição 1** | O script de boot procura a Partição 1 (`:1`) do disco. NVMe "cru" (sem tabela de partição) quebra o boot. |

---

## 📋 Pré-requisitos

- Orange Pi 4 Pro rodando pelo SD card ou eMMC
- SSD NVMe instalado
- Cartão microSD de boa qualidade (uso permanente)
- Acesso root (`sudo`)
- Conexão com internet

---

## 🔧 Uso rápido (script automatizado)

Para as partes repetitivas (drivers no initramfs + hook de proteção contra futuras atualizações de kernel), use o script deste repositório:

```bash
git clone https://github.com/SEU-USUARIO/opi4pro.git
cd opi4pro/docs/nvme-migration
chmod +x scripts/setup-nvme-boot.sh
sudo ./scripts/setup-nvme-boot.sh
```

O script cobre as **Fases 4 e 8** abaixo. As demais fases (parti­cionamento, `nand-sata-install`, fstab, `orangepiEnv.txt`) envolvem decisões específicas do seu disco/UUID e são feitas manualmente, como descrito a seguir.

---

## 🛠️ Passo a passo completo

### Fase 1 — Testar o hardware (opcional, recomendado)

```bash
sudo apt update
sudo apt install f3 fio parted
```

Testar capacidade real (detecta SSD falsificado):
```bash
cd /mnt/nvme
sudo f3write .
sudo f3read .
```

Testar velocidade:
```bash
sudo fio --name=sequencial --filename=teste_velocidade --size=1G --bs=1M --rw=readwrite --direct=1 --runtime=30 --time_based=0
sudo fio --name=aleatorio --filename=teste_iops --size=1G --bs=4k --rw=randread --direct=1 --runtime=30 --time_based=0
```
Esperado (PCIe x1): ~280 MB/s sequencial, ~50-60k IOPS aleatório.

### Fase 2 — Particionar o NVMe

```bash
cd ~
sudo umount /mnt/nvme        # se estiver montado

sudo parted /dev/nvme0n1 mklabel gpt
sudo parted /dev/nvme0n1 mkpart primary ext4 0% 100%
sudo mkfs.ext4 /dev/nvme0n1p1
```

### Fase 3 — Instalar o sistema no NVMe

```bash
sudo nand-sata-install
```

No menu:
1. **SPI flash boot** → Yes
2. **USB/SATA/NVMe root install** → Yes
3. **Filesystem type** → 1 (ext4)
4. **Confirmar formatação** → Yes

```bash
sudo reboot
```
> Normal o sistema ainda bootar pelo SD neste ponto — falta configurar o initramfs.

### Fase 4 — Drivers NVMe no initramfs

```bash
echo "nvme" | sudo tee -a /etc/initramfs-tools/modules
echo "nvme_core" | sudo tee -a /etc/initramfs-tools/modules
echo "nvme_pci" | sudo tee -a /etc/initramfs-tools/modules
sudo update-initramfs -u
```
*(Automatizado pelo `scripts/setup-nvme-boot.sh`)*

### Fase 5 — Fstab do NVMe

```bash
sudo mount /dev/nvme0n1p1 /mnt
sudo cat /mnt/etc/fstab
```

Garanta que exista a linha da raiz:
```text
UUID=SEU-UUID-DO-NVME  /  ext4  defaults,noatime,commit=600,errors=remount-ro,x-gvfs-hide  0  1
```
Descubra o UUID com `sudo blkid /dev/nvme0n1p1`. Depois:
```bash
sudo umount /mnt
```

### Fase 6 — Apontar o boot para o NVMe

```bash
sudo nano /boot/orangepiEnv.txt
```
Adicione ao final:
```text
rootdev=/dev/nvme0n1p1
```

### Fase 7 — Montar o SD em `/boot`

```bash
sudo blkid /dev/mmcblk1p1

sudo mount /dev/mmcblk1p1 /mnt
sudo cp -rf /boot/* /mnt/boot/
sudo umount /mnt

sudo nano /etc/fstab
```
Adicione (com o UUID do SD):
```text
UUID=UUID-DO-SD  /boot  ext4  defaults,noatime,commit=600,errors=remount-ro,x-gvfs-hide  0  2
```
```bash
sudo mount -a
df -h /boot   # deve mostrar o tamanho do SD
```

### Fase 8 — Hook automático para futuras atualizações

Cria `/etc/initramfs-tools/hooks/nvme-drivers` para garantir que os drivers NVMe sejam sempre incluídos após `apt upgrade`. *(Automatizado pelo `scripts/setup-nvme-boot.sh`, conteúdo em `scripts/nvme-drivers-hook`)*

### Fase 9 — Teste final

```bash
sudo reboot
df -h / && df -h /boot
cat /proc/cmdline
```

Esperado:
```
/dev/nvme0n1p1  229G   12G  206G   6% /
/dev/mmcblk1p1   57G   11G   46G  19% /boot
```

---

## 📊 Resumo da configuração final

| Componente | Localização | Função | Tamanho |
|---|---|---|---|
| SPI Flash | Placa | Bootloader inicial (eGON) | 16MB |
| SD Card | `/dev/mmcblk1p1` → `/boot` | Kernel, initramfs, device tree | ~57GB |
| NVMe SSD | `/dev/nvme0n1p1` → `/` | Sistema operacional | ~229GB |

---

## 🧯 Problemas comuns

Veja [troubleshooting.md](troubleshooting.md) para as soluções detalhadas de:
- Tela preta ao adicionar `rootdev`
- Sistema bootando do SD em vez do NVMe
- Boot falhando após atualização de kernel

---

## 🧾 Comandos de manutenção rápida

```bash
df -h / && df -h /boot
cat /sys/class/thermal/thermal_zone0/temp | awk '{print $1/1000 "°C"}'
free -h
sudo apt update && sudo apt upgrade
```

---

## Licença

MIT — veja [LICENSE](LICENSE).
