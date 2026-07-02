# opi4pro

Coleção de guias, tutoriais e scripts para o **Orange Pi 4 Pro** (Allwinner A733) — migração de sistema, configuração de hardware, otimizações e outros usos práticos.

## 📚 Guias disponíveis

| Guia | Descrição |
|---|---|
| [Migrando para NVMe](docs/nvme-migration/README.md) | Roteiro completo para rodar o SO no SSD NVMe mantendo `/boot` no SD card |

> Novos guias serão adicionados conforme o projeto cresce. Veja [CONTRIBUTING.md](CONTRIBUTING.md) se quiser propor um.

## 📁 Estrutura do repositório

```
opi4pro/
├── docs/
│   └── <tema>/
│       ├── README.md          ← guia principal do tema
│       ├── troubleshooting.md ← problemas comuns (se aplicável)
│       └── scripts/           ← scripts de apoio do tema
├── LICENSE
└── CONTRIBUTING.md
```

Cada guia vive em sua própria pasta dentro de `docs/`, com scripts próprios em `scripts/` quando fizer sentido automatizar algum passo.

## 🔧 Sobre o hardware

- **Placa:** Orange Pi 4 Pro
- **SoC:** Allwinner A733
- **SO testado:** Debian / Armbian

## Licença

MIT — veja [LICENSE](LICENSE).
