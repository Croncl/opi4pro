# 🚨 Troubleshooting

## Problema 1: Tela preta ao adicionar `rootdev=/dev/nvme0n1p1`

**Causa:** o initramfs do SD não tem os drivers NVMe.

**Solução:**
1. Boot pelo SD (remova a linha `rootdev` de `/boot/orangepiEnv.txt` se necessário)
2. Execute:
   ```bash
   echo "nvme" | sudo tee -a /etc/initramfs-tools/modules
   echo "nvme_core" | sudo tee -a /etc/initramfs-tools/modules
   echo "nvme_pci" | sudo tee -a /etc/initramfs-tools/modules
   sudo update-initramfs -u
   ```
3. Adicione `rootdev=/dev/nvme0n1p1` novamente
4. Reinicie

## Problema 2: Sistema bootou mas está rodando do SD, não do NVMe

**Causa:** o fstab do NVMe não tem a linha da raiz (`/`).

**Solução:**
```bash
sudo mount /dev/nvme0n1p1 /mnt
sudo nano /mnt/etc/fstab
# adicione: UUID=SEU-UUID-DO-NVME  /  ext4  defaults,noatime,commit=600,errors=remount-ro  0  1
sudo umount /mnt
sudo reboot
```

## Problema 3: Boot falhou após atualização de kernel

**Causa:** o initramfs foi recriado sem os drivers NVMe.

**Solução:**
```bash
# boot pelo SD, removendo rootdev se necessário
sudo update-initramfs -u
# reinsira rootdev=/dev/nvme0n1p1 em /boot/orangepiEnv.txt
sudo reboot
```

**Prevenção:** o hook em `scripts/nvme-drivers-hook` evita esse problema — instale-o com `scripts/setup-nvme-boot.sh`.

## Problema 4: SD montado em `/media/orangepi/opi_root`

**Causa:** o gerenciador de arquivos do desktop montou o SD automaticamente.

**Solução:** é normal, pode ignorar ou desmontar:
```bash
sudo umount /media/orangepi/opi_root
```
